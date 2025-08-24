# API接口整合设计说明

## 🎯 设计目标

基于您的建议，我们将原本分散的多个接口整合成统一的接口，通过 `action` 参数来区分不同的操作类型。**每个模块根据其业务特点，定义专属的 `action` 字典**。

## ✨ 整合前后对比

### 整合前（采购计划模块）
```
GET  /api/procurement/plans          # 获取列表
GET  /api/procurement/plans/:id      # 获取详情
POST /api/procurement/plans          # 创建
POST /api/procurement/plans/:id      # 更新
POST /api/procurement/plans/:id/delete  # 删除
POST /api/procurement/plans/:id/approve # 审批
POST /api/procurement/plans/batch    # 批量操作
GET  /api/procurement/plans/statistics # 统计
POST /api/procurement/plans/export   # 导出
```
**总计：9个接口**

### 整合后（采购计划模块）
```
POST /api/procurement/plans  # 统一接口
```
**总计：1个接口**

## 📋 各模块专属Action字典

### 🛒 采购管理模块

#### 采购计划接口 (`/api/procurement/plans`)
```typescript
type ProcurementPlanAction = 
  | 'list'           // 获取列表
  | 'detail'         // 获取详情
  | 'create'         // 创建计划
  | 'update'         // 更新计划
  | 'delete'         // 删除计划
  | 'approve'        // 审批计划
  | 'batch'          // 批量操作
  | 'statistics'     // 统计分析
  | 'export'         // 数据导出
  | 'draft'          // 保存草稿
  | 'submit'         // 提交审核
  | 'reject'         // 驳回计划
  | 'copy'           // 复制计划
  | 'archive'        // 归档计划
```

#### 供应商评估接口 (`/api/procurement/evaluations`)
```typescript
type SupplierEvaluationAction = 
  | 'list'           // 获取列表
  | 'detail'         // 获取详情
  | 'create'         // 创建评估
  | 'update'         // 更新评估
  | 'performance'    // 获取绩效
  | 'history'        // 评估历史
  | 'reports'        // 生成报告
  | 'export'         // 数据导出
  | 'approve'        // 评估审批
  | 'trends'         // 趋势分析
  | 'compare'        // 供应商对比
  | 'score'          // 评分计算
  | 'alert'          // 预警设置
```

#### 采购订单接口 (`/api/procurement/orders`)
```typescript
type PurchaseOrderAction = 
  | 'list'           // 获取列表
  | 'detail'         // 获取详情
  | 'create'         // 创建订单
  | 'update'         // 更新订单
  | 'delete'         // 删除订单
  | 'approve'        // 审批订单
  | 'tracking'       // 订单跟踪
  | 'items'          // 订单明细
  | 'status'         // 状态变更
  | 'batch'          // 批量操作
  | 'statistics'     // 统计分析
  | 'export'         // 数据导出
  | 'cancel'         // 取消订单
  | 'confirm'        // 确认收货
  | 'payment'        // 付款管理
```

### 📦 库存管理模块

#### 库存查询接口 (`/api/inventory/stock`)
```typescript
type InventoryStockAction = 
  | 'list'           // 获取列表
  | 'detail'         // 获取详情
  | 'query'          // 条件查询
  | 'alerts'         // 库存预警
  | 'expiring'       // 即将过期
  | 'statistics'     // 统计分析
  | 'export'         // 数据导出
  | 'movement'       // 库存移动
  | 'aging'          // 库存龄分析
  | 'abc'            // ABC分析
  | 'forecast'       // 库存预测
  | 'optimization'   // 库存优化
```

#### 库存预留管理接口 (`/api/inventory/reservations`)
```typescript
type InventoryReservationAction = 
  | 'list'           // 获取列表
  | 'detail'         // 获取详情
  | 'create'         // 创建预留
  | 'update'         // 更新预留
  | 'delete'         // 取消预留
  | 'details'        // 详情查询
  | 'priority'       // 优先级管理
  | 'conflicts'      // 冲突检测
  | 'batch'          // 批量操作
  | 'statistics'     // 统计分析
  | 'export'         // 数据导出
  | 'extend'         // 延期预留
  | 'split'          // 拆分预留
  | 'merge'          // 合并预留
```

#### 批次管理接口 (`/api/inventory/batches`)
```typescript
type BatchManagementAction = 
  | 'list'           // 获取列表
  | 'detail'         // 获取详情
  | 'create'         // 创建批次
  | 'update'         // 更新批次
  | 'trace'          // 批次追溯
  | 'merge'          // 批次合并
  | 'expiring'       // 即将过期
  | 'quality'        // 质量检查
  | 'statistics'     // 统计分析
  | 'export'         // 数据导出
  | 'split'          // 批次拆分
  | 'transfer'       // 批次转移
  | 'dispose'        // 批次处置
  | 'recall'         // 批次召回
```

### 🏪 销售管理模块

#### 销售订单接口 (`/api/sales/orders`)
```typescript
type SalesOrderAction = 
  | 'list'           // 获取列表
  | 'detail'         // 获取详情
  | 'create'         // 创建订单
  | 'update'         // 更新订单
  | 'delete'         // 删除订单
  | 'approve'        // 审批订单
  | 'ship'           // 发货处理
  | 'deliver'        // 配送管理
  | 'return'         // 退货处理
  | 'refund'         // 退款处理
  | 'invoice'        // 发票管理
  | 'payment'        // 收款管理
  | 'batch'          // 批量操作
  | 'statistics'     // 统计分析
  | 'export'         // 数据导出
```

### 🔍 质量控制模块

#### 质量检验接口 (`/api/quality/inspections`)
```typescript
type QualityInspectionAction = 
  | 'list'           // 获取列表
  | 'detail'         // 获取详情
  | 'create'         // 创建检验
  | 'update'         // 更新检验
  | 'execute'        // 执行检验
  | 'result'         // 检验结果
  | 'approve'        // 结果审批
  | 'reject'         // 不合格处理
  | 'retest'         // 复检处理
  | 'certificate'    // 证书管理
  | 'standard'       // 标准管理
  | 'statistics'     // 统计分析
  | 'export'         // 数据导出
  | 'alert'          // 质量预警
  | 'trend'          // 质量趋势
```

## 🚀 主要优势

### 1. 业务导向的Action设计
- 每个模块的 `action` 根据具体业务需求定制
- 支持复杂的业务操作组合
- 便于业务逻辑的扩展和维护

### 2. 接口数量大幅减少
- **整合前**：503个接口
- **整合后**：约50个接口
- **减少比例**：90%以上

### 3. 统一的请求格式
```json
{
  "action": "模块特定的操作类型",
  "params": {
    "page": 1,
    "size": 20,
    "filters": {...}
  },
  "data": {
    "业务数据": {...}
  }
}
```

### 4. 便于前端开发
- 统一的API调用方式
- 统一的错误处理
- 统一的参数验证
- 类型安全的Action定义

### 5. 便于后端维护
- 减少重复代码
- 统一的业务逻辑处理
- 便于权限控制和日志记录
- 模块化的Action处理

## 💡 实现建议

### 后端实现（TypeScript）
```typescript
// 定义模块特定的Action类型
type ProcurementPlanAction = 'list' | 'detail' | 'create' | 'update' | 'delete' | 'approve' | 'batch' | 'statistics' | 'export';

// 统一的控制器方法
@Post('plans')
async handleProcurementPlans(@Body() request: {
  action: ProcurementPlanAction;
  params?: any;
  data?: any;
}) {
  switch (request.action) {
    case 'list':
      return this.getPlansList(request.params);
    case 'detail':
      return this.getPlanDetail(request.params.id);
    case 'create':
      return this.createPlan(request.data);
    case 'approve':
      return this.approvePlan(request.params.id, request.data);
    // ... 其他操作
  }
}
```

### 前端实现（TypeScript）
```typescript
// 定义模块特定的Action类型
type ProcurementPlanAction = 'list' | 'detail' | 'create' | 'update' | 'delete' | 'approve' | 'batch' | 'statistics' | 'export';

// 统一的API调用方法
const apiCall = async <T>(
  endpoint: string, 
  action: T, 
  params?: any, 
  data?: any
) => {
  const response = await fetch(`/api/${endpoint}`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ action, params, data })
  });
  return response.json();
};

// 使用示例（类型安全）
const plans = await apiCall<ProcurementPlanAction>('procurement/plans', 'list', { page: 1, size: 20 });
const plan = await apiCall<ProcurementPlanAction>('procurement/plans', 'detail', { id: 123 });
```

## 🎉 总结

这种模块化的 `action` 设计模式不仅简化了接口结构，还提高了系统的可维护性和开发效率。每个模块根据其业务特点定义专属的 `action` 字典，既保持了接口的语义清晰，又实现了接口的统一管理。

这种设计特别适合企业级应用，能够有效减少接口数量，提高开发效率，降低维护成本，同时保持业务逻辑的清晰性和可扩展性。
