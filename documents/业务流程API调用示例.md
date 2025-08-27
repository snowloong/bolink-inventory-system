<!--
 * @Author: snowloong iamfinleyyao1997@163.com
 * @Date: 2025-08-27 21:50:22
 * @LastEditors: snowloong iamfinleyyao1997@163.com
 * @LastEditTime: 2025-08-27 21:50:24
 * @FilePath: /bolink-inventory-system/documents/业务流程API调用示例.md
 * @Description: 
 * 
-->
# 业务流程API调用示例

## 📋 概述

本文档提供新能源电池进销存系统的完整业务流程API调用示例，展示从基础数据设置到完整业务链条的实际操作流程。

**文档版本：** v1.0  
**更新时间：** 2025-01-27  
**适用范围：** 开发人员、测试人员、系统集成人员

---

## 🎯 业务流程概览

### 完整业务链条
```
基础数据设置 → 供应商管理 → 采购计划 → 采购订单 → 入库管理 → 质量检验 → 库存管理 → 销售订单 → 出库管理 → 财务结算 → 报表统计
```

### 涉及的核心模块
- 📦 基础数据管理（产品、供应商、客户、仓库）
- 🛒 采购管理（采购计划、采购订单、供应商评估）
- 📋 库存管理（入库、出库、库存调整、盘点）
- 💰 销售管理（销售订单、客户管理、价格管理）
- 🔍 质量控制（质量检验、批次追溯、不合格品处理）
- 🛡️ 安全管理（安全检查、危险品运输、应急处理）
- 📊 报表统计（业务报表、财务报表、分析报表）

---

## 🚀 完整业务流程示例

### 第一步：基础数据设置

#### 1.1 创建产品信息
```http
POST /api/basic/products
Content-Type: application/json

{
  "action": "create",
  "data": {
    "product_code": "BAT-18650-2500",
    "product_name": "18650锂离子电池",
    "model": "18650-2500mAh-3.7V",
    "battery_type": "锂离子",
    "capacity": 2500,
    "voltage": 3.7,
    "weight": 45,
    "dimensions": {
      "diameter": 18,
      "height": 65
    },
    "specifications": {
      "nominal_capacity": "2500mAh",
      "nominal_voltage": "3.7V",
      "charging_voltage": "4.2V",
      "discharge_cutoff": "2.5V",
      "max_charge_current": "1C",
      "max_discharge_current": "2C",
      "cycle_life": "≥500次",
      "operating_temp": "-10°C ~ +60°C"
    },
    "safety_features": [
      "过充保护",
      "过放保护",
      "短路保护",
      "过温保护"
    ],
    "certifications": [
      {
        "type": "UN38.3",
        "certificate_no": "UN38.3-2024-001",
        "issue_date": "2024-01-15",
        "expire_date": "2027-01-15"
      },
      {
        "type": "CE",
        "certificate_no": "CE-2024-002",
        "issue_date": "2024-02-01",
        "expire_date": "2027-02-01"
      }
    ],
    "category_id": 1,
    "unit": "个",
    "min_stock": 1000,
    "max_stock": 10000,
    "status": "active"
  }
}
```

**响应示例：**
```json
{
  "code": 200,
  "message": "产品创建成功",
  "data": {
    "id": 1001,
    "product_code": "BAT-18650-2500",
    "created_at": "2025-01-27T10:00:00Z"
  },
  "timestamp": "2025-01-27T10:00:00Z"
}
```

#### 1.2 创建供应商信息
```http
POST /api/basic/suppliers
Content-Type: application/json

{
  "action": "create",
  "data": {
    "supplier_code": "SUP-CATL-001",
    "supplier_name": "宁德时代新能源科技股份有限公司",
    "supplier_type": "制造商",
    "business_license": "91350900MA2XH0E15X",
    "contact_info": {
      "address": "福建省宁德市蕉城区漳湾镇新港路2号",
      "contact_person": "张经理",
      "phone": "0593-8888888",
      "email": "zhang.manager@catl.com",
      "fax": "0593-8888889"
    },
    "bank_info": {
      "bank_name": "中国工商银行宁德分行",
      "account_name": "宁德时代新能源科技股份有限公司",
      "account_number": "1234567890123456789"
    },
    "qualifications": [
      {
        "type": "ISO9001",
        "certificate_no": "ISO9001-2024-001",
        "issue_date": "2024-01-01",
        "expire_date": "2027-01-01",
        "issuer": "中国质量认证中心"
      },
      {
        "type": "ISO14001",
        "certificate_no": "ISO14001-2024-001",
        "issue_date": "2024-01-01",
        "expire_date": "2027-01-01",
        "issuer": "中国质量认证中心"
      }
    ],
    "cooperation_level": "战略",
    "credit_rating": "AAA",
    "payment_terms": "月结30天",
    "status": "active"
  }
}
```

#### 1.3 创建客户信息
```http
POST /api/sales/customers
Content-Type: application/json

{
  "action": "create",
  "data": {
    "customer_code": "CUS-BYD-001",
    "customer_name": "比亚迪股份有限公司",
    "customer_type": "企业客户",
    "industry": "新能源汽车",
    "business_license": "91440300708461136T",
    "contact_info": {
      "address": "广东省深圳市坪山区比亚迪路3009号",
      "contact_person": "李总监",
      "phone": "0755-8888888",
      "email": "li.director@byd.com"
    },
    "credit_info": {
      "credit_limit": 5000000,
      "credit_rating": "AA+",
      "payment_terms": "月结45天"
    },
    "status": "active"
  }
}
```

#### 1.4 创建仓库信息
```http
POST /api/basic/warehouses
Content-Type: application/json

{
  "action": "create",
  "data": {
    "warehouse_code": "WH-SZ-001",
    "warehouse_name": "深圳电池仓储中心",
    "warehouse_type": "成品仓",
    "address": "广东省深圳市宝安区新安街道海秀路1号",
    "manager": "王仓管",
    "phone": "0755-6666666",
    "capacity": {
      "total_area": 5000,
      "storage_area": 4000,
      "max_capacity": 100000
    },
    "safety_config": {
      "fire_system": true,
      "temperature_control": true,
      "humidity_control": true,
      "security_system": true,
      "temp_range": "15-25°C",
      "humidity_range": "45-75%RH"
    },
    "zones": [
      {
        "zone_code": "A01",
        "zone_name": "锂电池存储区A",
        "zone_type": "普通存储",
        "capacity": 20000
      },
      {
        "zone_code": "B01",
        "zone_name": "危险品存储区B",
        "zone_type": "危险品存储",
        "capacity": 5000
      }
    ],
    "status": "active"
  }
}
```

### 第二步：采购流程

#### 2.1 创建采购计划
```http
POST /api/procurement/plans
Content-Type: application/json

{
  "action": "create",
  "data": {
    "plan_code": "PP-2025-001",
    "plan_name": "2025年Q1锂电池采购计划",
    "plan_period": {
      "start_date": "2025-01-01",
      "end_date": "2025-03-31"
    },
    "department": "采购部",
    "planner": "采购员A",
    "items": [
      {
        "product_id": 1001,
        "product_code": "BAT-18650-2500",
        "planned_quantity": 50000,
        "estimated_price": 25.00,
        "estimated_amount": 1250000,
        "required_date": "2025-02-15",
        "priority": "高",
        "purpose": "库存补充"
      }
    ],
    "total_amount": 1250000,
    "approval_flow": [
      {"level": 1, "approver": "部门经理", "status": "pending"},
      {"level": 2, "approver": "财务总监", "status": "pending"},
      {"level": 3, "approver": "总经理", "status": "pending"}
    ],
    "status": "draft"
  }
}
```

#### 2.2 提交采购计划审批
```http
POST /api/procurement/plans
Content-Type: application/json

{
  "action": "submit",
  "params": {
    "id": 2001
  },
  "data": {
    "submit_comment": "Q1季度库存不足，急需补充18650电池库存"
  }
}
```

#### 2.3 审批采购计划
```http
POST /api/procurement/plans
Content-Type: application/json

{
  "action": "approve",
  "params": {
    "id": 2001
  },
  "data": {
    "approval_level": 1,
    "approval_result": "approved",
    "approval_comment": "同意采购，注意控制成本",
    "approver": "部门经理"
  }
}
```

#### 2.4 创建采购订单
```http
POST /api/procurement/orders
Content-Type: application/json

{
  "action": "create",
  "data": {
    "order_code": "PO-2025-001",
    "plan_id": 2001,
    "supplier_id": 3001,
    "supplier_code": "SUP-CATL-001",
    "order_date": "2025-01-27",
    "expected_delivery_date": "2025-02-15",
    "delivery_address": "广东省深圳市宝安区新安街道海秀路1号深圳电池仓储中心",
    "items": [
      {
        "product_id": 1001,
        "product_code": "BAT-18650-2500",
        "quantity": 50000,
        "unit_price": 24.50,
        "amount": 1225000,
        "tax_rate": 0.13,
        "tax_amount": 159250,
        "total_amount": 1384250,
        "quality_requirements": {
          "capacity_tolerance": "±3%",
          "voltage_tolerance": "±0.05V",
          "defect_rate": "<0.1%",
          "packaging": "防静电包装"
        }
      }
    ],
    "total_amount": 1225000,
    "total_tax": 159250,
    "grand_total": 1384250,
    "payment_terms": "月结30天",
    "delivery_terms": "送货上门",
    "quality_terms": "按国标GB/T 31467执行",
    "contract_terms": "按采购合同执行",
    "buyer": "采购员A",
    "status": "draft"
  }
}
```

#### 2.5 发送采购订单
```http
POST /api/procurement/orders
Content-Type: application/json

{
  "action": "send",
  "params": {
    "id": 4001
  },
  "data": {
    "send_method": "email",
    "recipient_email": "zhang.manager@catl.com",
    "send_comment": "请确认订单并安排生产"
  }
}
```

### 第三步：入库流程

#### 3.1 供应商确认发货
```http
POST /api/procurement/orders
Content-Type: application/json

{
  "action": "confirm-shipment",
  "params": {
    "id": 4001
  },
  "data": {
    "shipment_info": {
      "shipment_date": "2025-02-10",
      "tracking_number": "SF1234567890",
      "carrier": "顺丰速运",
      "estimated_arrival": "2025-02-12",
      "packages": [
        {
          "package_no": "PKG-001",
          "product_code": "BAT-18650-2500",
          "quantity": 25000,
          "batch_no": "CATL-20250210-001"
        },
        {
          "package_no": "PKG-002",
          "product_code": "BAT-18650-2500",
          "quantity": 25000,
          "batch_no": "CATL-20250210-002"
        }
      ]
    }
  }
}
```

#### 3.2 创建入库单
```http
POST /api/inventory/inbound
Content-Type: application/json

{
  "action": "create",
  "data": {
    "inbound_code": "IN-2025-001",
    "inbound_type": "采购入库",
    "source_type": "purchase_order",
    "source_id": 4001,
    "source_code": "PO-2025-001",
    "warehouse_id": 5001,
    "warehouse_code": "WH-SZ-001",
    "supplier_id": 3001,
    "planned_date": "2025-02-12",
    "items": [
      {
        "product_id": 1001,
        "product_code": "BAT-18650-2500",
        "batch_no": "CATL-20250210-001",
        "production_date": "2025-02-08",
        "expire_date": "2030-02-08",
        "planned_quantity": 25000,
        "unit_price": 24.50,
        "location": "A01-001-001",
        "quality_status": "待检"
      },
      {
        "product_id": 1001,
        "product_code": "BAT-18650-2500",
        "batch_no": "CATL-20250210-002",
        "production_date": "2025-02-08",
        "expire_date": "2030-02-08",
        "planned_quantity": 25000,
        "unit_price": 24.50,
        "location": "A01-001-002",
        "quality_status": "待检"
      }
    ],
    "operator": "仓管员A",
    "status": "planned"
  }
}
```

#### 3.3 执行入库操作
```http
POST /api/inventory/inbound
Content-Type: application/json

{
  "action": "execute",
  "params": {
    "id": 6001
  },
  "data": {
    "actual_date": "2025-02-12T14:30:00Z",
    "items": [
      {
        "id": 60011,
        "actual_quantity": 25000,
        "actual_location": "A01-001-001",
        "condition": "良好",
        "notes": "包装完好，无破损"
      },
      {
        "id": 60012,
        "actual_quantity": 25000,
        "actual_location": "A01-001-002",
        "condition": "良好",
        "notes": "包装完好，无破损"
      }
    ],
    "operator": "仓管员A",
    "notes": "货物按时到达，包装完好，已安排质检"
  }
}
```

### 第四步：质量检验流程

#### 4.1 创建质检任务
```http
POST /api/quality/inspections
Content-Type: application/json

{
  "action": "create",
  "data": {
    "inspection_code": "QC-2025-001",
    "inspection_type": "入库检验",
    "source_type": "inbound",
    "source_id": 6001,
    "source_code": "IN-2025-001",
    "product_id": 1001,
    "product_code": "BAT-18650-2500",
    "batch_no": "CATL-20250210-001",
    "inspection_quantity": 500,
    "total_quantity": 25000,
    "sampling_method": "随机抽样",
    "inspection_standards": [
      "GB/T 31467-2015",
      "IEC 62133-2017",
      "UN38.3"
    ],
    "inspection_items": [
      {
        "item_name": "外观检查",
        "standard": "无破损、变形、漏液",
        "method": "目视检查",
        "sample_size": 500
      },
      {
        "item_name": "容量测试",
        "standard": "2500±75mAh",
        "method": "恒流充放电",
        "sample_size": 50
      },
      {
        "item_name": "电压测试",
        "standard": "3.7±0.05V",
        "method": "万用表测量",
        "sample_size": 50
      },
      {
        "item_name": "内阻测试",
        "standard": "≤50mΩ",
        "method": "内阻仪测量",
        "sample_size": 50
      }
    ],
    "inspector": "质检员A",
    "planned_date": "2025-02-13",
    "status": "planned"
  }
}
```

#### 4.2 执行质检并记录结果
```http
POST /api/quality/inspections
Content-Type: application/json

{
  "action": "execute",
  "params": {
    "id": 7001
  },
  "data": {
    "actual_date": "2025-02-13T09:00:00Z",
    "inspection_results": [
      {
        "item_name": "外观检查",
        "result": "合格",
        "actual_value": "无异常",
        "pass_quantity": 500,
        "fail_quantity": 0,
        "notes": "外观完好，无破损变形"
      },
      {
        "item_name": "容量测试",
        "result": "合格",
        "actual_value": "2485mAh",
        "pass_quantity": 48,
        "fail_quantity": 2,
        "notes": "平均容量2485mAh，2个样品略低于标准"
      },
      {
        "item_name": "电压测试",
        "result": "合格",
        "actual_value": "3.68V",
        "pass_quantity": 50,
        "fail_quantity": 0,
        "notes": "电压稳定，符合标准"
      },
      {
        "item_name": "内阻测试",
        "result": "合格",
        "actual_value": "42mΩ",
        "pass_quantity": 50,
        "fail_quantity": 0,
        "notes": "内阻正常"
      }
    ],
    "overall_result": "合格",
    "pass_rate": 99.6,
    "inspector": "质检员A",
    "reviewer": "质检主管B",
    "conclusion": "产品质量符合标准，允许入库",
    "recommendations": "建议加强容量一致性控制"
  }
}
```

#### 4.3 更新库存质量状态
```http
POST /api/inventory/stocks
Content-Type: application/json

{
  "action": "update-quality-status",
  "data": {
    "batch_no": "CATL-20250210-001",
    "quality_status": "合格",
    "inspection_id": 7001,
    "available_quantity": 25000,
    "operator": "质检员A"
  }
}
```

### 第五步：销售流程

#### 5.1 创建销售订单
```http
POST /api/sales/orders
Content-Type: application/json

{
  "action": "create",
  "data": {
    "order_code": "SO-2025-001",
    "customer_id": 8001,
    "customer_code": "CUS-BYD-001",
    "order_date": "2025-02-15",
    "delivery_date": "2025-02-20",
    "delivery_address": "广东省深圳市坪山区比亚迪路3009号",
    "items": [
      {
        "product_id": 1001,
        "product_code": "BAT-18650-2500",
        "quantity": 10000,
        "unit_price": 28.00,
        "amount": 280000,
        "tax_rate": 0.13,
        "tax_amount": 36400,
        "total_amount": 316400,
        "delivery_requirements": {
          "packaging": "防静电包装",
          "labeling": "按客户要求标识",
          "quality": "提供质检报告"
        }
      }
    ],
    "total_amount": 280000,
    "total_tax": 36400,
    "grand_total": 316400,
    "payment_terms": "月结45天",
    "delivery_terms": "送货上门",
    "salesperson": "销售员A",
    "status": "draft"
  }
}
```

#### 5.2 确认销售订单
```http
POST /api/sales/orders
Content-Type: application/json

{
  "action": "confirm",
  "params": {
    "id": 9001
  },
  "data": {
    "confirm_date": "2025-02-15T16:00:00Z",
    "confirmer": "销售经理",
    "confirm_comment": "订单确认，安排发货"
  }
}
```

### 第六步：出库流程

#### 6.1 创建出库单
```http
POST /api/inventory/outbound
Content-Type: application/json

{
  "action": "create",
  "data": {
    "outbound_code": "OUT-2025-001",
    "outbound_type": "销售出库",
    "source_type": "sales_order",
    "source_id": 9001,
    "source_code": "SO-2025-001",
    "warehouse_id": 5001,
    "warehouse_code": "WH-SZ-001",
    "customer_id": 8001,
    "planned_date": "2025-02-20",
    "items": [
      {
        "product_id": 1001,
        "product_code": "BAT-18650-2500",
        "batch_no": "CATL-20250210-001",
        "planned_quantity": 10000,
        "location": "A01-001-001",
        "unit_price": 28.00
      }
    ],
    "operator": "仓管员A",
    "status": "planned"
  }
}
```

#### 6.2 执行出库操作
```http
POST /api/inventory/outbound
Content-Type: application/json

{
  "action": "execute",
  "params": {
    "id": 10001
  },
  "data": {
    "actual_date": "2025-02-20T10:00:00Z",
    "items": [
      {
        "id": 100011,
        "actual_quantity": 10000,
        "actual_location": "A01-001-001",
        "condition": "良好",
        "packaging": "防静电包装箱，50个/箱，共200箱",
        "notes": "按客户要求包装标识"
      }
    ],
    "shipping_info": {
      "carrier": "德邦物流",
      "tracking_number": "DB1234567890",
      "estimated_delivery": "2025-02-21"
    },
    "operator": "仓管员A",
    "notes": "货物已发出，提供质检报告"
  }
}
```

### 第七步：安全管理

#### 7.1 危险品运输记录
```http
POST /api/safety/hazmat-transport
Content-Type: application/json

{
  "action": "create",
  "data": {
    "transport_code": "HT-2025-001",
    "outbound_id": 10001,
    "product_info": {
      "product_code": "BAT-18650-2500",
      "product_name": "18650锂离子电池",
      "quantity": 10000,
      "un_number": "UN3480",
      "class": "9类危险品",
      "packing_group": "II"
    },
    "transport_info": {
      "carrier": "德邦物流",
      "driver_name": "李师傅",
      "driver_license": "危险品运输证123456",
      "vehicle_no": "粤B12345",
      "route": "深圳-深圳坪山",
      "departure_time": "2025-02-20T10:30:00Z",
      "estimated_arrival": "2025-02-21T09:00:00Z"
    },
    "safety_measures": [
      "防火防爆包装",
      "温度监控",
      "防震措施",
      "应急工具包"
    ],
    "documents": [
      "危险品运输许可证",
      "MSDS安全数据表",
      "UN38.3测试报告",
      "包装合格证"
    ],
    "status": "in_transit"
  }
}
```

### 第八步：财务结算

#### 8.1 生成应收账款
```http
POST /api/finance/receivables
Content-Type: application/json

{
  "action": "create",
  "data": {
    "receivable_code": "AR-2025-001",
    "source_type": "sales_order",
    "source_id": 9001,
    "source_code": "SO-2025-001",
    "customer_id": 8001,
    "customer_code": "CUS-BYD-001",
    "invoice_date": "2025-02-20",
    "due_date": "2025-04-06",
    "amount": 316400,
    "tax_amount": 36400,
    "total_amount": 316400,
    "payment_terms": "月结45天",
    "status": "pending"
  }
}
```

### 第九步：报表统计

#### 9.1 生成业务报表
```http
POST /api/reports/business
Content-Type: application/json

{
  "action": "generate",
  "data": {
    "report_type": "monthly_summary",
    "period": {
      "start_date": "2025-02-01",
      "end_date": "2025-02-28"
    },
    "modules": [
      "procurement",
      "inventory",
      "sales",
      "quality",
      "finance"
    ],
    "format": "excel",
    "include_charts": true
  }
}
```

---

## 📊 业务流程监控

### 实时状态查询

#### 查询采购订单状态
```http
POST /api/procurement/orders
Content-Type: application/json

{
  "action": "detail",
  "params": {
    "id": 4001
  }
}
```

#### 查询库存状态
```http
POST /api/inventory/stocks
Content-Type: application/json

{
  "action": "list",
  "params": {
    "product_code": "BAT-18650-2500",
    "warehouse_code": "WH-SZ-001"
  }
}
```

#### 查询销售订单状态
```http
POST /api/sales/orders
Content-Type: application/json

{
  "action": "detail",
  "params": {
    "id": 9001
  }
}
```

---

## 🔧 错误处理示例

### 库存不足处理
```http
POST /api/sales/orders
Content-Type: application/json

{
  "action": "create",
  "data": {
    "order_code": "SO-2025-002",
    "customer_id": 8001,
    "items": [
      {
        "product_code": "BAT-18650-2500",
        "quantity": 100000  // 超出库存
      }
    ]
  }
}
```

**错误响应：**
```json
{
  "code": 400,
  "message": "库存不足",
  "data": {
    "error_type": "insufficient_stock",
    "product_code": "BAT-18650-2500",
    "requested_quantity": 100000,
    "available_quantity": 15000,
    "shortage": 85000
  },
  "timestamp": "2025-01-27T10:00:00Z"
}
```

### 质检不合格处理
```http
POST /api/quality/inspections
Content-Type: application/json

{
  "action": "execute",
  "params": {
    "id": 7002
  },
  "data": {
    "overall_result": "不合格",
    "fail_items": [
      {
        "item_name": "容量测试",
        "fail_reason": "容量低于标准",
        "fail_quantity": 1000
      }
    ],
    "disposition": "退货"
  }
}
```

---

## 📝 总结

本文档展示了新能源电池进销存系统的完整业务流程API调用示例，涵盖了从基础数据设置到完整业务链条的所有关键环节。通过这些示例，开发人员可以：

1. **理解业务流程**：掌握完整的业务操作流程
2. **学习API使用**：了解统一API设计模式的具体应用
3. **处理异常情况**：学会处理各种业务异常和错误
4. **集成系统**：为系统集成提供参考

**建议**：
- 在实际开发中，请根据具体业务需求调整参数
- 注意错误处理和异常情况的处理
- 遵循API文档中的数据格式和约束
- 进行充分的测试验证