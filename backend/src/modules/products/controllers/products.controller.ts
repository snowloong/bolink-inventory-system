import {
  Controller,
  Get,
  Post,
  Body,
  Patch,
  Param,
  Delete,
  Query,
  UseGuards,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { ProductsService } from '../services/products.service';
import { CreateProductDto, UpdateProductDto, ProductQueryDto } from '../dto/product.dto';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';

@ApiTags('产品管理')
@Controller('products')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class ProductsController {
  constructor(private readonly productsService: ProductsService) {}

  @Post()
  @ApiOperation({ summary: '创建产品' })
  create(@Body() createProductDto: CreateProductDto) {
    return this.productsService.create(createProductDto);
  }

  @Get()
  @ApiOperation({ summary: '获取产品列表' })
  findAll(@Query() query: ProductQueryDto) {
    return this.productsService.findAll(query);
  }

  @Get('statistics')
  @ApiOperation({ summary: '获取产品统计信息' })
  getStatistics() {
    return this.productsService.getProductStatistics();
  }

  @Get('low-stock')
  @ApiOperation({ summary: '获取低库存产品' })
  getLowStockProducts() {
    return this.productsService.getLowStockProducts();
  }

  @Get('expiring')
  @ApiOperation({ summary: '获取即将过期产品' })
  getExpiringProducts(@Query('days') days: number = 30) {
    return this.productsService.getExpiringProducts(days);
  }

  @Get(':id')
  @ApiOperation({ summary: '根据ID获取产品' })
  findOne(@Param('id') id: string) {
    return this.productsService.findOne(+id);
  }

  @Get('code/:code')
  @ApiOperation({ summary: '根据编码获取产品' })
  findByCode(@Param('code') code: string) {
    return this.productsService.findByCode(code);
  }

  @Patch(':id')
  @ApiOperation({ summary: '更新产品' })
  update(@Param('id') id: string, @Body() updateProductDto: UpdateProductDto) {
    return this.productsService.update(+id, updateProductDto);
  }

  @Delete(':id')
  @ApiOperation({ summary: '删除产品' })
  remove(@Param('id') id: string) {
    return this.productsService.remove(+id);
  }
} 