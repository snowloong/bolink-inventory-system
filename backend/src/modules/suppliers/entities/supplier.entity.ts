import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
} from 'typeorm';
import { ApiProperty } from '@nestjs/swagger';

export enum SupplierStatus {
  ACTIVE = 'active',
  INACTIVE = 'inactive',
  SUSPENDED = 'suspended',
}

@Entity('suppliers')
export class Supplier {
  @PrimaryGeneratedColumn()
  @ApiProperty({ description: '供应商ID' })
  id: number;

  @Column({ length: 100, unique: true })
  @ApiProperty({ description: '供应商编码' })
  code: string;

  @Column({ length: 200 })
  @ApiProperty({ description: '供应商名称' })
  name: string;

  @Column({ length: 100, nullable: true })
  @ApiProperty({ description: '联系人' })
  contactPerson: string;

  @Column({ length: 50, nullable: true })
  @ApiProperty({ description: '联系电话' })
  phone: string;

  @Column({ length: 100, nullable: true })
  @ApiProperty({ description: '邮箱' })
  email: string;

  @Column({ type: 'text', nullable: true })
  @ApiProperty({ description: '地址' })
  address: string;

  @Column({
    type: 'enum',
    enum: SupplierStatus,
    default: SupplierStatus.ACTIVE,
  })
  @ApiProperty({ description: '供应商状态' })
  status: SupplierStatus;

  @Column({ type: 'text', nullable: true })
  @ApiProperty({ description: '备注' })
  notes: string;

  @CreateDateColumn()
  @ApiProperty({ description: '创建时间' })
  createdAt: Date;

  @UpdateDateColumn()
  @ApiProperty({ description: '更新时间' })
  updatedAt: Date;
} 