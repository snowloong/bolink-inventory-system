import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { BatchInfo } from './entities/batch-info.entity';
import { Inventory } from './entities/inventory.entity';
import { Product } from '../products/entities/product.entity';

@Module({
  imports: [TypeOrmModule.forFeature([BatchInfo, Inventory, Product])],
  controllers: [],
  providers: [],
  exports: [],
})
export class InventoryModule {} 