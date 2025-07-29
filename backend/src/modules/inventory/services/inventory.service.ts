import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, DataSource } from 'typeorm';
import { BatchInfo, BatchStatus } from '../entities/batch-info.entity';
import { Inventory, InventoryStatus } from '../entities/inventory.entity';
import { Product } from '../../products/entities/product.entity';

export interface OutboundResult {
  outboundItems: Array<{
    batchId: number;
    quantity: number;
  }>;
  success: boolean;
  remainingQuantity?: number;
}

@Injectable()
export class InventoryService {
  constructor(
    @InjectRepository(BatchInfo)
    private batchRepository: Repository<BatchInfo>,
    @InjectRepository(Inventory)
    private inventoryRepository: Repository<Inventory>,
    @InjectRepository(Product)
    private productRepository: Repository<Product>,
    private dataSource: DataSource,
  ) {}

  // 创建批次
  async createBatch(batchData: {
    productId: number;
    supplierId: number;
    productionDate: Date;
    expiryDate: Date;
    quantity: number;
    purchasePrice: number;
    qualityReportNo?: string;
    notes?: string;
  }): Promise<BatchInfo> {
    const batch = new BatchInfo();
    batch.batchSerial = this.generateBatchSerial();
    batch.productId = batchData.productId;
    batch.supplierId = batchData.supplierId;
    batch.productionDate = batchData.productionDate;
    batch.expiryDate = batchData.expiryDate;
    batch.initialQuantity = batchData.quantity;
    batch.remainingQuantity = batchData.quantity;
    batch.purchasePrice = batchData.purchasePrice;
    batch.qualityReportNo = batchData.qualityReportNo;
    batch.notes = batchData.notes;
    batch.status = BatchStatus.ACTIVE;

    const savedBatch = await this.batchRepository.save(batch);

    // 创建库存记录
    const inventory = new Inventory();
    inventory.batchId = savedBatch.id;
    inventory.quantity = batchData.quantity;
    inventory.status = InventoryStatus.AVAILABLE;
    await this.inventoryRepository.save(inventory);

    // 更新产品库存
    await this.updateProductStock(batchData.productId, batchData.quantity);

    return savedBatch;
  }

  // FIFO 出库算法
  async processFIFOOutbound(productId: number, quantity: number): Promise<OutboundResult> {
    const queryRunner = this.dataSource.createQueryRunner();
    await queryRunner.connect();
    await queryRunner.startTransaction();

    try {
      // 获取按生产日期排序的批次
      const batches = await queryRunner.manager.find(BatchInfo, {
        where: { 
          productId, 
          status: BatchStatus.ACTIVE,
          remainingQuantity: 0,
        },
        order: { productionDate: 'ASC' },
      });

      let remainingQuantity = quantity;
      const outboundItems = [];

      for (const batch of batches) {
        if (remainingQuantity <= 0) break;

        const outboundQty = Math.min(remainingQuantity, batch.remainingQuantity);
        batch.remainingQuantity -= outboundQty;
        remainingQuantity -= outboundQty;

        outboundItems.push({
          batchId: batch.id,
          quantity: outboundQty,
        });

        // 如果批次已耗尽，更新状态
        if (batch.remainingQuantity === 0) {
          batch.status = BatchStatus.DEPLETED;
        }

        await queryRunner.manager.save(BatchInfo, batch);
      }

      // 更新产品库存
      if (remainingQuantity === 0) {
        await this.updateProductStock(productId, -quantity);
      }

      await queryRunner.commitTransaction();

      return { 
        outboundItems, 
        success: remainingQuantity === 0,
        remainingQuantity: remainingQuantity > 0 ? remainingQuantity : undefined,
      };
    } catch (error) {
      await queryRunner.rollbackTransaction();
      throw error;
    } finally {
      await queryRunner.release();
    }
  }

  // 批次追溯
  async traceBatch(batchSerial: string) {
    const batch = await this.batchRepository.findOne({
      where: { batchSerial },
      relations: ['product', 'supplier'],
    });

    if (!batch) {
      throw new NotFoundException('批次不存在');
    }

    // 获取批次的所有库存记录
    const inventoryRecords = await this.inventoryRepository.find({
      where: { batchId: batch.id },
    });

    // 获取批次的所有出入库记录（这里需要实现出入库记录表）
    // const transactions = await this.transactionRepository.find({
    //   where: { batchId: batch.id },
    //   order: { createdAt: 'DESC' },
    // });

    return {
      batch,
      inventoryRecords,
      // transactions,
    };
  }

  // 获取产品库存
  async getProductInventory(productId: number) {
    const batches = await this.batchRepository.find({
      where: { 
        productId,
        status: BatchStatus.ACTIVE,
      },
      relations: ['supplier'],
      order: { productionDate: 'ASC' },
    });

    const totalQuantity = batches.reduce((sum, batch) => sum + batch.remainingQuantity, 0);
    const totalValue = batches.reduce((sum, batch) => sum + (batch.remainingQuantity * batch.purchasePrice), 0);

    return {
      productId,
      batches,
      totalQuantity,
      totalValue,
      batchCount: batches.length,
    };
  }

  // 库存预警检查
  async checkLowStock() {
    const products = await this.productRepository.find({
      where: { status: 'active' },
    });

    const lowStockProducts = [];

    for (const product of products) {
      const inventory = await this.getProductInventory(product.id);
      
      if (inventory.totalQuantity <= product.safetyStock) {
        lowStockProducts.push({
          product,
          currentStock: inventory.totalQuantity,
          safetyStock: product.safetyStock,
        });
      }
    }

    return lowStockProducts;
  }

  // 过期检查
  async checkExpiringProducts(days: number = 30) {
    const expiryDate = new Date();
    expiryDate.setDate(expiryDate.getDate() + days);

    const expiringBatches = await this.batchRepository.find({
      where: {
        expiryDate: expiryDate,
        status: BatchStatus.ACTIVE,
        remainingQuantity: 0,
      },
      relations: ['product', 'supplier'],
    });

    return expiringBatches;
  }

  // 生成批次序列号
  private generateBatchSerial(): string {
    const timestamp = Date.now();
    const random = Math.floor(Math.random() * 1000);
    return `B${timestamp}${random.toString().padStart(3, '0')}`;
  }

  // 更新产品库存
  private async updateProductStock(productId: number, quantity: number): Promise<void> {
    await this.productRepository
      .createQueryBuilder()
      .update(Product)
      .set({ currentStock: () => `currentStock + ${quantity}` })
      .where('id = :id', { id: productId })
      .execute();
  }
} 