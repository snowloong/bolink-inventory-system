import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { ApiProperty } from '@nestjs/swagger';
import { BatchInfo } from './batch-info.entity';

export enum InventoryStatus {
  AVAILABLE = 'available',
  RESERVED = 'reserved',
  DAMAGED = 'damaged',
  QUARANTINE = 'quarantine',
}

@Entity('inventory')
export class Inventory {
  @PrimaryGeneratedColumn()
  @ApiProperty({ description: '库存ID' })
  id: number;

  @Column()
  @ApiProperty({ description: '批次ID' })
  batchId: number;

  @Column({ type: 'int' })
  @ApiProperty({ description: '数量' })
  quantity: number;

  @Column({
    type: 'enum',
    enum: InventoryStatus,
    default: InventoryStatus.AVAILABLE,
  })
  @ApiProperty({ description: '库存状态' })
  status: InventoryStatus;

  @Column({ length: 100, nullable: true })
  @ApiProperty({ description: '库位编号' })
  locationCode: string;

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
  @ManyToOne(() => BatchInfo)
  @JoinColumn({ name: 'batchId' })
  batch: BatchInfo;
} 