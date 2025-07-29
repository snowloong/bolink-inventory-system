# 博链科技进销存管理系统 - 后端

## 项目简介

这是博链科技公司新能源电池进销存信息管理系统的后端服务，基于 Nest.js 框架开发，采用 TypeScript 语言，支持多端部署。

## 技术栈

- **框架**: Nest.js + TypeScript
- **数据库**: PostgreSQL + Redis
- **ORM**: TypeORM
- **认证**: JWT + Passport
- **文档**: Swagger
- **容器化**: Docker + Docker Compose

## 核心功能

### 1. 认证管理
- 用户注册/登录
- JWT 令牌认证
- 角色权限控制
- 密码加密存储

### 2. 产品管理
- 新能源电池产品信息管理
- 支持多种电池类型（锂离子、锂聚合物等）
- 产品编码唯一性验证
- 库存预警功能

### 3. 库存管理（核心功能）
- **批次追溯**: 完整的批次生命周期管理
- **FIFO策略**: 先进先出库存管理
- **实时库存**: 实时库存状态更新
- **库存预警**: 低库存自动预警
- **过期管理**: 即将过期产品提醒

### 4. 采购管理
- 采购计划制定
- 采购订单管理
- 批次入库管理
- 质检报告管理

### 5. 销售管理
- 销售订单处理
- 信用控制
- 出库管理
- 退货处理

### 6. 报表分析
- 库存报表
- 销售报表
- 采购报表
- 统计分析

## 快速开始

### 环境要求

- Node.js 18+
- PostgreSQL 15+
- Redis 7+
- Docker & Docker Compose (可选)

### 安装依赖

```bash
npm install
```

### 环境配置

复制环境变量文件：

```bash
cp env.example .env
```

编辑 `.env` 文件，配置数据库连接等信息。

### 数据库迁移

```bash
# 启动数据库
docker-compose up postgres redis -d

# 运行迁移
npm run migration:run
```

### 启动开发服务器

```bash
npm run start:dev
```

### 使用 Docker 启动

```bash
# 启动所有服务
docker-compose up -d

# 查看日志
docker-compose logs -f backend
```

## API 文档

启动服务后，访问以下地址查看 API 文档：

```
http://localhost:3000/api/docs
```

## 核心算法

### FIFO 出库算法

```typescript
async processFIFOOutbound(productId: number, quantity: number): Promise<OutboundResult> {
  // 按生产日期排序获取批次
  const batches = await this.batchRepository.find({
    where: { productId, status: BatchStatus.ACTIVE },
    order: { productionDate: 'ASC' }
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
      quantity: outboundQty
    });
  }
  
  return { outboundItems, success: remainingQuantity === 0 };
}
```

### 批次追溯

```typescript
async traceBatch(batchSerial: string) {
  const batch = await this.batchRepository.findOne({
    where: { batchSerial },
    relations: ['product', 'supplier']
  });
  
  const inventoryRecords = await this.inventoryRepository.find({
    where: { batchId: batch.id }
  });
  
  return { batch, inventoryRecords };
}
```

## 数据库设计

### 核心表结构

#### 批次表 (batch_info)
```sql
CREATE TABLE batch_info (
  id SERIAL PRIMARY KEY,
  batch_serial VARCHAR(50) UNIQUE NOT NULL,
  product_id INTEGER REFERENCES products(id),
  supplier_id INTEGER REFERENCES suppliers(id),
  production_date DATE,
  expiry_date DATE,
  initial_quantity INTEGER,
  remaining_quantity INTEGER,
  status VARCHAR(20),
  purchase_price DECIMAL(10,2),
  created_at TIMESTAMP DEFAULT NOW()
);
```

#### 库存表 (inventory)
```sql
CREATE TABLE inventory (
  id SERIAL PRIMARY KEY,
  batch_id INTEGER REFERENCES batch_info(id),
  quantity INTEGER,
  status VARCHAR(20),
  location_code VARCHAR(100),
  created_at TIMESTAMP DEFAULT NOW()
);
```

## 测试

```bash
# 单元测试
npm run test

# 测试覆盖率
npm run test:cov

# E2E测试
npm run test:e2e
```

## 部署

### 生产环境部署

1. 构建 Docker 镜像：
```bash
docker build -t bolink-backend .
```

2. 使用 Docker Compose 部署：
```bash
docker-compose -f docker-compose.prod.yml up -d
```

### 环境变量配置

生产环境需要配置以下环境变量：

- `NODE_ENV=production`
- `DB_HOST`, `DB_PORT`, `DB_USERNAME`, `DB_PASSWORD`, `DB_DATABASE`
- `REDIS_HOST`, `REDIS_PORT`, `REDIS_PASSWORD`
- `JWT_SECRET`
- `ALLOWED_ORIGINS`

## 性能优化

### 数据库优化
- 为常用查询字段创建索引
- 使用数据库连接池
- 定期清理过期数据

### 缓存策略
- Redis 缓存热点数据
- 缓存用户会话信息
- 缓存产品信息

### API 优化
- 实现 API 限流
- 使用压缩中间件
- 启用 CORS 配置

## 监控与日志

### 日志配置
- 使用 Winston 日志库
- 分级日志记录
- 日志文件轮转

### 健康检查
- 数据库连接检查
- Redis 连接检查
- 应用状态检查

## 安全措施

### 认证安全
- JWT 令牌过期机制
- 密码加密存储
- 角色权限控制

### 数据安全
- SQL 注入防护
- XSS 攻击防护
- CSRF 防护

### API 安全
- 请求限流
- 输入验证
- 错误信息脱敏

## 贡献指南

1. Fork 项目
2. 创建功能分支
3. 提交代码
4. 创建 Pull Request

## 许可证

本项目采用 MIT 许可证。

## 联系方式

- 作者: snowloong
- 邮箱: iamfinleyyao1997@163.com
- 项目地址: https://github.com/your-username/bolink-inventory-system 