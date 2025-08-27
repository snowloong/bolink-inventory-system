# API测试用例文档

## 📋 概述

本文档提供新能源电池进销存系统的API测试用例，包括功能测试、边界测试、异常测试和性能测试等场景。

**文档版本：** v1.0  
**更新时间：** 2025-01-27  
**适用范围：** 测试人员、开发人员、QA工程师

---

## 🎯 测试策略

### 测试分类
- **功能测试**：验证API功能是否符合需求
- **边界测试**：测试参数边界值和极限情况
- **异常测试**：测试错误处理和异常情况
- **性能测试**：测试API响应时间和并发能力
- **安全测试**：测试权限控制和数据安全
- **集成测试**：测试模块间的数据流转

### 测试环境
- **开发环境**：http://localhost:3000
- **测试环境**：http://test.bolink.com
- **预生产环境**：http://staging.bolink.com

---

## 🧪 基础数据管理模块测试用例

### 产品管理API测试

#### TC001: 创建产品 - 正常场景
```http
POST /api/basic/products
Content-Type: application/json
Authorization: Bearer {token}

{
  "action": "create",
  "data": {
    "product_code": "TEST-BAT-001",
    "product_name": "测试18650锂电池",
    "model": "TEST-18650-2500mAh",
    "battery_type": "锂离子",
    "capacity": 2500,
    "voltage": 3.7,
    "weight": 45,
    "category_id": 1,
    "unit": "个",
    "status": "active"
  }
}
```

**预期结果：**
```json
{
  "code": 200,
  "message": "产品创建成功",
  "data": {
    "id": 1001,
    "product_code": "TEST-BAT-001",
    "created_at": "2025-01-27T10:00:00Z"
  }
}
```

#### TC002: 创建产品 - 重复编码
```http
POST /api/basic/products
Content-Type: application/json

{
  "action": "create",
  "data": {
    "product_code": "TEST-BAT-001",  // 重复编码
    "product_name": "重复测试产品",
    "battery_type": "锂离子"
  }
}
```

**预期结果：**
```json
{
  "code": 400,
  "message": "产品编码已存在",
  "data": {
    "error_type": "duplicate_code",
    "field": "product_code",
    "value": "TEST-BAT-001"
  }
}
```

#### TC003: 创建产品 - 必填字段缺失
```http
POST /api/basic/products
Content-Type: application/json

{
  "action": "create",
  "data": {
    "product_name": "缺失编码的产品"
    // 缺少 product_code
  }
}
```

**预期结果：**
```json
{
  "code": 400,
  "message": "必填字段缺失",
  "data": {
    "error_type": "missing_required_field",
    "missing_fields": ["product_code"]
  }
}
```

#### TC004: 查询产品列表 - 分页测试
```http
POST /api/basic/products
Content-Type: application/json

{
  "action": "list",
  "params": {
    "page": 1,
    "size": 10,
    "battery_type": "锂离子",
    "status": "active"
  }
}
```

**预期结果：**
```json
{
  "code": 200,
  "message": "查询成功",
  "data": {
    "page": 1,
    "size": 10,
    "total": 25,
    "list": [
      {
        "id": 1001,
        "product_code": "TEST-BAT-001",
        "product_name": "测试18650锂电池",
        "battery_type": "锂离子",
        "status": "active"
      }
    ]
  }
}
```

#### TC005: 批量导入产品 - Excel文件
```http
POST /api/basic/products
Content-Type: application/json

{
  "action": "batch-import",
  "data": {
    "file": "data:application/vnd.openxmlformats-officedocument.spreadsheetml.sheet;base64,UEsDBBQABgAIAAAAIQC...",
    "template": "standard",
    "skip_errors": true
  }
}
```

**预期结果：**
```json
{
  "code": 200,
  "message": "批量导入完成",
  "data": {
    "total_rows": 100,
    "success_count": 95,
    "error_count": 5,
    "errors": [
      {
        "row": 10,
        "error": "产品编码重复",
        "data": {"product_code": "DUP-001"}
      }
    ]
  }
}
```

---

## 🛒 采购管理模块测试用例

### 采购计划API测试

#### TC101: 创建采购计划 - 正常场景
```http
POST /api/procurement/plans
Content-Type: application/json

{
  "action": "create",
  "data": {
    "plan_code": "TEST-PP-001",
    "plan_name": "测试采购计划",
    "plan_period": {
      "start_date": "2025-02-01",
      "end_date": "2025-02-28"
    },
    "items": [
      {
        "product_id": 1001,
        "planned_quantity": 1000,
        "estimated_price": 25.00,
        "required_date": "2025-02-15"
      }
    ],
    "status": "draft"
  }
}
```

#### TC102: 提交采购计划审批
```http
POST /api/procurement/plans
Content-Type: application/json

{
  "action": "submit",
  "params": {
    "id": 2001
  },
  "data": {
    "submit_comment": "请审批测试采购计划"
  }
}
```

#### TC103: 审批采购计划 - 权限测试
```http
POST /api/procurement/plans
Content-Type: application/json
Authorization: Bearer {普通用户token}

{
  "action": "approve",
  "params": {
    "id": 2001
  },
  "data": {
    "approval_result": "approved"
  }
}
```

**预期结果：**
```json
{
  "code": 403,
  "message": "权限不足",
  "data": {
    "error_type": "insufficient_permission",
    "required_role": "manager",
    "current_role": "user"
  }
}
```

### 采购订单API测试

#### TC104: 创建采购订单 - 金额超限
```http
POST /api/procurement/orders
Content-Type: application/json

{
  "action": "create",
  "data": {
    "order_code": "TEST-PO-001",
    "supplier_id": 3001,
    "items": [
      {
        "product_id": 1001,
        "quantity": 1000000,  // 超大数量
        "unit_price": 25.00
      }
    ]
  }
}
```

**预期结果：**
```json
{
  "code": 400,
  "message": "订单金额超出限制",
  "data": {
    "error_type": "amount_exceeded",
    "order_amount": 25000000,
    "max_amount": 10000000
  }
}
```

---

## 📦 库存管理模块测试用例

### 入库管理API测试

#### TC201: 创建入库单 - 正常场景
```http
POST /api/inventory/inbound
Content-Type: application/json

{
  "action": "create",
  "data": {
    "inbound_code": "TEST-IN-001",
    "inbound_type": "采购入库",
    "source_type": "purchase_order",
    "source_id": 4001,
    "warehouse_id": 5001,
    "items": [
      {
        "product_id": 1001,
        "batch_no": "TEST-BATCH-001",
        "planned_quantity": 1000,
        "unit_price": 25.00
      }
    ]
  }
}
```

#### TC202: 执行入库 - 数量不符
```http
POST /api/inventory/inbound
Content-Type: application/json

{
  "action": "execute",
  "params": {
    "id": 6001
  },
  "data": {
    "items": [
      {
        "id": 60011,
        "actual_quantity": 950,  // 少于计划数量1000
        "condition": "良好",
        "notes": "包装破损，部分产品丢失"
      }
    ]
  }
}
```

**预期结果：**
```json
{
  "code": 200,
  "message": "入库完成，存在数量差异",
  "data": {
    "inbound_id": 6001,
    "differences": [
      {
        "product_id": 1001,
        "planned_quantity": 1000,
        "actual_quantity": 950,
        "difference": -50
      }
    ]
  }
}
```

### 库存查询API测试

#### TC203: 库存查询 - 多条件筛选
```http
POST /api/inventory/stocks
Content-Type: application/json

{
  "action": "list",
  "params": {
    "warehouse_id": 5001,
    "product_code": "TEST-BAT-001",
    "quality_status": "合格",
    "min_quantity": 100,
    "batch_no": "TEST-BATCH-001"
  }
}
```

#### TC204: 库存调整 - 负库存检查
```http
POST /api/inventory/stocks
Content-Type: application/json

{
  "action": "adjust",
  "data": {
    "product_id": 1001,
    "warehouse_id": 5001,
    "batch_no": "TEST-BATCH-001",
    "adjust_type": "decrease",
    "adjust_quantity": 2000,  // 超过现有库存
    "reason": "测试负库存"
  }
}
```

**预期结果：**
```json
{
  "code": 400,
  "message": "库存不足，无法调整",
  "data": {
    "error_type": "insufficient_stock",
    "current_quantity": 950,
    "adjust_quantity": 2000,
    "shortage": 1050
  }
}
```

---

## 💰 销售管理模块测试用例

### 销售订单API测试

#### TC301: 创建销售订单 - 信用额度检查
```http
POST /api/sales/orders
Content-Type: application/json

{
  "action": "create",
  "data": {
    "order_code": "TEST-SO-001",
    "customer_id": 8001,
    "items": [
      {
        "product_id": 1001,
        "quantity": 100000,  // 超大订单
        "unit_price": 28.00
      }
    ]
  }
}
```

**预期结果：**
```json
{
  "code": 400,
  "message": "超出客户信用额度",
  "data": {
    "error_type": "credit_limit_exceeded",
    "order_amount": 2800000,
    "credit_limit": 1000000,
    "available_credit": 500000
  }
}
```

#### TC302: 价格计算API测试
```http
POST /api/sales/pricing
Content-Type: application/json

{
  "action": "calculate",
  "data": {
    "customer_id": 8001,
    "items": [
      {
        "product_id": 1001,
        "quantity": 1000
      }
    ],
    "pricing_strategy": "volume_discount"
  }
}
```

**预期结果：**
```json
{
  "code": 200,
  "message": "价格计算成功",
  "data": {
    "items": [
      {
        "product_id": 1001,
        "base_price": 28.00,
        "discount_rate": 0.05,
        "final_price": 26.60,
        "total_amount": 26600
      }
    ],
    "total_amount": 26600,
    "discount_amount": 1400
  }
}
```

---

## 🔍 质量控制模块测试用例

### 质检管理API测试

#### TC401: 创建质检任务 - 抽样规则
```http
POST /api/quality/inspections
Content-Type: application/json

{
  "action": "create",
  "data": {
    "inspection_code": "TEST-QC-001",
    "product_id": 1001,
    "batch_no": "TEST-BATCH-001",
    "inspection_quantity": 50,
    "total_quantity": 1000,
    "sampling_method": "random",
    "inspection_items": [
      {
        "item_name": "容量测试",
        "standard": "2500±75mAh",
        "sample_size": 10
      }
    ]
  }
}
```

#### TC402: 质检结果录入 - 不合格处理
```http
POST /api/quality/inspections
Content-Type: application/json

{
  "action": "execute",
  "params": {
    "id": 7001
  },
  "data": {
    "inspection_results": [
      {
        "item_name": "容量测试",
        "result": "不合格",
        "actual_value": "2300mAh",
        "pass_quantity": 7,
        "fail_quantity": 3
      }
    ],
    "overall_result": "不合格",
    "disposition": "隔离"
  }
}
```

**预期结果：**
```json
{
  "code": 200,
  "message": "质检完成，产品不合格",
  "data": {
    "inspection_id": 7001,
    "result": "不合格",
    "next_actions": [
      "隔离库存",
      "联系供应商",
      "启动退货流程"
    ]
  }
}
```

---

## 🛡️ 安全管理模块测试用例

### 危险品运输API测试

#### TC501: 创建运输记录 - UN编码验证
```http
POST /api/safety/hazmat-transport
Content-Type: application/json

{
  "action": "create",
  "data": {
    "transport_code": "TEST-HT-001",
    "product_info": {
      "product_id": 1001,
      "quantity": 1000,
      "un_number": "UN3480",
      "class": "9类"
    },
    "transport_info": {
      "carrier": "测试物流",
      "driver_license": "TEST123456",
      "vehicle_no": "测A12345"
    }
  }
}
```

#### TC502: 运输状态更新 - 异常处理
```http
POST /api/safety/hazmat-transport
Content-Type: application/json

{
  "action": "update-status",
  "params": {
    "id": 11001
  },
  "data": {
    "status": "emergency",
    "incident_type": "vehicle_breakdown",
    "location": "G4京港澳高速K100处",
    "description": "车辆故障，需要救援"
  }
}
```

---

## 📊 报表统计模块测试用例

### 业务报表API测试

#### TC601: 生成月度报表 - 大数据量
```http
POST /api/reports/business
Content-Type: application/json

{
  "action": "generate",
  "data": {
    "report_type": "monthly_summary",
    "period": {
      "start_date": "2025-01-01",
      "end_date": "2025-01-31"
    },
    "modules": ["procurement", "inventory", "sales"],
    "format": "excel",
    "include_charts": true
  }
}
```

#### TC602: 实时数据统计 - 并发测试
```http
POST /api/reports/realtime
Content-Type: application/json

{
  "action": "dashboard",
  "params": {
    "metrics": [
      "current_stock",
      "pending_orders",
      "quality_issues",
      "safety_alerts"
    ]
  }
}
```

---

## ⚡ 性能测试用例

### 并发测试场景

#### PT001: 库存查询并发测试
```bash
# 使用Apache Bench进行并发测试
ab -n 1000 -c 50 -H "Content-Type: application/json" \
   -p stock_query.json \
   http://localhost:3000/api/inventory/stocks
```

**测试数据文件 (stock_query.json):**
```json
{
  "action": "list",
  "params": {
    "warehouse_id": 5001,
    "page": 1,
    "size": 20
  }
}
```

**性能指标要求：**
- 响应时间：95%请求 < 500ms
- 吞吐量：> 200 QPS
- 错误率：< 0.1%

#### PT002: 批量数据导入性能测试
```http
POST /api/basic/products
Content-Type: application/json

{
  "action": "batch-import",
  "data": {
    "file": "base64编码的10000条产品数据",
    "template": "standard"
  }
}
```

**性能指标要求：**
- 处理时间：10000条数据 < 30秒
- 内存使用：< 512MB
- CPU使用率：< 80%

---

## 🔒 安全测试用例

### 权限控制测试

#### ST001: 未授权访问测试
```http
POST /api/basic/products
Content-Type: application/json
# 不提供Authorization头

{
  "action": "list"
}
```

**预期结果：**
```json
{
  "code": 401,
  "message": "未授权访问",
  "data": {
    "error_type": "unauthorized"
  }
}
```

#### ST002: Token过期测试
```http
POST /api/basic/products
Content-Type: application/json
Authorization: Bearer expired_token_here

{
  "action": "list"
}
```

**预期结果：**
```json
{
  "code": 401,
  "message": "Token已过期",
  "data": {
    "error_type": "token_expired",
    "expired_at": "2025-01-26T10:00:00Z"
  }
}
```

### SQL注入测试

#### ST003: SQL注入攻击测试
```http
POST /api/basic/products
Content-Type: application/json

{
  "action": "list",
  "params": {
    "product_code": "'; DROP TABLE products; --"
  }
}
```

**预期结果：**
- 系统应该正常处理，不执行恶意SQL
- 返回空结果或参数错误

---

## 🧪 集成测试用例

### 完整业务流程测试

#### IT001: 采购到销售完整流程
```javascript
// 测试脚本示例
const testCompleteFlow = async () => {
  // 1. 创建产品
  const product = await createProduct({
    product_code: 'IT-TEST-001',
    product_name: '集成测试产品'
  });
  
  // 2. 创建供应商
  const supplier = await createSupplier({
    supplier_code: 'IT-SUP-001',
    supplier_name: '集成测试供应商'
  });
  
  // 3. 创建采购订单
  const purchaseOrder = await createPurchaseOrder({
    supplier_id: supplier.id,
    items: [{
      product_id: product.id,
      quantity: 1000,
      unit_price: 25.00
    }]
  });
  
  // 4. 执行入库
  const inbound = await executeInbound({
    source_id: purchaseOrder.id,
    items: [{
      product_id: product.id,
      actual_quantity: 1000
    }]
  });
  
  // 5. 质检
  const inspection = await executeInspection({
    batch_no: inbound.items[0].batch_no,
    result: '合格'
  });
  
  // 6. 创建销售订单
  const salesOrder = await createSalesOrder({
    customer_id: 8001,
    items: [{
      product_id: product.id,
      quantity: 500
    }]
  });
  
  // 7. 执行出库
  const outbound = await executeOutbound({
    source_id: salesOrder.id
  });
  
  // 验证库存
  const stock = await getStock({
    product_id: product.id
  });
  
  assert.equal(stock.quantity, 500, '库存数量应为500');
};
```

---

## 📊 测试报告模板

### 测试执行报告

```markdown
# API测试执行报告

## 测试概况
- 测试时间：2025-01-27
- 测试环境：测试环境
- 测试人员：测试工程师A
- 测试版本：v1.0.0

## 测试结果统计
| 模块 | 总用例数 | 通过数 | 失败数 | 通过率 |
|------|----------|--------|--------|--------|
| 基础数据管理 | 20 | 18 | 2 | 90% |
| 采购管理 | 15 | 14 | 1 | 93% |
| 库存管理 | 25 | 23 | 2 | 92% |
| 销售管理 | 18 | 17 | 1 | 94% |
| 质量控制 | 12 | 11 | 1 | 92% |
| 安全管理 | 8 | 8 | 0 | 100% |
| 报表统计 | 10 | 9 | 1 | 90% |
| **总计** | **108** | **100** | **8** | **93%** |

## 失败用例分析
1. **TC002**: 产品编码重复检查 - 错误信息格式不符合规范
2. **TC104**: 采购订单金额超限 - 限制阈值配置错误
3. **TC204**: 库存调整负库存检查 - 边界值处理异常

## 性能测试结果
- 平均响应时间：245ms
- 95%响应时间：480ms
- 最大并发：200 QPS
- 错误率：0.05%

## 建议
1. 修复失败用例中的问题
2. 优化响应时间较长的接口
3. 加强边界值测试
4. 完善错误信息格式
```

---

## 📝 总结

本API测试用例文档提供了新能源电池进销存系统的全面测试方案，包括：

1. **功能测试用例**：覆盖所有核心业务功能
2. **异常测试用例**：验证错误处理和边界情况
3. **性能测试用例**：确保系统性能满足要求
4. **安全测试用例**：保障系统安全性
5. **集成测试用例**：验证模块间协作

**使用建议：**
- 按模块分阶段执行测试
- 优先执行核心业务流程测试
- 定期更新测试用例
- 自动化重复性测试
- 建立持续集成测试流程

**工具推荐：**
- **API测试**：Postman、Insomnia
- **性能测试**：Apache Bench、JMeter
- **自动化测试**：Jest、Mocha
- **集成测试**：Cypress、Playwright