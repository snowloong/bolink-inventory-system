import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  OneToMany,
} from 'typeorm';
import { ApiProperty } from '@nestjs/swagger';

export enum BatteryType {
  LITHIUM_ION = 'lithium_ion',
  LITHIUM_POLYMER = 'lithium_polymer',
  NICKEL_METAL_HYDRIDE = 'nickel_metal_hydride',
  LEAD_ACID = 'lead_acid',
  SOLID_STATE = 'solid_state',
}

export enum ProductStatus {
  ACTIVE = 'active',
  INACTIVE = 'inactive',
  DISCONTINUED = 'discontinued',
}

@Entity('products')
export class Product {
  @PrimaryGeneratedColumn()
  @ApiProperty({ description: '产品ID' })
  id: number;

  @Column({ length: 100, unique: true })
  @ApiProperty({ description: '产品编码' })
  code: string;

  @Column({ length: 200 })
  @ApiProperty({ description: '产品名称' })
  name: string;

  @Column({ type: 'text', nullable: true })
  @ApiProperty({ description: '产品描述' })
  description: string;

  @Column({
    type: 'enum',
    enum: BatteryType,
  })
  @ApiProperty({ description: '电池类型' })
  batteryType: BatteryType;

  @Column({ type: 'decimal', precision: 10, scale: 2 })
  @ApiProperty({ description: '额定电压(V)' })
  voltage: number;

  @Column({ type: 'decimal', precision: 10, scale: 2 })
  @ApiProperty({ description: '额定容量(Ah)' })
  capacity: number;

  @Column({ type: 'decimal', precision: 10, scale: 2 })
  @ApiProperty({ description: '重量(kg)' })
  weight: number;

  @Column({ length: 50 })
  @ApiProperty({ description: '尺寸规格' })
  dimensions: string;

  @Column({ type: 'decimal', precision: 10, scale: 2 })
  @ApiProperty({ description: '采购价格' })
  purchasePrice: number;

  @Column({ type: 'decimal', precision: 10, scale: 2 })
  @ApiProperty({ description: '销售价格' })
  sellingPrice: number;

  @Column({ type: 'int' })
  @ApiProperty({ description: '安全库存' })
  safetyStock: number;

  @Column({ type: 'int' })
  @ApiProperty({ description: '最大库存' })
  maxStock: number;

  @Column({
    type: 'enum',
    enum: ProductStatus,
    default: ProductStatus.ACTIVE,
  })
  @ApiProperty({ description: '产品状态' })
  status: ProductStatus;

  @Column({ type: 'int', default: 0 })
  @ApiProperty({ description: '当前库存' })
  currentStock: number;

  @Column({ type: 'date', nullable: true })
  @ApiProperty({ description: '生产日期' })
  productionDate: Date;

  @Column({ type: 'date', nullable: true })
  @ApiProperty({ description: '过期日期' })
  expiryDate: Date;

  @Column({ length: 100, nullable: true })
  @ApiProperty({ description: '制造商' })
  manufacturer: string;

  @Column({ length: 100, nullable: true })
  @ApiProperty({ description: '品牌' })
  brand: string;

  @Column({ type: 'text', nullable: true })
  @ApiProperty({ description: '技术参数' })
  technicalSpecs: string;

  @Column({ type: 'text', nullable: true })
  @ApiProperty({ description: '安全注意事项' })
  safetyNotes: string;

  @CreateDateColumn()
  @ApiProperty({ description: '创建时间' })
  createdAt: Date;

  @UpdateDateColumn()
  @ApiProperty({ description: '更新时间' })
  updatedAt: Date;
} 