import { IsString, IsNumber, IsEnum, IsOptional, IsDateString, Min, Max } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';
import { BatteryType, ProductStatus } from '../entities/product.entity';

export class CreateProductDto {
  @ApiProperty({ description: '产品编码' })
  @IsString()
  code: string;

  @ApiProperty({ description: '产品名称' })
  @IsString()
  name: string;

  @ApiProperty({ description: '产品描述', required: false })
  @IsOptional()
  @IsString()
  description?: string;

  @ApiProperty({ description: '电池类型', enum: BatteryType })
  @IsEnum(BatteryType)
  batteryType: BatteryType;

  @ApiProperty({ description: '额定电压(V)' })
  @IsNumber()
  @Min(0)
  voltage: number;

  @ApiProperty({ description: '额定容量(Ah)' })
  @IsNumber()
  @Min(0)
  capacity: number;

  @ApiProperty({ description: '重量(kg)' })
  @IsNumber()
  @Min(0)
  weight: number;

  @ApiProperty({ description: '尺寸规格' })
  @IsString()
  dimensions: string;

  @ApiProperty({ description: '采购价格' })
  @IsNumber()
  @Min(0)
  purchasePrice: number;

  @ApiProperty({ description: '销售价格' })
  @IsNumber()
  @Min(0)
  sellingPrice: number;

  @ApiProperty({ description: '安全库存' })
  @IsNumber()
  @Min(0)
  safetyStock: number;

  @ApiProperty({ description: '最大库存' })
  @IsNumber()
  @Min(0)
  maxStock: number;

  @ApiProperty({ description: '生产日期', required: false })
  @IsOptional()
  @IsDateString()
  productionDate?: string;

  @ApiProperty({ description: '过期日期', required: false })
  @IsOptional()
  @IsDateString()
  expiryDate?: string;

  @ApiProperty({ description: '制造商', required: false })
  @IsOptional()
  @IsString()
  manufacturer?: string;

  @ApiProperty({ description: '品牌', required: false })
  @IsOptional()
  @IsString()
  brand?: string;

  @ApiProperty({ description: '技术参数', required: false })
  @IsOptional()
  @IsString()
  technicalSpecs?: string;

  @ApiProperty({ description: '安全注意事项', required: false })
  @IsOptional()
  @IsString()
  safetyNotes?: string;
}

export class UpdateProductDto {
  @ApiProperty({ description: '产品名称', required: false })
  @IsOptional()
  @IsString()
  name?: string;

  @ApiProperty({ description: '产品描述', required: false })
  @IsOptional()
  @IsString()
  description?: string;

  @ApiProperty({ description: '电池类型', enum: BatteryType, required: false })
  @IsOptional()
  @IsEnum(BatteryType)
  batteryType?: BatteryType;

  @ApiProperty({ description: '额定电压(V)', required: false })
  @IsOptional()
  @IsNumber()
  @Min(0)
  voltage?: number;

  @ApiProperty({ description: '额定容量(Ah)', required: false })
  @IsOptional()
  @IsNumber()
  @Min(0)
  capacity?: number;

  @ApiProperty({ description: '重量(kg)', required: false })
  @IsOptional()
  @IsNumber()
  @Min(0)
  weight?: number;

  @ApiProperty({ description: '尺寸规格', required: false })
  @IsOptional()
  @IsString()
  dimensions?: string;

  @ApiProperty({ description: '采购价格', required: false })
  @IsOptional()
  @IsNumber()
  @Min(0)
  purchasePrice?: number;

  @ApiProperty({ description: '销售价格', required: false })
  @IsOptional()
  @IsNumber()
  @Min(0)
  sellingPrice?: number;

  @ApiProperty({ description: '安全库存', required: false })
  @IsOptional()
  @IsNumber()
  @Min(0)
  safetyStock?: number;

  @ApiProperty({ description: '最大库存', required: false })
  @IsOptional()
  @IsNumber()
  @Min(0)
  maxStock?: number;

  @ApiProperty({ description: '产品状态', enum: ProductStatus, required: false })
  @IsOptional()
  @IsEnum(ProductStatus)
  status?: ProductStatus;

  @ApiProperty({ description: '生产日期', required: false })
  @IsOptional()
  @IsDateString()
  productionDate?: string;

  @ApiProperty({ description: '过期日期', required: false })
  @IsOptional()
  @IsDateString()
  expiryDate?: string;

  @ApiProperty({ description: '制造商', required: false })
  @IsOptional()
  @IsString()
  manufacturer?: string;

  @ApiProperty({ description: '品牌', required: false })
  @IsOptional()
  @IsString()
  brand?: string;

  @ApiProperty({ description: '技术参数', required: false })
  @IsOptional()
  @IsString()
  technicalSpecs?: string;

  @ApiProperty({ description: '安全注意事项', required: false })
  @IsOptional()
  @IsString()
  safetyNotes?: string;
}

export class ProductQueryDto {
  @ApiProperty({ description: '页码', required: false })
  @IsOptional()
  @IsNumber()
  page?: number = 1;

  @ApiProperty({ description: '每页数量', required: false })
  @IsOptional()
  @IsNumber()
  @Min(1)
  @Max(100)
  limit?: number = 10;

  @ApiProperty({ description: '搜索关键词', required: false })
  @IsOptional()
  @IsString()
  search?: string;

  @ApiProperty({ description: '电池类型', enum: BatteryType, required: false })
  @IsOptional()
  @IsEnum(BatteryType)
  batteryType?: BatteryType;

  @ApiProperty({ description: '产品状态', enum: ProductStatus, required: false })
  @IsOptional()
  @IsEnum(ProductStatus)
  status?: ProductStatus;
} 