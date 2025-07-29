import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, Like } from 'typeorm';
import { Product, ProductStatus } from '../entities/product.entity';
import { CreateProductDto, UpdateProductDto, ProductQueryDto } from '../dto/product.dto';

@Injectable()
export class ProductsService {
  constructor(
    @InjectRepository(Product)
    private productRepository: Repository<Product>,
  ) {}

  async create(createProductDto: CreateProductDto): Promise<Product> {
    // 检查产品编码是否已存在
    const existingProduct = await this.productRepository.findOne({
      where: { code: createProductDto.code },
    });

    if (existingProduct) {
      throw new BadRequestException('产品编码已存在');
    }

    const product = this.productRepository.create(createProductDto);
    return await this.productRepository.save(product);
  }

  async findAll(query: ProductQueryDto) {
    const { page = 1, limit = 10, search, batteryType, status } = query;
    const skip = (page - 1) * limit;

    const queryBuilder = this.productRepository.createQueryBuilder('product');

    if (search) {
      queryBuilder.where(
        '(product.name LIKE :search OR product.code LIKE :search OR product.description LIKE :search)',
        { search: `%${search}%` }
      );
    }

    if (batteryType) {
      queryBuilder.andWhere('product.batteryType = :batteryType', { batteryType });
    }

    if (status) {
      queryBuilder.andWhere('product.status = :status', { status });
    }

    const [products, total] = await queryBuilder
      .skip(skip)
      .take(limit)
      .orderBy('product.createdAt', 'DESC')
      .getManyAndCount();

    return {
      data: products,
      total,
      page,
      limit,
      totalPages: Math.ceil(total / limit),
    };
  }

  async findOne(id: number): Promise<Product> {
    const product = await this.productRepository.findOne({ where: { id } });
    
    if (!product) {
      throw new NotFoundException('产品不存在');
    }
    
    return product;
  }

  async findByCode(code: string): Promise<Product> {
    const product = await this.productRepository.findOne({ where: { code } });
    
    if (!product) {
      throw new NotFoundException('产品不存在');
    }
    
    return product;
  }

  async update(id: number, updateProductDto: UpdateProductDto): Promise<Product> {
    const product = await this.findOne(id);
    
    // 如果更新了产品编码，检查是否与其他产品冲突
    if (updateProductDto.code && updateProductDto.code !== product.code) {
      const existingProduct = await this.productRepository.findOne({
        where: { code: updateProductDto.code },
      });

      if (existingProduct) {
        throw new BadRequestException('产品编码已存在');
      }
    }

    Object.assign(product, updateProductDto);
    return await this.productRepository.save(product);
  }

  async remove(id: number): Promise<void> {
    const product = await this.findOne(id);
    await this.productRepository.remove(product);
  }

  async updateStock(id: number, quantity: number): Promise<Product> {
    const product = await this.findOne(id);
    product.currentStock += quantity;
    
    // 确保库存不为负数
    if (product.currentStock < 0) {
      throw new BadRequestException('库存不足');
    }
    
    return await this.productRepository.save(product);
  }

  async getLowStockProducts(): Promise<Product[]> {
    return await this.productRepository.find({
      where: {
        status: ProductStatus.ACTIVE,
      },
      order: {
        currentStock: 'ASC',
      },
    });
  }

  async getExpiringProducts(days: number = 30): Promise<Product[]> {
    const expiryDate = new Date();
    expiryDate.setDate(expiryDate.getDate() + days);

    return await this.productRepository
      .createQueryBuilder('product')
      .where('product.expiryDate <= :expiryDate', { expiryDate })
      .andWhere('product.status = :status', { status: ProductStatus.ACTIVE })
      .orderBy('product.expiryDate', 'ASC')
      .getMany();
  }

  async getProductStatistics() {
    const totalProducts = await this.productRepository.count();
    const activeProducts = await this.productRepository.count({
      where: { status: ProductStatus.ACTIVE },
    });
    const lowStockProducts = await this.productRepository.count({
      where: {
        status: ProductStatus.ACTIVE,
      },
    });

    const lowStockCount = await this.productRepository
      .createQueryBuilder('product')
      .where('product.currentStock <= product.safetyStock')
      .andWhere('product.status = :status', { status: ProductStatus.ACTIVE })
      .getCount();

    return {
      totalProducts,
      activeProducts,
      lowStockProducts: lowStockCount,
    };
  }
} 