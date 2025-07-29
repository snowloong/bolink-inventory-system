import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToOne,
  JoinColumn,
  OneToMany,
} from 'typeorm';
import { ApiProperty } from '@nestjs/swagger';
import { Product } from '../../products/entities/product.entity';
import { Supplier } from '../../suppliers/entities/supplier.entity';

export enum BatchStatus {
  ACTIVE = 'active',
  DEPLETED = 'depleted',
  EXPIRED = 'expired',
  RECALLED = 'recalled',
}

@Entity('batch_info')
export class BatchInfo {
  @PrimaryGeneratedColumn()
  @ApiProperty({ description: '批次ID' })
  id: number;

  @Column({ length: 50, unique: true })
  @ApiProperty({ description: '批次序列号' })
  batchSerial: string;

  @Column()
  @ApiProperty({ description: '产品ID' })
  productId: number;

  @Column()
  @ApiProperty({ description: '供应商ID' })
  supplierId: number;

  @Column({ type: 'date' })
  @ApiProperty({ description: '生产日期' })
  productionDate: Date;

  @Column({ type: 'date' })
  @ApiProperty({ description: '过期日期' })
  expiryDate: Date;

  @Column({ type: 'int' })
  @ApiProperty({ description: '初始数量' })
  initialQuantity: number;

  @Column({ type: 'int' })
  @ApiProperty({ description: '剩余数量' })
  remainingQuantity: number;

  @Column({
    type: 'enum',
    enum: BatchStatus,
    default: BatchStatus.ACTIVE,
  })
  @ApiProperty({ description: '批次状态' })
  status: BatchStatus;

  @Column({ type: 'decimal', precision: 10, scale: 2 })
  @ApiProperty({ description: '采购价格' })
  purchasePrice: number;

  @Column({ length: 100, nullable: true })
  @ApiProperty({ description: '质检报告编号' })
  qualityReportNo: string;

  @Column({ type: 'text', nullable: true })
  @ApiProperty({ description: '备注' })
  notes: string;

  @CreateDateColumn()
  @ApiProperty({ description: '创建时间' })
  createdAt: Date;

  @UpdateDateColumn()
  @ApiProperty({ description: '更新时间' })
  updatedAt: Date;

  // 关联关系
  @ManyToOne(() => Product)
  @JoinColumn({ name: 'productId' })
  product: Product;

  @ManyToOne(() => Supplier)
  @JoinColumn({ name: 'supplierId' })
  supplier: Supplier;
} 