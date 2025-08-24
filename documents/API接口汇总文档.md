# API接口汇总文档

## 📋 概述

本文档汇总了新能源电池进销存信息管理系统的所有API接口，按照模块分类整理。

**系统架构：**
- 前端：React + TypeScript + Vite + Material-UI
- 后端：NestJS + TypeScript + PostgreSQL 14+
- API设计：统一API设计模式，使用action参数区分操作

**文档版本：** v2.0  
**更新时间：** 2025-08-24  
**接口总数：** 约50个（整合后）

---

## 📊 模块概览

| 模块 | 原接口数量 | 整合后接口数量 | 状态 |
|------|------------|----------------|------|
| 01-基础数据管理 | 44个 | 3个 | ✅ 已完成 |
| 02-采购管理 | 40个 | 5个 | ✅ 已完成 |
| 03-库存管理 | 71个 | 7个 | ✅ 已完成 |
| 04-销售管理 | 66个 | 5个 | ✅ 已完成 |
| 05-质量控制 | 56个 | 4个 | ✅ 已完成 |
| 06-安全管理 | 66个 | 6个 | ✅ 已完成 |
| 07-报表统计 | 69个 | 5个 | ✅ 已完成 |
| 08-系统管理 | 91个 | 6个 | ✅ 已完成 |
| **总计** | **503个** | **41个** | **92%减少** |

---

## 🔧 通用规范

### 统一API设计模式
为了简化API设计，提高一致性，系统采用统一的接口设计模式：

**设计原则：**
- 每个业务模块使用一个统一的POST接口
- 通过 `action` 参数区分不同的操作类型
- 统一的请求和响应格式

**请求格式：**
```json
{
  "action": "操作类型",
  "params": {
    // 查询参数
  },
  "data": {
    // 业务数据
  }
}
```

**操作类型说明：**
- `list`: 获取列表数据
- `detail`: 获取详情数据
- `create`: 创建记录
- `update`: 更新记录
- `delete`: 删除记录
- `approve`: 审批操作
- `batch`: 批量操作
- `statistics`: 统计分析
- `export`: 数据导出
- 其他业务特定操作

**优势：**
- ✅ 减少接口数量，提高维护性
- ✅ 统一的错误处理和响应格式
- ✅ 便于前端统一调用
- ✅ 支持复杂的业务操作组合

### HTTP方法
- **GET**：查询操作（保留部分简单查询）
- **POST**：创建、更新、删除、状态变更等操作

### 响应格式
```json
{
  "code": 200,
  "message": "success",
  "data": {},
  "timestamp": "2025-08-24T10:00:00Z"
}
```

### 分页参数
```json
{
  "page": 1,
  "size": 20,
  "total": 100,
  "list": []
}
```

### 状态码
- 200：成功
- 400：请求参数错误
- 401：未授权
- 403：禁止访问
- 404：资源不存在
- 500：服务器内部错误

---

## 📁 模块详情

### 01-基础数据管理模块

#### 产品管理接口
| 方法 | 路径 | 描述 | 参数说明 |
|------|------|------|----------|
| POST | `/api/basic/products` | 产品管理统一接口 | `action`: create(创建)/list(列表)/detail(详情)/update(更新)/delete(删除)/batch-import(批量导入)/batch-export(批量导出)/batch-delete(批量删除)/validate-code(编码验证)/validate-model(型号验证)/enable(启用)/disable(停用)/discontinue(淘汰)/specs(技术参数)/update-specs(更新参数)/certifications(认证管理)/add-certification(添加认证)/remove-certification(移除认证)/statistics(统计)/report(报表) |

**Action字典说明：**
```typescript
type ProductAction = 
  // 基础CRUD操作
  | 'create'    // 创建产品
  | 'list'      // 查询产品列表
  | 'detail'    // 获取产品详情
  | 'update'    // 更新产品
  | 'delete'    // 删除产品
  
  // 批量操作
  | 'batch-import'  // 批量导入
  | 'batch-export'  // 批量导出
  | 'batch-delete'  // 批量删除
  
  // 验证操作
  | 'validate-code' // 产品编码验证
  | 'validate-model' // 型号重复验证
  
  // 状态管理
  | 'enable'    // 启用产品
  | 'disable'   // 停用产品
  | 'discontinue' // 淘汰产品
  
  // 技术参数管理
  | 'specs'     // 技术参数查询
  | 'update-specs' // 更新技术参数
  
  // 认证管理
  | 'certifications' // 认证信息管理
  | 'add-certification' // 添加认证
  | 'remove-certification' // 移除认证
  
  // 统计报表
  | 'statistics' // 产品统计
  | 'report'     // 生成报表
```

**不同action的请求示例：**
- **创建产品**: `{"action": "create", "data": {"product_name": "18650锂电池", "model": "18650-2500mAh", "battery_type": "锂离子", "capacity": 2500, "voltage": 3.7}}`
- **获取列表**: `{"action": "list", "params": {"page": 1, "size": 20, "battery_type": "锂离子", "status": "active"}}`
- **获取详情**: `{"action": "detail", "params": {"id": 123}}`
- **更新产品**: `{"action": "update", "params": {"id": 123}, "data": {...}}`
- **删除产品**: `{"action": "delete", "params": {"id": 123}}`
- **批量导入**: `{"action": "batch-import", "data": {"file": "base64编码的Excel文件", "template": "standard"}}`
- **批量导出**: `{"action": "batch-export", "params": {"format": "excel", "filters": {...}}}`
- **批量删除**: `{"action": "batch-delete", "data": {"ids": [1,2,3]}}`
- **编码验证**: `{"action": "validate-code", "data": {"product_code": "P001"}}`
- **型号验证**: `{"action": "validate-model", "data": {"model": "18650-2500mAh"}}`
- **启用产品**: `{"action": "enable", "params": {"id": 123}}`
- **停用产品**: `{"action": "disable", "params": {"id": 123}}`
- **淘汰产品**: `{"action": "discontinue", "params": {"id": 123}}`
- **技术参数**: `{"action": "specs", "params": {"id": 123}}`
- **更新参数**: `{"action": "update-specs", "params": {"id": 123}, "data": {"specifications": {...}}`
- **认证管理**: `{"action": "certifications", "params": {"id": 123}}`
- **添加认证**: `{"action": "add-certification", "params": {"id": 123}, "data": {"certification": {...}}`
- **移除认证**: `{"action": "remove-certification", "params": {"id": 123}, "data": {"certification_id": 456}}`
- **统计分析**: `{"action": "statistics", "params": {"type": "category"}}`
- **生成报表**: `{"action": "report", "data": {"report_type": "product_summary"}}`

#### 供应商管理接口
| 方法 | 路径 | 描述 | 参数说明 |
|------|------|------|----------|
| POST | `/api/basic/suppliers` | 供应商管理统一接口 | `action`: create(创建)/list(列表)/detail(详情)/update(更新)/delete(删除)/batch-import(批量导入)/batch-export(批量导出)/batch-delete(批量删除)/validate-code(编码验证)/validate-name(名称验证)/enable(启用)/disable(停用)/blacklist(黑名单)/qualifications(资质管理)/add-qualification(添加资质)/update-qualification(更新资质)/expire-qualification(资质过期)/evaluations(评估记录)/add-evaluation(添加评估)/update-rating(更新评级)/cooperation-history(合作历史)/update-level(更新等级)/statistics(统计)/report(报表) |

**Action字典说明：**
```typescript
type SupplierAction = 
  // 基础CRUD操作
  | 'create'    // 创建供应商
  | 'list'      // 查询供应商列表
  | 'detail'    // 获取供应商详情
  | 'update'    // 更新供应商
  | 'delete'    // 删除供应商
  
  // 批量操作
  | 'batch-import'  // 批量导入
  | 'batch-export'  // 批量导出
  | 'batch-delete'  // 批量删除
  
  // 验证操作
  | 'validate-code' // 供应商编码验证
  | 'validate-name' // 供应商名称验证
  
  // 状态管理
  | 'enable'    // 启用供应商
  | 'disable'   // 停用供应商
  | 'blacklist' // 加入黑名单
  
  // 资质管理
  | 'qualifications' // 资质信息管理
  | 'add-qualification' // 添加资质
  | 'update-qualification' // 更新资质
  | 'expire-qualification' // 资质过期处理
  
  // 评估管理
  | 'evaluations' // 评估记录查询
  | 'add-evaluation' // 添加评估
  | 'update-rating' // 更新评级
  
  // 合作管理
  | 'cooperation-history' // 合作历史
  | 'update-level' // 更新合作等级
  
  // 统计报表
  | 'statistics' // 供应商统计
  | 'report'     // 生成报表
```

**不同action的请求示例：**
- **创建供应商**: `{"action": "create", "data": {"supplier_name": "宁德时代新能源科技股份有限公司", "supplier_type": "制造商", "contact_info": {"address": "福建省宁德市", "contact_person": "张三", "phone": "0593-12345678"}}}`
- **获取列表**: `{"action": "list", "params": {"page": 1, "size": 20, "supplier_type": "制造商", "cooperation_level": "战略"}}`
- **获取详情**: `{"action": "detail", "params": {"id": 123}}`
- **更新供应商**: `{"action": "update", "params": {"id": 123}, "data": {...}}`
- **删除供应商**: `{"action": "delete", "params": {"id": 123}}`
- **批量导入**: `{"action": "batch-import", "data": {"file": "base64编码的Excel文件", "template": "standard"}}`
- **批量导出**: `{"action": "batch-export", "params": {"format": "excel", "filters": {...}}}`
- **批量删除**: `{"action": "batch-delete", "data": {"ids": [1,2,3]}}`
- **编码验证**: `{"action": "validate-code", "data": {"supplier_code": "S001"}}`
- **名称验证**: `{"action": "validate-name", "data": {"supplier_name": "宁德时代"}}`
- **启用供应商**: `{"action": "enable", "params": {"id": 123}}`
- **停用供应商**: `{"action": "disable", "params": {"id": 123}}`
- **加入黑名单**: `{"action": "blacklist", "params": {"id": 123}}`
- **资质管理**: `{"action": "qualifications", "params": {"id": 123}}`
- **添加资质**: `{"action": "add-qualification", "data": {"supplier_id": 123, "qualification_type": "ISO9001", "certificate_no": "ISO9001-2024-001", "issue_date": "2024-01-01", "expire_date": "2027-01-01"}}`
- **更新资质**: `{"action": "update-qualification", "params": {"id": 123}, "data": {...}}`
- **资质过期**: `{"action": "expire-qualification", "params": {"id": 123}}`
- **评估记录**: `{"action": "evaluations", "params": {"id": 123}}`
- **添加评估**: `{"action": "add-evaluation", "params": {"id": 123}, "data": {"evaluation": {...}}`
- **更新评级**: `{"action": "update-rating", "params": {"id": 123}, "data": {"rating": "AAA"}}`
- **合作历史**: `{"action": "cooperation-history", "params": {"id": 123}}`
- **更新等级**: `{"action": "update-level", "params": {"id": 123}, "data": {"level": "战略"}}`
- **统计分析**: `{"action": "statistics", "params": {"type": "performance"}}`
- **生成报表**: `{"action": "report", "data": {"report_type": "supplier_summary"}}`

#### 客户管理接口
| 方法 | 路径 | 描述 | 参数说明 |
|------|------|------|----------|
| POST | `/api/sales/customers` | 客户管理统一接口 | `action`: list(列表)/detail(详情)/create(创建)/update(更新)/delete(删除)/orders(订单历史)/returns(退换货历史)/credit(信用检查)/limit(信用额度)/analysis(信用分析)/risk(风险评估)/statistics(统计)/export(导出) |

**Action字典说明：**
```typescript
type CustomerAction = 
  | 'list'           // 获取客户列表
  | 'detail'         // 获取客户详情
  | 'create'         // 创建客户
  | 'update'         // 更新客户信息
  | 'delete'         // 删除客户
  | 'orders'         // 获取客户订单历史
  | 'returns'        // 获取客户退换货历史
  | 'credit'         // 客户信用检查
  | 'limit'          // 设置信用额度
  | 'analysis'       // 客户信用分析
  | 'risk'           // 客户风险评估
  | 'statistics'     // 客户统计分析
  | 'export'         // 客户数据导出
```

**不同action的请求示例：**
- **获取列表**: `{"action": "list", "params": {...}}`
- **获取详情**: `{"action": "detail", "params": {"id": 123}}`
- **创建客户**: `{"action": "create", "data": {...}}`
- **更新客户**: `{"action": "update", "params": {"id": 123}, "data": {...}}`
- **删除客户**: `{"action": "delete", "params": {"id": 123}}`
- **订单历史**: `{"action": "orders", "params": {"customer_id": 123}}`
- **退换货历史**: `{"action": "returns", "params": {"customer_id": 123}}`
- **信用检查**: `{"action": "credit", "params": {"customer_id": 123}}`
- **信用额度**: `{"action": "limit", "params": {"customer_id": 123}, "data": {"credit_limit": 100000}}`
- **信用分析**: `{"action": "analysis", "params": {"customer_id": 123}}`
- **风险评估**: `{"action": "risk", "params": {"customer_id": 123}}`
- **统计分析**: `{"action": "statistics", "params": {"type": "monthly"}}`
- **数据导出**: `{"action": "export", "params": {"format": "excel", "filters": {...}}}`

#### 仓库管理接口
| 方法 | 路径 | 描述 | 参数说明 |
|------|------|------|----------|
| POST | `/api/basic/warehouses` | 仓库管理统一接口 | `action`: create(创建)/list(列表)/detail(详情)/update(更新)/delete(删除)/batch-import(批量导入)/batch-export(批量导出)/batch-delete(批量删除)/validate-code(编码验证)/validate-name(名称验证)/enable(启用)/disable(停用)/maintenance(维护)/capacity-management(容量管理)/update-capacity(更新容量)/capacity-alert(容量预警)/safety-config(安全配置)/update-safety(更新安全)/safety-check(安全检查)/zones(库区管理)/add-zone(添加库区)/update-zone(更新库区)/statistics(统计)/report(报表) |

**Action字典说明：**
```typescript
type WarehouseAction = 
  // 基础CRUD操作
  | 'create'    // 创建仓库
  | 'list'      // 查询仓库列表
  | 'detail'    // 获取仓库详情
  | 'update'    // 更新仓库
  | 'delete'    // 删除仓库
  
  // 批量操作
  | 'batch-import'  // 批量导入
  | 'batch-export'  // 批量导出
  | 'batch-delete'  // 批量删除
  
  // 验证操作
  | 'validate-code' // 仓库编码验证
  | 'validate-name' // 仓库名称验证
  
  // 状态管理
  | 'enable'    // 启用仓库
  | 'disable'   // 停用仓库
  | 'maintenance' // 维护模式
  
  // 容量管理
  | 'capacity-management' // 容量管理
  | 'update-capacity' // 更新容量
  | 'capacity-alert' // 容量预警
  
  // 安全配置
  | 'safety-config' // 安全配置管理
  | 'update-safety' // 更新安全配置
  | 'safety-check' // 安全检查
  
  // 库区管理
  | 'zones'     // 库区管理
  | 'add-zone'  // 添加库区
  | 'update-zone' // 更新库区
  
  // 统计报表
  | 'statistics' // 仓库统计
  | 'report'     // 生成报表
```

**不同action的请求示例：**
- **创建仓库**: `{"action": "create", "data": {"warehouse_name": "深圳主仓库", "warehouse_type": "主仓", "address": "广东省深圳市宝安区", "specifications": {"area": 5000, "capacity": 10000}}}`
- **获取列表**: `{"action": "list", "params": {"page": 1, "size": 20, "warehouse_type": "主仓"}}`
- **获取详情**: `{"action": "detail", "params": {"id": 123}}`
- **更新仓库**: `{"action": "update", "params": {"id": 123}, "data": {...}}`
- **删除仓库**: `{"action": "delete", "params": {"id": 123}}`
- **批量导入**: `{"action": "batch-import", "data": {"file": "base64编码的Excel文件", "template": "standard"}}`
- **批量导出**: `{"action": "batch-export", "params": {"format": "excel", "filters": {...}}}`
- **批量删除**: `{"action": "batch-delete", "data": {"ids": [1,2,3]}}`
- **编码验证**: `{"action": "validate-code", "data": {"warehouse_code": "W001"}}`
- **名称验证**: `{"action": "validate-name", "data": {"warehouse_name": "深圳主仓库"}}`
- **启用仓库**: `{"action": "enable", "params": {"id": 123}}`
- **停用仓库**: `{"action": "disable", "params": {"id": 123}}`
- **维护模式**: `{"action": "maintenance", "params": {"id": 123}}`
- **容量管理**: `{"action": "capacity-management", "data": {"warehouse_id": 789, "current_usage": 7500, "alert_threshold": 8000}}`
- **更新容量**: `{"action": "update-capacity", "params": {"id": 123}, "data": {"capacity": 12000}}`
- **容量预警**: `{"action": "capacity-alert", "params": {"id": 123}}`
- **安全配置**: `{"action": "safety-config", "params": {"id": 123}}`
- **更新安全**: `{"action": "update-safety", "params": {"id": 123}, "data": {"safety_config": {...}}`
- **安全检查**: `{"action": "safety-check", "params": {"id": 123}}`
- **库区管理**: `{"action": "zones", "params": {"id": 123}}`
- **添加库区**: `{"action": "add-zone", "params": {"id": 123}, "data": {"zone_info": {...}}`
- **更新库区**: `{"action": "update-zone", "params": {"id": 123}, "data": {"zone_info": {...}}`
- **统计分析**: `{"action": "statistics", "params": {"type": "utilization"}}`
- **生成报表**: `{"action": "report", "data": {"report_type": "warehouse_summary"}}`

---

## 📝 更新日志

### v2.0 (2025-08-24)
- ✅ 完成API接口整合设计
- ✅ 实现统一接口模式，通过action参数区分操作
- ✅ 完成所有8个模块的接口整合
- ✅ 接口数量从503个减少到42个，减少92%以上
- ✅ 每个模块定义专属的action字典
- ✅ 统一的请求和响应格式
- ✅ 支持复杂的业务操作组合

### v1.0 (2025-08-24)
- ✅ 完成所有8个模块的API接口设计
- ✅ 统一HTTP方法为POST，通过action参数区分操作
- ✅ 简化路径结构和命名规范
- ✅ 整理所有模块的API接口汇总
- ✅ 完成503个接口的完整文档

---

### 02-采购管理模块

#### 采购计划接口
| 方法 | 路径 | 描述 | 参数说明 |
|------|------|------|----------|
| POST | `/api/procurement/plans` | 采购计划统一接口 | `action`: list(列表)/detail(详情)/create(创建)/update(更新)/delete(删除)/approve(审批)/batch(批量)/statistics(统计)/export(导出)/draft(草稿)/submit(提交)/reject(驳回)/copy(复制)/archive(归档) |

**Action字典说明：**
```typescript
type ProcurementPlanAction = 
  | 'list'           // 获取采购计划列表
  | 'detail'         // 获取采购计划详情
  | 'create'         // 创建采购计划
  | 'update'         // 更新采购计划
  | 'delete'         // 删除采购计划
  | 'approve'        // 审批采购计划
  | 'batch'          // 批量操作
  | 'statistics'     // 统计分析
  | 'export'         // 数据导出
  | 'draft'          // 保存草稿
  | 'submit'         // 提交审核
  | 'reject'         // 驳回计划
  | 'copy'           // 复制计划
  | 'archive'        // 归档计划
```

**接口参数示例：**
```json
{
  "action": "list",
  "params": {
    "page": 1,
    "size": 20,
    "status": "pending",
    "start_date": "2024-01-01",
    "end_date": "2024-12-31"
  }
}
```

**不同action的请求示例：**
- **获取列表**: `{"action": "list", "params": {...}}`
- **获取详情**: `{"action": "detail", "params": {"id": 123}}`
- **创建计划**: `{"action": "create", "data": {...}}`
- **更新计划**: `{"action": "update", "params": {"id": 123}, "data": {...}}`
- **删除计划**: `{"action": "delete", "params": {"id": 123}}`
- **审批计划**: `{"action": "approve", "params": {"id": 123}, "data": {"status": "approved", "comment": "..."}}`
- **批量操作**: `{"action": "batch", "data": {"ids": [1,2,3], "operation": "delete"}}`
- **统计分析**: `{"action": "statistics", "params": {"type": "monthly", "date_range": {...}}}`
- **数据导出**: `{"action": "export", "params": {"format": "excel", "filters": {...}}}`
- **保存草稿**: `{"action": "draft", "data": {...}}`
- **提交审核**: `{"action": "submit", "params": {"id": 123}}`
- **驳回计划**: `{"action": "reject", "params": {"id": 123}, "data": {"reason": "..."}}`
- **复制计划**: `{"action": "copy", "params": {"id": 123}}`
- **归档计划**: `{"action": "archive", "params": {"id": 123}}`

**响应格式统一：**
```json
{
  "code": 200,
  "message": "操作成功",
  "data": {
    // 根据action返回相应数据
  },
  "timestamp": "2024-01-01T00:00:00Z"
}
```

#### 供应商评估接口
| 方法 | 路径 | 描述 | 参数说明 |
|------|------|------|----------|
| POST | `/api/procurement/evaluations` | 供应商评估统一接口 | `action`: list(列表)/detail(详情)/create(创建)/update(更新)/performance(绩效)/history(历史)/reports(报告)/export(导出)/approve(审批)/trends(趋势)/compare(对比)/score(评分)/alert(预警) |

**Action字典说明：**
```typescript
type SupplierEvaluationAction = 
  | 'list'           // 获取供应商评估列表
  | 'detail'         // 获取评估详情
  | 'create'         // 创建供应商评估
  | 'update'         // 更新评估信息
  | 'performance'    // 获取供应商绩效
  | 'history'        // 评估历史记录
  | 'reports'        // 评估报告生成
  | 'export'         // 评估数据导出
  | 'approve'        // 评估审批
  | 'trends'         // 评估趋势分析
  | 'compare'        // 供应商对比分析
  | 'score'          // 评分计算
  | 'alert'          // 预警设置
```

**不同action的请求示例：**
- **获取列表**: `{"action": "list", "params": {...}}`
- **获取详情**: `{"action": "detail", "params": {"id": 123}}`
- **创建评估**: `{"action": "create", "data": {...}}`
- **更新评估**: `{"action": "update", "params": {"id": 123}, "data": {...}}`
- **获取绩效**: `{"action": "performance", "params": {"supplier_id": 123}}`
- **历史记录**: `{"action": "history", "params": {"supplier_id": 123}}`
- **生成报告**: `{"action": "reports", "data": {"type": "monthly", "supplier_ids": [1,2,3]}}`
- **数据导出**: `{"action": "export", "params": {"format": "excel", "filters": {...}}}`
- **评估审批**: `{"action": "approve", "params": {"id": 123}, "data": {"status": "approved"}}`
- **趋势分析**: `{"action": "trends", "params": {"supplier_id": 123, "period": "6months"}}`
- **供应商对比**: `{"action": "compare", "data": {"supplier_ids": [1,2,3], "metrics": ["quality", "delivery"]}}`
- **评分计算**: `{"action": "score", "params": {"supplier_id": 123}, "data": {"criteria": {...}}`
- **预警设置**: `{"action": "alert", "data": {"supplier_id": 123, "threshold": 0.8}}`

#### 采购订单接口
| 方法 | 路径 | 描述 | 参数说明 |
|------|------|------|----------|
| POST | `/api/procurement/orders` | 采购订单统一接口 | `action`: list(列表)/detail(详情)/create(创建)/update(更新)/delete(删除)/approve(审批)/tracking(跟踪)/items(明细)/status(状态)/batch(批量)/statistics(统计)/export(导出)/cancel(取消)/confirm(确认)/payment(付款) |

**Action字典说明：**
```typescript
type PurchaseOrderAction = 
  | 'list'           // 获取采购订单列表
  | 'detail'         // 获取采购订单详情
  | 'create'         // 创建采购订单
  | 'update'         // 更新采购订单
  | 'delete'         // 删除采购订单
  | 'approve'        // 审批采购订单
  | 'tracking'       // 订单跟踪
  | 'items'          // 采购订单明细
  | 'status'         // 订单状态变更
  | 'batch'          // 批量操作
  | 'statistics'     // 订单统计分析
  | 'export'         // 订单数据导出
  | 'cancel'         // 取消订单
  | 'confirm'        // 确认收货
  | 'payment'        // 付款管理
```

**不同action的请求示例：**
- **获取列表**: `{"action": "list", "params": {...}}`
- **获取详情**: `{"action": "detail", "params": {"id": 123}}`
- **创建订单**: `{"action": "create", "data": {...}}`
- **更新订单**: `{"action": "update", "params": {"id": 123}, "data": {...}}`
- **删除订单**: `{"action": "delete", "params": {"id": 123}}`
- **审批订单**: `{"action": "approve", "params": {"id": 123}, "data": {"status": "approved"}}`
- **订单跟踪**: `{"action": "tracking", "params": {"id": 123}}`
- **明细查询**: `{"action": "items", "params": {"id": 123}}`
- **明细更新**: `{"action": "items", "params": {"id": 123, "item_id": 456}, "data": {...}}`
- **状态变更**: `{"action": "status", "params": {"id": 123}, "data": {"status": "shipped"}}`
- **批量操作**: `{"action": "batch", "data": {"ids": [1,2,3], "operation": "approve"}}`
- **统计分析**: `{"action": "statistics", "params": {"type": "monthly"}}`
- **数据导出**: `{"action": "export", "params": {"format": "excel", "filters": {...}}}`
- **取消订单**: `{"action": "cancel", "params": {"id": 123}, "data": {"reason": "..."}}`
- **确认收货**: `{"action": "confirm", "params": {"id": 123}, "data": {"receipt_data": {...}}`
- **付款管理**: `{"action": "payment", "params": {"id": 123}, "data": {"payment_info": {...}}`

#### 收货验收接口
| 方法 | 路径 | 描述 | 参数说明 |
|------|------|------|----------|
| POST | `/api/procurement/receiving` | 收货验收统一接口 | `action`: list(列表)/detail(详情)/create(创建)/update(更新)/inspect(检验)/items(明细)/status(状态)/exceptions(异常)/statistics(统计) |

**不同action的请求示例：**
- **获取列表**: `{"action": "list", "params": {...}}`
- **获取详情**: `{"action": "detail", "params": {"id": 123}}`
- **创建收货**: `{"action": "create", "data": {...}}`
- **更新收货**: `{"action": "update", "params": {"id": 123}, "data": {...}}`
- **质量检验**: `{"action": "inspect", "params": {"id": 123}, "data": {"inspection_result": {...}}}`
- **明细查询**: `{"action": "items", "params": {"id": 123}}`
- **明细更新**: `{"action": "items", "params": {"id": 123, "item_id": 456}, "data": {...}}`
- **状态变更**: `{"action": "status", "params": {"id": 123}, "data": {"status": "completed"}}`
- **异常处理**: `{"action": "exceptions", "params": {"id": 123}, "data": {"exception_type": "quality", "description": "..."}}`
- **统计分析**: `{"action": "statistics", "params": {"type": "monthly"}}`

#### 价格管理接口
| 方法 | 路径 | 描述 | 参数说明 |
|------|------|------|----------|
| POST | `/api/procurement/prices` | 价格管理统一接口 | `action`: history(历史)/trends(趋势)/comparison(对比)/approval(审批)/statistics(统计)/export(导出) |

**不同action的请求示例：**
- **价格历史**: `{"action": "history", "params": {"product_id": 123, "period": "1year"}}`
- **价格趋势**: `{"action": "trends", "params": {"product_id": 123, "analysis_type": "monthly"}}`
- **价格对比**: `{"action": "comparison", "data": {"suppliers": [1,2,3], "product_id": 123}}`
- **价格审批**: `{"action": "approval", "data": {"price_change": {...}, "approver": "user123"}}`
- **统计分析**: `{"action": "statistics", "params": {"type": "cost_analysis"}}`
- **数据导出**: `{"action": "export", "params": {"format": "excel", "filters": {...}}}`

---

### 03-库存管理模块

#### 库存查询接口
| 方法 | 路径 | 描述 | 参数说明 |
|------|------|------|----------|
| POST | `/api/inventory/stock` | 库存查询统一接口 | `action`: list(列表)/detail(详情)/query(查询)/alerts(预警)/expiring(过期)/statistics(统计)/export(导出)/movement(移动)/aging(库存龄)/abc(ABC分析)/forecast(预测)/optimization(优化) |

**Action字典说明：**
```typescript
type InventoryStockAction = 
  | 'list'           // 获取库存列表
  | 'detail'         // 获取库存详情
  | 'query'          // 条件查询库存
  | 'alerts'         // 库存预警信息
  | 'expiring'       // 即将过期库存
  | 'statistics'     // 库存统计分析
  | 'export'         // 库存数据导出
  | 'movement'       // 库存移动记录
  | 'aging'          // 库存龄分析
  | 'abc'            // ABC分类分析
  | 'forecast'       // 库存预测
  | 'optimization'   // 库存优化建议
```

**不同action的请求示例：**
- **获取列表**: `{"action": "list", "params": {"page": 1, "size": 20}}`
- **获取详情**: `{"action": "detail", "params": {"id": 123}}`
- **按条件查询**: `{"action": "query", "params": {"product_id": 123, "warehouse_id": 456}}`
- **库存预警**: `{"action": "alerts", "params": {"alert_type": "low_stock"}}`
- **即将过期**: `{"action": "expiring", "params": {"days": 30}}`
- **统计分析**: `{"action": "statistics", "params": {"type": "warehouse_summary"}}`
- **数据导出**: `{"action": "export", "params": {"format": "excel", "filters": {...}}}`
- **库存移动**: `{"action": "movement", "params": {"product_id": 123, "date_range": {...}}`
- **库存龄分析**: `{"action": "aging", "params": {"warehouse_id": 456}}`
- **ABC分析**: `{"action": "abc", "params": {"warehouse_id": 456, "period": "monthly"}}`
- **库存预测**: `{"action": "forecast", "params": {"product_id": 123, "period": "3months"}}`
- **库存优化**: `{"action": "optimization", "params": {"warehouse_id": 456}}`

#### 库存预留管理接口
| 方法 | 路径 | 描述 | 参数说明 |
|------|------|------|----------|
| POST | `/api/inventory/reservations` | 库存预留统一接口 | `action`: list(列表)/detail(详情)/create(创建)/update(更新)/delete(删除)/details(详情查询)/priority(优先级)/conflicts(冲突检测)/batch(批量)/statistics(统计)/export(导出) |

**不同action的请求示例：**
- **获取列表**: `{"action": "list", "params": {...}}`
- **获取详情**: `{"action": "detail", "params": {"id": 123}}`
- **创建预留**: `{"action": "create", "data": {...}}`
- **更新预留**: `{"action": "update", "params": {"id": 123}, "data": {...}}`
- **取消预留**: `{"action": "delete", "params": {"id": 123}}`
- **详情查询**: `{"action": "details", "params": {"id": 123}}`
- **优先级管理**: `{"action": "priority", "params": {"id": 123}, "data": {"priority": "high"}}`
- **冲突检测**: `{"action": "conflicts", "params": {"reservation_id": 123}}`
- **批量操作**: `{"action": "batch", "data": {"ids": [1,2,3], "operation": "cancel"}}`
- **统计分析**: `{"action": "statistics", "params": {"type": "monthly"}}`
- **数据导出**: `{"action": "export", "params": {"format": "excel", "filters": {...}}}`

#### 批次管理接口
| 方法 | 路径 | 描述 | 参数说明 |
|------|------|------|----------|
| POST | `/api/inventory/batches` | 批次管理统一接口 | `action`: list(列表)/detail(详情)/create(创建)/update(更新)/trace(追溯)/merge(合并)/expiring(过期)/quality(质量检查)/statistics(统计)/export(导出) |

**不同action的请求示例：**
- **获取列表**: `{"action": "list", "params": {...}}`
- **获取详情**: `{"action": "detail", "params": {"id": 123}}`
- **创建批次**: `{"action": "create", "data": {...}}`
- **更新批次**: `{"action": "update", "params": {"id": 123}, "data": {...}}`
- **批次追溯**: `{"action": "trace", "params": {"id": 123}}`
- **批次合并**: `{"action": "merge", "data": {"batch_ids": [1,2,3]}}`
- **即将过期**: `{"action": "expiring", "params": {"days": 30}}`
- **质量检查**: `{"action": "quality", "params": {"id": 123}, "data": {"check_result": {...}}}`
- **统计分析**: `{"action": "statistics", "params": {"type": "batch_summary"}}`
- **数据导出**: `{"action": "export", "params": {"format": "excel", "filters": {...}}}`

#### 库位管理接口
| 方法 | 路径 | 描述 | 参数说明 |
|------|------|------|----------|
| POST | `/api/inventory/locations` | 库位管理统一接口 | `action`: list(列表)/detail(详情)/create(创建)/update(更新)/delete(删除)/allocate(分配)/optimization(优化)/reserve(预留)/usage(使用统计)/clean(清理)/heatmap(热力图) |

**不同action的请求示例：**
- **获取列表**: `{"action": "list", "params": {...}}`
- **获取详情**: `{"action": "detail", "params": {"id": 123}}`
- **创建库位**: `{"action": "create", "data": {...}}`
- **更新库位**: `{"action": "update", "params": {"id": 123}, "data": {...}}`
- **删除库位**: `{"action": "delete", "params": {"id": 123}}`
- **自动分配**: `{"action": "allocate", "data": {"product_id": 123, "quantity": 100}}`
- **优化建议**: `{"action": "optimization", "params": {"warehouse_id": 456}}`
- **库位预留**: `{"action": "reserve", "data": {"location_id": 123, "reservation_data": {...}}}`
- **使用统计**: `{"action": "usage", "params": {"warehouse_id": 456}}`
- **库位清理**: `{"action": "clean", "params": {"location_id": 123}}`
- **热力图**: `{"action": "heatmap", "params": {"warehouse_id": 456}}`

#### 库存调拨接口
| 方法 | 路径 | 描述 | 参数说明 |
|------|------|------|----------|
| POST | `/api/inventory/transfers` | 库存调拨统一接口 | `action`: list(列表)/detail(详情)/create(创建)/update(更新)/delete(删除)/approve(审批)/execute(执行)/tracking(跟踪)/statistics(统计)/export(导出) |

**不同action的请求示例：**
- **获取列表**: `{"action": "list", "params": {...}}`
- **获取详情**: `{"action": "detail", "params": {"id": 123}}`
- **创建调拨**: `{"action": "create", "data": {...}}`
- **更新调拨**: `{"action": "update", "params": {"id": 123}, "data": {...}}`
- **删除调拨**: `{"action": "delete", "params": {"id": 123}}`
- **审批调拨**: `{"action": "approve", "params": {"id": 123}, "data": {"status": "approved"}}`
- **执行调拨**: `{"action": "execute", "params": {"id": 123}}`
- **调拨跟踪**: `{"action": "tracking", "params": {"id": 123}}`
- **统计分析**: `{"action": "statistics", "params": {"type": "monthly"}}`
- **数据导出**: `{"action": "export", "params": {"format": "excel", "filters": {...}}}`

#### 盘点管理接口
| 方法 | 路径 | 描述 | 参数说明 |
|------|------|------|----------|
| POST | `/api/inventory/stock-counts` | 盘点管理统一接口 | `action`: list(列表)/detail(详情)/create(创建)/update(更新)/delete(删除)/status(状态)/adjust(调整)/differences(差异)/statistics(统计)/export(导出) |

**不同action的请求示例：**
- **获取列表**: `{"action": "list", "params": {...}}`
- **获取详情**: `{"action": "detail", "params": {"id": 123}}`
- **创建盘点**: `{"action": "create", "data": {...}}`
- **更新盘点**: `{"action": "update", "params": {"id": 123}, "data": {...}}`
- **删除盘点**: `{"action": "delete", "params": {"id": 123}}`
- **状态变更**: `{"action": "status", "params": {"id": 123}, "data": {"status": "completed"}}`
- **盘点调整**: `{"action": "adjust", "params": {"id": 123}, "data": {"adjustments": [...]]}}`
- **盘点差异**: `{"action": "differences", "params": {"id": 123}}`
- **统计分析**: `{"action": "statistics", "params": {"type": "monthly"}}`
- **数据导出**: `{"action": "export", "params": {"format": "excel", "filters": {...}}}`

#### 库存流水接口
| 方法 | 路径 | 描述 | 参数说明 |
|------|------|------|----------|
| POST | `/api/inventory/transactions` | 库存流水统一接口 | `action`: list(列表)/detail(详情)/create(创建)/query(查询)/statistics(统计)/export(导出) |

**不同action的请求示例：**
- **获取列表**: `{"action": "list", "params": {...}}`
- **获取详情**: `{"action": "detail", "params": {"id": 123}}`
- **创建流水**: `{"action": "create", "data": {...}}`
- **条件查询**: `{"action": "query", "params": {"product_id": 123, "transaction_type": "in"}}`
- **统计分析**: `{"action": "statistics", "params": {"type": "daily_summary"}}`
- **数据导出**: `{"action": "export", "params": {"format": "excel", "filters": {...}}}`

---

### 04-销售管理模块

#### 销售订单接口
| 方法 | 路径 | 描述 | 参数说明 |
|------|------|------|----------|
| POST | `/api/sales/orders` | 销售订单统一接口 | `action`: list(列表)/detail(详情)/create(创建)/update(更新)/delete(删除)/approve(审批)/cancel(取消)/tracking(跟踪)/items(明细)/status(状态)/batch(批量)/statistics(统计)/export(导出)/ship(发货)/deliver(配送)/return(退货)/refund(退款)/invoice(发票)/payment(收款) |

**Action字典说明：**
```typescript
type SalesOrderAction = 
  | 'list'           // 获取销售订单列表
  | 'detail'         // 获取销售订单详情
  | 'create'         // 创建销售订单
  | 'update'         // 更新销售订单
  | 'delete'         // 删除销售订单
  | 'approve'        // 审批销售订单
  | 'cancel'         // 取消销售订单
  | 'tracking'       // 订单跟踪
  | 'items'          // 订单明细管理
  | 'status'         // 订单状态变更
  | 'batch'          // 批量操作
  | 'statistics'     // 订单统计分析
  | 'export'         // 订单数据导出
  | 'ship'           // 发货处理
  | 'deliver'        // 配送管理
  | 'return'         // 退货处理
  | 'refund'         // 退款处理
  | 'invoice'        // 发票管理
  | 'payment'        // 收款管理
```

**不同action的请求示例：**
- **获取列表**: `{"action": "list", "params": {...}}`
- **获取详情**: `{"action": "detail", "params": {"id": 123}}`
- **创建订单**: `{"action": "create", "data": {...}}`
- **更新订单**: `{"action": "update", "params": {"id": 123}, "data": {...}}`
- **删除订单**: `{"action": "delete", "params": {"id": 123}}`
- **审批订单**: `{"action": "approve", "params": {"id": 123}, "data": {"status": "approved"}}`
- **取消订单**: `{"action": "cancel", "params": {"id": 123}, "data": {"reason": "..."}}`
- **订单跟踪**: `{"action": "tracking", "params": {"id": 123}}`
- **明细查询**: `{"action": "items", "params": {"id": 123}}`
- **明细更新**: `{"action": "items", "params": {"id": 123, "item_id": 456}, "data": {...}}`
- **状态变更**: `{"action": "status", "params": {"id": 123}, "data": {"status": "shipped"}}`
- **批量操作**: `{"action": "batch", "data": {"ids": [1,2,3], "operation": "approve"}}`
- **统计分析**: `{"action": "statistics", "params": {"type": "monthly"}}`
- **数据导出**: `{"action": "export", "params": {"format": "excel", "filters": {...}}}`
- **发货处理**: `{"action": "ship", "params": {"id": 123}, "data": {"shipping_info": {...}}`
- **配送管理**: `{"action": "deliver", "params": {"id": 123}, "data": {"delivery_info": {...}}`
- **退货处理**: `{"action": "return", "params": {"id": 123}, "data": {"return_info": {...}}`
- **退款处理**: `{"action": "refund", "params": {"id": 123}, "data": {"refund_info": {...}}`
- **发票管理**: `{"action": "invoice", "params": {"id": 123}, "data": {"invoice_info": {...}}`
- **收款管理**: `{"action": "payment", "params": {"id": 123}, "data": {"payment_info": {...}}`

#### 出库管理接口
| 方法 | 路径 | 描述 | 参数说明 |
|------|------|------|----------|
| POST | `/api/sales/deliveries` | 出库管理统一接口 | `action`: list(列表)/detail(详情)/create(创建)/update(更新)/delete(删除)/approve(审批)/execute(执行)/items(明细)/pick(拣货)/pack(包装)/tracking(物流跟踪)/exceptions(异常)/statistics(统计)/export(导出) |

**Action字典说明：**
```typescript
type DeliveryAction = 
  | 'list'           // 获取出库单列表
  | 'detail'         // 获取出库单详情
  | 'create'         // 创建出库单
  | 'update'         // 更新出库单
  | 'delete'         // 删除出库单
  | 'approve'        // 审批出库单
  | 'execute'        // 执行出库
  | 'items'          // 出库明细管理
  | 'pick'           // 拣货计划
  | 'pack'           // 包装管理
  | 'tracking'       // 物流跟踪
  | 'exceptions'     // 异常处理
  | 'statistics'     // 出库统计分析
  | 'export'         // 出库数据导出
```

**不同action的请求示例：**
- **获取列表**: `{"action": "list", "params": {...}}`
- **获取详情**: `{"action": "detail", "params": {"id": 123}}`
- **创建出库**: `{"action": "create", "data": {...}}`
- **更新出库**: `{"action": "update", "params": {"id": 123}, "data": {...}}`
- **删除出库**: `{"action": "delete", "params": {"id": 123}}`
- **审批出库**: `{"action": "approve", "params": {"id": 123}, "data": {"status": "approved"}}`
- **执行出库**: `{"action": "execute", "params": {"id": 123}}`
- **明细查询**: `{"action": "items", "params": {"id": 123}}`
- **拣货计划**: `{"action": "pick", "params": {"id": 123}, "data": {"picking_plan": {...}}`
- **包装管理**: `{"action": "pack", "params": {"id": 123}, "data": {"packing_info": {...}}`
- **物流跟踪**: `{"action": "tracking", "params": {"id": 123}}`
- **异常处理**: `{"action": "exceptions", "params": {"id": 123}, "data": {"exception_type": "delay", "description": "..."}}`
- **统计分析**: `{"action": "statistics", "params": {"type": "monthly"}}`
- **数据导出**: `{"action": "export", "params": {"format": "excel", "filters": {...}}}`

#### 退换货管理接口
| 方法 | 路径 | 描述 | 参数说明 |
|------|------|------|----------|
| POST | `/api/sales/returns` | 退换货管理统一接口 | `action`: list(列表)/detail(详情)/create(创建)/update(更新)/delete(删除)/approve(审批)/status(状态)/details(详情)/inspection(质量检验)/refund(退款处理)/analysis(原因分析)/prevention(预防措施)/statistics(统计)/export(导出) |

**Action字典说明：**
```typescript
type ReturnAction = 
  | 'list'           // 获取退换货单列表
  | 'detail'         // 获取退换货单详情
  | 'create'         // 创建退换货单
  | 'update'         // 更新退换货单
  | 'delete'         // 删除退换货单
  | 'approve'        // 审批退换货单
  | 'status'         // 处理退换货
  | 'details'        // 退换货详情
  | 'inspection'     // 退货质量检验
  | 'refund'         // 退款处理
  | 'analysis'       // 退货原因分析
  | 'prevention'     // 预防措施
  | 'statistics'     // 退换货统计分析
  | 'export'         // 退换货数据导出
```

**不同action的请求示例：**
- **获取列表**: `{"action": "list", "params": {...}}`
- **获取详情**: `{"action": "detail", "params": {"id": 123}}`
- **创建退换货**: `{"action": "create", "data": {...}}`
- **更新退换货**: `{"action": "update", "params": {"id": 123}, "data": {...}}`
- **删除退换货**: `{"action": "delete", "params": {"id": 123}}`
- **审批退换货**: `{"action": "approve", "params": {"id": 123}, "data": {"status": "approved"}}`
- **处理退换货**: `{"action": "status", "params": {"id": 123}, "data": {"status": "processing"}}`
- **详情查询**: `{"action": "details", "params": {"id": 123}}`
- **质量检验**: `{"action": "inspection", "params": {"id": 123}, "data": {"inspection_result": {...}}`
- **退款处理**: `{"action": "refund", "params": {"id": 123}, "data": {"refund_info": {...}}`
- **原因分析**: `{"action": "analysis", "params": {"id": 123}}`
- **预防措施**: `{"action": "prevention", "params": {"id": 123}, "data": {"measures": {...}}`
- **统计分析**: `{"action": "statistics", "params": {"type": "monthly"}}`
- **数据导出**: `{"action": "export", "params": {"format": "excel", "filters": {...}}}`

#### 客户管理接口
| 方法 | 路径 | 描述 |
|------|------|------|
| GET | `/api/sales/customers` | 获取客户列表 |
| GET | `/api/sales/customers/:id` | 获取客户详情 |
| POST | `/api/sales/customers` | 创建客户 |
| POST | `/api/sales/customers/:id` | 更新客户信息 |
| POST | `/api/sales/customers/:id/delete` | 删除客户 |
| GET | `/api/sales/customers/:id/orders` | 获取客户订单历史 |
| GET | `/api/sales/customers/:id/returns` | 获取客户退换货历史 |
| POST | `/api/sales/customers/:id/credit-check` | 客户信用检查 |
| POST | `/api/sales/customers/:id/credit-limit` | 设置信用额度 |
| GET | `/api/sales/customers/credit-analysis` | 客户信用分析 |
| POST | `/api/sales/customers/risk-assessment` | 客户风险评估 |
| GET | `/api/sales/customers/statistics` | 客户统计分析 |
| POST | `/api/sales/customers/export` | 客户数据导出 |

#### 客户回访接口
| 方法 | 路径 | 描述 | 参数说明 |
|------|------|------|----------|
| POST | `/api/sales/visits` | 客户回访统一接口 | `action`: list(列表)/detail(详情)/create(创建)/update(更新)/delete(删除)/history(回访历史)/schedule(安排计划)/reminder(发送提醒)/feedback(反馈分析)/statistics(统计)/export(导出) |

**Action字典说明：**
```typescript
type CustomerVisitAction = 
  | 'list'           // 获取客户回访列表
  | 'detail'         // 获取回访详情
  | 'create'         // 创建客户回访
  | 'update'         // 更新回访信息
  | 'delete'         // 删除回访记录
  | 'history'        // 获取客户回访历史
  | 'schedule'       // 安排回访计划
  | 'reminder'       // 发送回访提醒
  | 'feedback'       // 回访反馈分析
  | 'statistics'     // 回访统计分析
  | 'export'         // 回访数据导出
```

**不同action的请求示例：**
- **获取列表**: `{"action": "list", "params": {...}}`
- **获取详情**: `{"action": "detail", "params": {"id": 123}}`
- **创建回访**: `{"action": "create", "data": {...}}`
- **更新回访**: `{"action": "update", "params": {"id": 123}, "data": {...}}`
- **删除回访**: `{"action": "delete", "params": {"id": 123}}`
- **回访历史**: `{"action": "history", "params": {"customer_id": 123}}`
- **安排计划**: `{"action": "schedule", "data": {"customer_id": 123, "visit_date": "2024-01-15"}}`
- **发送提醒**: `{"action": "reminder", "params": {"visit_id": 123}}`
- **反馈分析**: `{"action": "feedback", "params": {"customer_id": 123}}`
- **统计分析**: `{"action": "statistics", "params": {"type": "monthly"}}`
- **数据导出**: `{"action": "export", "params": {"format": "excel", "filters": {...}}}`

---

### 05-质量控制模块

#### 质量检验接口
| 方法 | 路径 | 描述 | 参数说明 |
|------|------|------|----------|
| POST | `/api/quality/inspections` | 质量检验统一接口 | `action`: list(列表)/detail(详情)/create(创建)/update(更新)/delete(删除)/approve(审批)/query(条件查询)/statistics(统计)/export(导出)/execute(执行检验)/result(检验结果)/reject(不合格处理)/retest(复检处理)/certificate(证书管理)/standard(标准管理)/alert(质量预警)/trend(质量趋势) |

**Action字典说明：**
```typescript
type QualityInspectionAction = 
  | 'list'           // 获取质量检验列表
  | 'detail'         // 获取检验详情
  | 'create'         // 创建质量检验
  | 'update'         // 更新检验信息
  | 'delete'         // 删除检验记录
  | 'approve'        // 审批检验结果
  | 'query'          // 条件查询检验
  | 'statistics'     // 检验统计分析
  | 'export'         // 检验数据导出
  | 'execute'        // 执行检验
  | 'result'         // 检验结果
  | 'reject'         // 不合格处理
  | 'retest'         // 复检处理
  | 'certificate'    // 证书管理
  | 'standard'       // 标准管理
  | 'alert'          // 质量预警
  | 'trend'          // 质量趋势
```

**不同action的请求示例：**
- **获取列表**: `{"action": "list", "params": {...}}`
- **获取详情**: `{"action": "detail", "params": {"id": 123}}`
- **创建检验**: `{"action": "create", "data": {...}}`
- **更新检验**: `{"action": "update", "params": {"id": 123}, "data": {...}}`
- **删除检验**: `{"action": "delete", "params": {"id": 123}}`
- **审批结果**: `{"action": "approve", "params": {"id": 123}, "data": {"status": "approved"}}`
- **条件查询**: `{"action": "query", "params": {"product_id": 123, "batch_number": "B001"}}`
- **统计分析**: `{"action": "statistics", "params": {"type": "monthly"}}`
- **数据导出**: `{"action": "export", "params": {"format": "excel", "filters": {...}}}`
- **执行检验**: `{"action": "execute", "params": {"id": 123}}`
- **检验结果**: `{"action": "result", "params": {"id": 123}, "data": {"result": {...}}`
- **不合格处理**: `{"action": "reject", "params": {"id": 123}, "data": {"rejection_reason": "..."}}`
- **复检处理**: `{"action": "retest", "params": {"id": 123}}`
- **证书管理**: `{"action": "certificate", "params": {"id": 123}, "data": {"certificate_info": {...}}`
- **标准管理**: `{"action": "standard", "params": {"product_id": 123}}`
- **质量预警**: `{"action": "alert", "params": {"product_id": 123}}`
- **质量趋势**: `{"action": "trend", "params": {"product_id": 123, "period": "6months"}}`

#### 批次追溯接口
| 方法 | 路径 | 描述 | 参数说明 |
|------|------|------|----------|
| POST | `/api/quality/batches` | 批次追溯统一接口 | `action`: list(列表)/detail(详情)/create(创建)/update(更新)/trace(追溯查询)/upstream(上游追溯)/downstream(下游追溯)/flow(流转轨迹)/quality(质量记录)/merge(批次合并)/statistics(统计)/export(导出) |

**Action字典说明：**
```typescript
type BatchTraceAction = 
  | 'list'           // 获取批次追溯列表
  | 'detail'         // 获取批次详情
  | 'create'         // 创建批次追溯记录
  | 'update'         // 更新批次信息
  | 'trace'          // 批次追溯查询
  | 'upstream'       // 上游追溯查询
  | 'downstream'     // 下游追溯查询
  | 'flow'           // 流转轨迹查询
  | 'quality'        // 质量记录查询
  | 'merge'          // 批次合并
  | 'statistics'     // 批次统计分析
  | 'export'         // 批次数据导出
```

**不同action的请求示例：**
- **获取列表**: `{"action": "list", "params": {...}}`
- **获取详情**: `{"action": "detail", "params": {"id": 123}}`
- **创建追溯**: `{"action": "create", "data": {...}}`
- **更新批次**: `{"action": "update", "params": {"id": 123}, "data": {...}}`
- **追溯查询**: `{"action": "trace", "params": {"id": 123}}`
- **上游追溯**: `{"action": "upstream", "params": {"id": 123}}`
- **下游追溯**: `{"action": "downstream", "params": {"id": 123}}`
- **流转轨迹**: `{"action": "flow", "params": {"id": 123}}`
- **质量记录**: `{"action": "quality", "params": {"id": 123}}`
- **批次合并**: `{"action": "merge", "data": {"batch_ids": [1,2,3]}}`
- **统计分析**: `{"action": "statistics", "params": {"type": "batch_summary"}}`
- **数据导出**: `{"action": "export", "params": {"format": "excel", "filters": {...}}}`

#### 不合格品处理接口
| 方法 | 路径 | 描述 | 参数说明 |
|------|------|------|----------|
| POST | `/api/quality/defective` | 不合格品处理统一接口 | `action`: list(列表)/detail(详情)/create(创建)/update(更新)/delete(删除)/isolation(隔离)/disposal(处置)/cost(成本分析)/actions(纠正措施)/prevention(预防措施)/statistics(统计)/export(导出) |

**Action字典说明：**
```typescript
type DefectiveAction = 
  | 'list'           // 获取不合格品列表
  | 'detail'         // 获取不合格品详情
  | 'create'         // 创建不合格品记录
  | 'update'         // 更新不合格品信息
  | 'delete'         // 删除不合格品记录
  | 'isolation'      // 不合格品隔离
  | 'disposal'       // 不合格品处置
  | 'cost'           // 成本影响分析
  | 'actions'        // 纠正措施
  | 'prevention'     // 预防措施
  | 'statistics'     // 不合格品统计分析
  | 'export'         // 不合格品数据导出
```

**不同action的请求示例：**
- **获取列表**: `{"action": "list", "params": {...}}`
- **获取详情**: `{"action": "detail", "params": {"id": 123}}`
- **创建记录**: `{"action": "create", "data": {...}}`
- **更新信息**: `{"action": "update", "params": {"id": 123}, "data": {...}}`
- **删除记录**: `{"action": "delete", "params": {"id": 123}}`
- **产品隔离**: `{"action": "isolation", "params": {"id": 123}, "data": {"isolation_reason": "..."}}`
- **产品处置**: `{"action": "disposal", "params": {"id": 123}, "data": {"disposal_method": "..."}}`
- **成本分析**: `{"action": "cost", "params": {"id": 123}}`
- **纠正措施**: `{"action": "actions", "params": {"id": 123}, "data": {"corrective_actions": {...}}`
- **预防措施**: `{"action": "prevention", "params": {"id": 123}, "data": {"preventive_measures": {...}}`
- **统计分析**: `{"action": "statistics", "params": {"type": "monthly"}}`
- **数据导出**: `{"action": "export", "params": {"format": "excel", "filters": {...}}}`

#### 供应商评价接口
| 方法 | 路径 | 描述 | 参数说明 |
|------|------|------|----------|
| POST | `/api/quality/supplier-evaluations` | 供应商评价统一接口 | `action`: list(列表)/detail(详情)/create(创建)/update(更新)/delete(删除)/query(条件查询)/auto(自动评价)/trends(趋势分析)/statistics(统计)/export(导出) |

**Action字典说明：**
```typescript
type SupplierEvaluationAction = 
  | 'list'           // 获取供应商评价列表
  | 'detail'         // 获取评价详情
  | 'create'         // 创建供应商评价
  | 'update'         // 更新评价信息
  | 'delete'         // 删除评价记录
  | 'query'          // 条件查询评价
  | 'auto'           // 自动评价
  | 'trends'         // 评价趋势分析
  | 'statistics'     // 评价统计分析
  | 'export'         // 评价数据导出
```

**不同action的请求示例：**
- **获取列表**: `{"action": "list", "params": {...}}`
- **获取详情**: `{"action": "detail", "params": {"id": 123}}`
- **创建评价**: `{"action": "create", "data": {...}}`
- **更新评价**: `{"action": "update", "params": {"id": 123}, "data": {...}}`
- **删除评价**: `{"action": "delete", "params": {"id": 123}}`
- **条件查询**: `{"action": "query", "params": {"supplier_id": 123, "period": "monthly"}}`
- **自动评价**: `{"action": "auto", "data": {"supplier_ids": [1,2,3]}}`
- **趋势分析**: `{"action": "trends", "params": {"supplier_id": 123}}`
- **统计分析**: `{"action": "statistics", "params": {"type": "monthly"}}`
- **数据导出**: `{"action": "export", "params": {"format": "excel", "filters": {...}}}`

#### 质量报告接口
| 方法 | 路径 | 描述 | 参数说明 |
|------|------|------|----------|
| POST | `/api/quality/reports` | 质量报告统一接口 | `action`: list(列表)/detail(详情)/create(创建)/update(更新)/delete(删除)/approve(审批)/generate(生成报告)/schedule(安排生成)/statistics(统计)/export(导出) |

**Action字典说明：**
```typescript
type QualityReportAction = 
  | 'list'           // 获取质量报告列表
  | 'detail'         // 获取报告详情
  | 'create'         // 创建质量报告
  | 'update'         // 更新报告信息
  | 'delete'         // 删除报告
  | 'approve'        // 审批质量报告
  | 'generate'       // 生成质量报告
  | 'schedule'       // 安排报告生成
  | 'statistics'     // 报告统计分析
  | 'export'         // 报告数据导出
```

**不同action的请求示例：**
- **获取列表**: `{"action": "list", "params": {...}}`
- **获取详情**: `{"action": "detail", "params": {"id": 123}}`
- **创建报告**: `{"action": "create", "data": {...}}`
- **更新报告**: `{"action": "update", "params": {"id": 123}, "data": {...}}`
- **删除报告**: `{"action": "delete", "params": {"id": 123}}`
- **审批报告**: `{"action": "approve", "params": {"id": 123}, "data": {"status": "approved"}}`
- **生成报告**: `{"action": "generate", "params": {"id": 123}}`
- **安排生成**: `{"action": "schedule", "data": {"report_type": "monthly", "schedule": "..."}}`
- **统计分析**: `{"action": "statistics", "params": {"type": "monthly"}}`
- **数据导出**: `{"action": "export", "params": {"format": "excel", "filters": {...}}}`

---

### 06-安全管理模块

#### 安全检查接口
| 方法 | 路径 | 描述 | 参数说明 |
|------|------|------|----------|
| POST | `/api/safety/inspections` | 安全检查统一接口 | `action`: list(列表)/detail(详情)/create(创建)/update(更新)/delete(删除)/approve(审批)/query(条件查询)/statistics(统计)/export(导出) |

**Action字典说明：**
```typescript
type SafetyInspectionAction = 
  | 'list'           // 获取安全检查列表
  | 'detail'         // 获取检查详情
  | 'create'         // 创建安全检查
  | 'update'         // 更新检查信息
  | 'delete'         // 删除检查记录
  | 'approve'        // 审批检查结果
  | 'query'          // 条件查询检查
  | 'statistics'     // 检查统计分析
  | 'export'         // 检查数据导出
```

**不同action的请求示例：**
- **获取列表**: `{"action": "list", "params": {...}}`
- **获取详情**: `{"action": "detail", "params": {"id": 123}}`
- **创建检查**: `{"action": "create", "data": {...}}`
- **更新检查**: `{"action": "update", "params": {"id": 123}, "data": {...}}`
- **删除检查**: `{"action": "delete", "params": {"id": 123}}`
- **审批结果**: `{"action": "approve", "params": {"id": 123}, "data": {"status": "approved"}}`
- **条件查询**: `{"action": "query", "params": {"warehouse_id": 123, "type": "routine"}}`
- **统计分析**: `{"action": "statistics", "params": {"type": "monthly"}}`
- **数据导出**: `{"action": "export", "params": {"format": "excel", "filters": {...}}}`

#### 环境监控接口
| 方法 | 路径 | 描述 | 参数说明 |
|------|------|------|----------|
| POST | `/api/safety/monitoring` | 环境监控统一接口 | `action`: list(列表)/detail(详情)/create(创建)/update(更新)/delete(删除)/alerts(警报查询)/alert-handle(警报处理)/equipment(设备状态)/maintain(设备维护)/trends(趋势分析)/export(导出) |

**Action字典说明：**
```typescript
type EnvironmentMonitoringAction = 
  | 'list'           // 获取环境监控列表
  | 'detail'         // 获取监控详情
  | 'create'         // 创建环境监控记录
  | 'update'         // 更新监控信息
  | 'delete'         // 删除监控记录
  | 'alerts'         // 环境警报查询
  | 'alert-handle'   // 警报处理
  | 'equipment'      // 设备状态查询
  | 'maintain'       // 设备维护
  | 'trends'         // 环境趋势分析
  | 'export'         // 监控数据导出
```

**不同action的请求示例：**
- **获取列表**: `{"action": "list", "params": {...}}`
- **获取详情**: `{"action": "detail", "params": {"id": 123}}`
- **创建监控**: `{"action": "create", "data": {...}}`
- **更新监控**: `{"action": "update", "params": {"id": 123}, "data": {...}}`
- **删除监控**: `{"action": "delete", "params": {"id": 123}}`
- **警报查询**: `{"action": "alerts", "params": {"alert_type": "temperature"}}`
- **警报处理**: `{"action": "alert-handle", "params": {"id": 123}, "data": {"handling_result": "..."}}`
- **设备状态**: `{"action": "equipment", "params": {"equipment_id": 123}}`
- **设备维护**: `{"action": "maintain", "data": {"equipment_id": 123, "maintenance_info": {...}}`
- **趋势分析**: `{"action": "trends", "params": {"monitoring_type": "temperature"}}`
- **数据导出**: `{"action": "export", "params": {"format": "excel", "filters": {...}}}`

#### 危险品运输接口
| 方法 | 路径 | 描述 | 参数说明 |
|------|------|------|----------|
| POST | `/api/safety/hazmat-shipments` | 危险品运输统一接口 | `action`: list(列表)/detail(详情)/create(创建)/update(更新)/delete(删除)/approve(审批)/start(开始运输)/complete(完成运输)/tracking(运输跟踪)/statistics(统计)/export(导出) |

**Action字典说明：**
```typescript
type HazmatShipmentAction = 
  | 'list'           // 获取危险品运输列表
  | 'detail'         // 获取运输详情
  | 'create'         // 创建危险品运输
  | 'update'         // 更新运输信息
  | 'delete'         // 删除运输记录
  | 'approve'        // 审批运输申请
  | 'start'          // 开始运输
  | 'complete'       // 完成运输
  | 'tracking'       // 运输跟踪
  | 'statistics'     // 运输统计分析
  | 'export'         // 运输数据导出
```

**不同action的请求示例：**
- **获取列表**: `{"action": "list", "params": {...}}`
- **获取详情**: `{"action": "detail", "params": {"id": 123}}`
- **创建运输**: `{"action": "create", "data": {...}}`
- **更新运输**: `{"action": "update", "params": {"id": 123}, "data": {...}}`
- **删除运输**: `{"action": "delete", "params": {"id": 123}}`
- **审批申请**: `{"action": "approve", "params": {"id": 123}, "data": {"status": "approved"}}`
- **开始运输**: `{"action": "start", "params": {"id": 123}}`
- **完成运输**: `{"action": "complete", "params": {"id": 123}}`
- **运输跟踪**: `{"action": "tracking", "params": {"id": 123}}`
- **统计分析**: `{"action": "statistics", "params": {"type": "monthly"}}`
- **数据导出**: `{"action": "export", "params": {"format": "excel", "filters": {...}}}`

#### 安全事故接口
| 方法 | 路径 | 描述 | 参数说明 |
|------|------|------|----------|
| POST | `/api/safety/incidents` | 安全事故统一接口 | `action`: list(列表)/detail(详情)/create(创建)/update(更新)/delete(删除)/report(报告事故)/escalation(事件升级)/response-team(应急响应)/communication(应急通信)/lessons(经验教训)/prevention(预防措施)/statistics(统计)/export(导出) |

**Action字典说明：**
```typescript
type SafetyIncidentAction = 
  | 'list'           // 获取安全事故列表
  | 'detail'         // 获取事故详情
  | 'create'         // 创建安全事故记录
  | 'update'         // 更新事故信息
  | 'delete'         // 删除事故记录
  | 'report'         // 报告安全事故
  | 'escalation'     // 事件升级
  | 'response-team'  // 应急响应团队
  | 'communication'  // 应急通信
  | 'lessons'        // 经验教训
  | 'prevention'     // 预防措施
  | 'statistics'     // 事件统计分析
  | 'export'         // 事故数据导出
```

**不同action的请求示例：**
- **获取列表**: `{"action": "list", "params": {...}}`
- **获取详情**: `{"action": "detail", "params": {"id": 123}}`
- **创建事故**: `{"action": "create", "data": {...}}`
- **更新事故**: `{"action": "update", "params": {"id": 123}, "data": {...}}`
- **删除事故**: `{"action": "delete", "params": {"id": 123}}`
- **报告事故**: `{"action": "report", "params": {"id": 123}, "data": {"report_details": {...}}`
- **事件升级**: `{"action": "escalation", "params": {"id": 123}, "data": {"escalation_level": "high"}}`
- **应急响应**: `{"action": "response-team", "params": {"id": 123}}`
- **应急通信**: `{"action": "communication", "params": {"id": 123}, "data": {"communication_info": {...}}`
- **经验教训**: `{"action": "lessons", "params": {"id": 123}}`
- **预防措施**: `{"action": "prevention", "params": {"id": 123}, "data": {"prevention_measures": {...}}`
- **统计分析**: `{"action": "statistics", "params": {"type": "monthly"}}`
- **数据导出**: `{"action": "export", "params": {"format": "excel", "filters": {...}}}`

#### 安全培训接口
| 方法 | 路径 | 描述 | 参数说明 |
|------|------|------|----------|
| POST | `/api/safety/training` | 安全培训统一接口 | `action`: list(列表)/detail(详情)/create(创建)/update(更新)/delete(删除)/schedule(安排培训)/complete(完成培训)/attendees(参训人员)/attendance(培训考勤)/statistics(统计)/export(导出) |

**Action字典说明：**
```typescript
type SafetyTrainingAction = 
  | 'list'           // 获取安全培训列表
  | 'detail'         // 获取培训详情
  | 'create'         // 创建安全培训
  | 'update'         // 更新培训信息
  | 'delete'         // 删除培训记录
  | 'schedule'       // 安排培训
  | 'complete'       // 完成培训
  | 'attendees'      // 获取参训人员
  | 'attendance'     // 培训考勤
  | 'statistics'     // 培训统计分析
  | 'export'         // 培训数据导出
```

**不同action的请求示例：**
- **获取列表**: `{"action": "list", "params": {...}}`
- **获取详情**: `{"action": "detail", "params": {"id": 123}}`
- **创建培训**: `{"action": "create", "data": {...}}`
- **更新培训**: `{"action": "update", "params": {"id": 123}, "data": {...}}`
- **删除培训**: `{"action": "delete", "params": {"id": 123}}`
- **安排培训**: `{"action": "schedule", "params": {"id": 123}, "data": {"schedule_info": {...}}`
- **完成培训**: `{"action": "complete", "params": {"id": 123}}`
- **参训人员**: `{"action": "attendees", "params": {"id": 123}}`
- **培训考勤**: `{"action": "attendance", "data": {"training_id": 123, "attendees": [...]]}}`
- **统计分析**: `{"action": "statistics", "params": {"type": "monthly"}}`
- **数据导出**: `{"action": "export", "params": {"format": "excel", "filters": {...}}}`

#### 安全资质接口
| 方法 | 路径 | 描述 | 参数说明 |
|------|------|------|----------|
| POST | `/api/safety/certificates` | 安全资质统一接口 | `action`: list(列表)/detail(详情)/create(创建)/update(更新)/delete(删除)/expiring(即将过期)/renewal(资质续期)/statistics(统计)/export(导出) |

**Action字典说明：**
```typescript
type SafetyCertificateAction = 
  | 'list'           // 获取安全资质列表
  | 'detail'         // 获取资质详情
  | 'create'         // 创建安全资质
  | 'update'         // 更新资质信息
  | 'delete'         // 删除资质记录
  | 'expiring'       // 即将过期资质
  | 'renewal'        // 资质续期
  | 'statistics'     // 资质统计分析
  | 'export'         // 资质数据导出
```

**不同action的请求示例：**
- **获取列表**: `{"action": "list", "params": {...}}`
- **获取详情**: `{"action": "detail", "params": {"id": 123}}`
- **创建资质**: `{"action": "create", "data": {...}}`
- **更新资质**: `{"action": "update", "params": {"id": 123}, "data": {...}}`
- **删除资质**: `{"action": "delete", "params": {"id": 123}}`
- **即将过期**: `{"action": "expiring", "params": {"days": 30}}`
- **资质续期**: `{"action": "renewal", "params": {"id": 123}, "data": {"renewal_info": {...}}`
- **统计分析**: `{"action": "statistics", "params": {"type": "monthly"}}`
- **数据导出**: `{"action": "export", "params": {"format": "excel", "filters": {...}}}`

---

### 07-报表统计模块

#### 报表模板管理接口
| 方法 | 路径 | 描述 | 参数说明 |
|------|------|------|----------|
| POST | `/api/reports/templates` | 报表模板管理统一接口 | `action`: list(列表)/detail(详情)/create(创建)/update(更新)/delete(删除)/validate(验证配置)/clone(克隆模板)/categories(模板分类)/statistics(统计)/export(导出) |

**Action字典说明：**
```typescript
type ReportTemplateAction = 
  | 'list'           // 获取报表模板列表
  | 'detail'         // 获取模板详情
  | 'create'         // 创建报表模板
  | 'update'         // 更新模板信息
  | 'delete'         // 删除模板
  | 'validate'       // 验证模板配置
  | 'clone'          // 克隆模板
  | 'categories'     // 获取模板分类
  | 'statistics'     // 模板使用统计
  | 'export'         // 模板数据导出
```

**不同action的请求示例：**
- **获取列表**: `{"action": "list", "params": {...}}`
- **获取详情**: `{"action": "detail", "params": {"id": 123}}`
- **创建模板**: `{"action": "create", "data": {...}}`
- **更新模板**: `{"action": "update", "params": {"id": 123}, "data": {...}}`
- **删除模板**: `{"action": "delete", "params": {"id": 123}}`
- **验证配置**: `{"action": "validate", "params": {"id": 123}}`
- **克隆模板**: `{"action": "clone", "params": {"id": 123}, "data": {"new_name": "..."}}`
- **模板分类**: `{"action": "categories", "params": {"type": "business"}}`
- **使用统计**: `{"action": "statistics", "params": {"template_id": 123}}`
- **数据导出**: `{"action": "export", "params": {"format": "excel", "filters": {...}}}`

#### 报表生成接口
| 方法 | 路径 | 描述 | 参数说明 |
|------|------|------|----------|
| POST | `/api/reports/generations` | 报表生成统一接口 | `action`: list(列表)/detail(详情)/create(创建)/update(更新)/delete(删除)/async(异步生成)/status(生成状态)/progress(生成进度)/cancel(取消任务)/download(下载报表)/batch(批量生成)/statistics(统计)/export(导出) |

**Action字典说明：**
```typescript
type ReportGenerationAction = 
  | 'list'           // 获取报表生成记录列表
  | 'detail'         // 获取生成记录详情
  | 'create'         // 创建报表生成任务
  | 'update'         // 更新生成记录
  | 'delete'         // 删除生成记录
  | 'async'          // 异步生成报表
  | 'status'         // 查询生成状态
  | 'progress'       // 查询生成进度
  | 'cancel'         // 取消生成任务
  | 'download'       // 下载生成的报表
  | 'batch'          // 批量生成报表
  | 'statistics'     // 生成记录统计
  | 'export'         // 生成记录导出
```

**不同action的请求示例：**
- **获取列表**: `{"action": "list", "params": {...}}`
- **获取详情**: `{"action": "detail", "params": {"id": 123}}`
- **创建任务**: `{"action": "create", "data": {...}}`
- **更新记录**: `{"action": "update", "params": {"id": 123}, "data": {...}}`
- **删除记录**: `{"action": "delete", "params": {"id": 123}}`
- **异步生成**: `{"action": "async", "data": {"template_id": 123, "params": {...}}`
- **生成状态**: `{"action": "status", "params": {"id": 123}}`
- **生成进度**: `{"action": "progress", "params": {"id": 123}}`
- **取消任务**: `{"action": "cancel", "params": {"id": 123}}`
- **下载报表**: `{"action": "download", "params": {"id": 123}}`
- **批量生成**: `{"action": "batch", "data": {"template_ids": [1,2,3]}}`
- **统计分析**: `{"action": "statistics", "params": {"type": "monthly"}}`
- **数据导出**: `{"action": "export", "params": {"format": "excel", "filters": {...}}}`

#### 数据查询接口
| 方法 | 路径 | 描述 | 参数说明 |
|------|------|------|----------|
| POST | `/api/reports/data` | 数据查询统一接口 | `action`: inventory(库存数据)/sales(销售数据)/procurement(采购数据)/quality(质量数据)/safety(安全数据)/query(自定义查询)/cache-status(缓存状态)/cache-refresh(刷新缓存)/cache-clear(清除缓存)/performance(性能统计) |

**Action字典说明：**
```typescript
type DataQueryAction = 
  | 'inventory'      // 获取库存数据
  | 'sales'          // 获取销售数据
  | 'procurement'    // 获取采购数据
  | 'quality'        // 获取质量数据
  | 'safety'         // 获取安全数据
  | 'query'          // 自定义数据查询
  | 'cache-status'   // 查询缓存状态
  | 'cache-refresh'  // 刷新数据缓存
  | 'cache-clear'    // 清除数据缓存
  | 'performance'    // 查询性能统计
```

**不同action的请求示例：**
- **库存数据**: `{"action": "inventory", "params": {"date_range": {...}, "warehouse_id": 123}}`
- **销售数据**: `{"action": "sales", "params": {"date_range": {...}, "customer_id": 123}}`
- **采购数据**: `{"action": "procurement", "params": {"date_range": {...}, "supplier_id": 123}}`
- **质量数据**: `{"action": "quality", "params": {"date_range": {...}, "product_id": 123}}`
- **安全数据**: `{"action": "safety", "params": {"date_range": {...}, "warehouse_id": 123}}`
- **自定义查询**: `{"action": "query", "data": {"sql": "SELECT * FROM ...", "params": {...}}`
- **缓存状态**: `{"action": "cache-status", "params": {"cache_type": "data"}}`
- **刷新缓存**: `{"action": "cache-refresh", "data": {"cache_type": "data"}}`
- **清除缓存**: `{"action": "cache-clear", "data": {"cache_type": "data"}}`
- **性能统计**: `{"action": "performance", "params": {"query_type": "slow"}}`

#### 仪表板管理接口
| 方法 | 路径 | 描述 | 参数说明 |
|------|------|------|----------|
| POST | `/api/reports/dashboards` | 仪表板管理统一接口 | `action`: list(列表)/detail(详情)/create(创建)/update(更新)/delete(删除)/clone(克隆仪表板)/widgets(组件管理)/layout(布局更新)/refresh(数据刷新)/share(分享仪表板)/statistics(统计) |

**Action字典说明：**
```typescript
type DashboardAction = 
  | 'list'           // 获取仪表板列表
  | 'detail'         // 获取仪表板详情
  | 'create'         // 创建仪表板
  | 'update'         // 更新仪表板
  | 'delete'         // 删除仪表板
  | 'clone'          // 克隆仪表板
  | 'widgets'        // 组件管理
  | 'layout'         // 更新布局
  | 'refresh'        // 实时数据刷新
  | 'share'          // 分享仪表板
  | 'statistics'     // 仪表板使用统计
```

**不同action的请求示例：**
- **获取列表**: `{"action": "list", "params": {...}}`
- **获取详情**: `{"action": "detail", "params": {"id": 123}}`
- **创建仪表板**: `{"action": "create", "data": {...}}`
- **更新仪表板**: `{"action": "update", "params": {"id": 123}, "data": {...}}`
- **删除仪表板**: `{"action": "delete", "params": {"id": 123}}`
- **克隆仪表板**: `{"action": "clone", "params": {"id": 123}, "data": {"new_name": "..."}}`
- **组件管理**: `{"action": "widgets", "params": {"id": 123}, "data": {"widget_info": {...}}`
- **布局更新**: `{"action": "layout", "params": {"id": 123}, "data": {"layout_config": {...}}`
- **数据刷新**: `{"action": "refresh", "params": {"id": 123}}`
- **分享仪表板**: `{"action": "share", "params": {"id": 123}, "data": {"share_config": {...}}`
- **使用统计**: `{"action": "statistics", "params": {"id": 123}}`

#### 定时任务接口
| 方法 | 路径 | 描述 | 参数说明 |
|------|------|------|----------|
| POST | `/api/reports/scheduled-tasks` | 定时任务统一接口 | `action`: list(列表)/detail(详情)/create(创建)/update(更新)/delete(删除)/start(启动任务)/stop(停止任务)/pause(暂停任务)/resume(恢复任务)/history(执行历史)/execute(立即执行)/statistics(统计) |

**Action字典说明：**
```typescript
type ScheduledTaskAction = 
  | 'list'           // 获取定时任务列表
  | 'detail'         // 获取任务详情
  | 'create'         // 创建定时任务
  | 'update'         // 更新任务配置
  | 'delete'         // 删除定时任务
  | 'start'          // 启动任务
  | 'stop'           // 停止任务
  | 'pause'          // 暂停任务
  | 'resume'         // 恢复任务
  | 'history'        // 执行历史
  | 'execute'        // 立即执行
  | 'statistics'     // 任务执行统计
```

**不同action的请求示例：**
- **获取列表**: `{"action": "list", "params": {...}}`
- **获取详情**: `{"action": "detail", "params": {"id": 123}}`
- **创建任务**: `{"action": "create", "data": {...}}`
- **更新任务**: `{"action": "update", "params": {"id": 123}, "data": {...}}`
- **删除任务**: `{"action": "delete", "params": {"id": 123}}`
- **启动任务**: `{"action": "start", "params": {"id": 123}}`
- **停止任务**: `{"action": "stop", "params": {"id": 123}}`
- **暂停任务**: `{"action": "pause", "params": {"id": 123}}`
- **恢复任务**: `{"action": "resume", "params": {"id": 123}}`
- **执行历史**: `{"action": "history", "params": {"id": 123}}`
- **立即执行**: `{"action": "execute", "params": {"id": 123}}`
- **执行统计**: `{"action": "statistics", "params": {"type": "monthly"}}`

#### 分析指标接口
| 方法 | 路径 | 描述 | 参数说明 |
|------|------|------|----------|
| POST | `/api/reports/metrics` | 分析指标统一接口 | `action`: list(列表)/detail(详情)/create(创建)/update(更新)/delete(删除)/validate(验证公式)/values(获取指标值)/calculate(计算指标)/trends(趋势分析)/statistics(统计) |

**Action字典说明：**
```typescript
type MetricsAction = 
  | 'list'           // 获取分析指标列表
  | 'detail'         // 获取指标详情
  | 'create'         // 创建分析指标
  | 'update'         // 更新指标配置
  | 'delete'         // 删除指标
  | 'validate'       // 验证指标公式
  | 'values'         // 获取指标值
  | 'calculate'      // 计算指标值
  | 'trends'         // 指标趋势分析
  | 'statistics'     // 指标使用统计
```

**不同action的请求示例：**
- **获取列表**: `{"action": "list", "params": {...}}`
- **获取详情**: `{"action": "detail", "params": {"id": 123}}`
- **创建指标**: `{"action": "create", "data": {...}}`
- **更新指标**: `{"action": "update", "params": {"id": 123}, "data": {...}}`
- **删除指标**: `{"action": "delete", "params": {"id": 123}}`
- **验证公式**: `{"action": "validate", "params": {"id": 123}}`
- **获取指标值**: `{"action": "values", "params": {"id": 123, "date_range": {...}}`
- **计算指标**: `{"action": "calculate", "params": {"id": 123}, "data": {"calculation_params": {...}}`
- **趋势分析**: `{"action": "trends", "params": {"id": 123, "period": "6months"}}`
- **使用统计**: `{"action": "statistics", "params": {"type": "usage"}}`

---

### 08-系统管理模块

#### 用户管理接口
| 方法 | 路径 | 描述 | 参数说明 |
|------|------|------|----------|
| POST | `/api/system/users` | 用户管理统一接口 | `action`: list(列表)/detail(详情)/create(创建)/update(更新)/delete(删除)/batch(批量操作)/reset-password(重置密码)/change-password(修改密码)/lock(锁定用户)/unlock(解锁用户)/login-history(登录历史)/logout(强制登出)/statistics(统计)/export(导出) |

**Action字典说明：**
```typescript
type UserManagementAction = 
  | 'list'           // 获取用户列表
  | 'detail'         // 获取用户详情
  | 'create'         // 创建用户
  | 'update'         // 更新用户信息
  | 'delete'         // 删除用户
  | 'batch'          // 批量操作用户
  | 'reset-password' // 重置密码
  | 'change-password'// 修改密码
  | 'lock'           // 锁定用户
  | 'unlock'         // 解锁用户
  | 'login-history'  // 获取登录历史
  | 'logout'         // 强制登出
  | 'statistics'     // 用户统计分析
  | 'export'         // 用户数据导出
```

**不同action的请求示例：**
- **获取列表**: `{"action": "list", "params": {...}}`
- **获取详情**: `{"action": "detail", "params": {"id": 123}}`
- **创建用户**: `{"action": "create", "data": {...}}`
- **更新用户**: `{"action": "update", "params": {"id": 123}, "data": {...}}`
- **删除用户**: `{"action": "delete", "params": {"id": 123}}`
- **批量操作**: `{"action": "batch", "data": {"ids": [1,2,3], "operation": "lock"}}`
- **重置密码**: `{"action": "reset-password", "params": {"id": 123}}`
- **修改密码**: `{"action": "change-password", "params": {"id": 123}, "data": {"new_password": "..."}}`
- **锁定用户**: `{"action": "lock", "params": {"id": 123}}`
- **解锁用户**: `{"action": "unlock", "params": {"id": 123}}`
- **登录历史**: `{"action": "login-history", "params": {"id": 123}}`
- **强制登出**: `{"action": "logout", "params": {"id": 123}}`
- **统计分析**: `{"action": "statistics", "params": {"type": "monthly"}}`
- **数据导出**: `{"action": "export", "params": {"format": "excel", "filters": {...}}}`

#### 角色管理接口
| 方法 | 路径 | 描述 | 参数说明 |
|------|------|------|----------|
| POST | `/api/system/roles` | 角色管理统一接口 | `action`: list(列表)/detail(详情)/create(创建)/update(更新)/delete(删除)/clone(克隆角色)/permissions(角色权限)/assign-permissions(分配权限)/remove-permissions(移除权限)/users(角色用户)/assign-users(分配用户)/remove-users(移除用户)/statistics(统计)/export(导出) |

**Action字典说明：**
```typescript
type RoleManagementAction = 
  | 'list'           // 获取角色列表
  | 'detail'         // 获取角色详情
  | 'create'         // 创建角色
  | 'update'         // 更新角色信息
  | 'delete'         // 删除角色
  | 'clone'          // 克隆角色
  | 'permissions'    // 获取角色权限
  | 'assign-permissions' // 分配角色权限
  | 'remove-permissions' // 移除角色权限
  | 'users'          // 获取角色用户
  | 'assign-users'   // 分配用户到角色
  | 'remove-users'   // 从角色移除用户
  | 'statistics'     // 角色使用统计
  | 'export'         // 角色数据导出
```

**不同action的请求示例：**
- **获取列表**: `{"action": "list", "params": {...}}`
- **获取详情**: `{"action": "detail", "params": {"id": 123}}`
- **创建角色**: `{"action": "create", "data": {...}}`
- **更新角色**: `{"action": "update", "params": {"id": 123}, "data": {...}}`
- **删除角色**: `{"action": "delete", "params": {"id": 123}}`
- **克隆角色**: `{"action": "clone", "params": {"id": 123}, "data": {"new_name": "..."}}`
- **角色权限**: `{"action": "permissions", "params": {"id": 123}}`
- **分配权限**: `{"action": "assign-permissions", "params": {"id": 123}, "data": {"permission_ids": [1,2,3]}}`
- **移除权限**: `{"action": "remove-permissions", "params": {"id": 123}, "data": {"permission_ids": [1,2,3]}}`
- **角色用户**: `{"action": "users", "params": {"id": 123}}`
- **分配用户**: `{"action": "assign-users", "params": {"id": 123}, "data": {"user_ids": [1,2,3]}}`
- **移除用户**: `{"action": "remove-users", "params": {"id": 123}, "data": {"user_ids": [1,2,3]}}`
- **使用统计**: `{"action": "statistics", "params": {"type": "usage"}}`
- **数据导出**: `{"action": "export", "params": {"format": "excel", "filters": {...}}}`

#### 权限管理接口
| 方法 | 路径 | 描述 | 参数说明 |
|------|------|------|----------|
| POST | `/api/system/permissions` | 权限管理统一接口 | `action`: list(列表)/detail(详情)/create(创建)/update(更新)/delete(删除)/tree(权限树)/validate(验证配置)/modules(模块权限)/dynamic(动态权限)/inheritance(权限继承)/set-inheritance(设置继承)/statistics(统计)/export(导出) |

**Action字典说明：**
```typescript
type PermissionManagementAction = 
  | 'list'           // 获取权限列表
  | 'detail'         // 获取权限详情
  | 'create'         // 创建权限
  | 'update'         // 更新权限信息
  | 'delete'         // 删除权限
  | 'tree'           // 获取权限树
  | 'validate'       // 验证权限配置
  | 'modules'        // 获取模块权限
  | 'dynamic'        // 动态权限控制
  | 'inheritance'    // 权限继承管理
  | 'set-inheritance'// 设置权限继承
  | 'statistics'     // 权限使用统计
  | 'export'         // 权限数据导出
```

**不同action的请求示例：**
- **获取列表**: `{"action": "list", "params": {...}}`
- **获取详情**: `{"action": "detail", "params": {"id": 123}}`
- **创建权限**: `{"action": "create", "data": {...}}`
- **更新权限**: `{"action": "update", "params": {"id": 123}, "data": {...}}`
- **删除权限**: `{"action": "delete", "params": {"id": 123}}`
- **权限树**: `{"action": "tree", "params": {"module": "procurement"}}`
- **验证配置**: `{"action": "validate", "data": {"permission_config": {...}}`
- **模块权限**: `{"action": "modules", "params": {"module": "inventory"}}`
- **动态权限**: `{"action": "dynamic", "data": {"dynamic_permission": {...}}`
- **权限继承**: `{"action": "inheritance", "params": {"permission_id": 123}}`
- **设置继承**: `{"action": "set-inheritance", "params": {"id": 123}, "data": {"inheritance_config": {...}}`
- **使用统计**: `{"action": "statistics", "params": {"type": "usage"}}`
- **数据导出**: `{"action": "export", "params": {"format": "excel", "filters": {...}}}`

#### 系统配置接口
| 方法 | 路径 | 描述 | 参数说明 |
|------|------|------|----------|
| POST | `/api/system/configs` | 系统配置统一接口 | `action`: list(列表)/detail(详情)/create(创建)/update(更新)/delete(删除)/groups(配置分组)/group(分组配置)/batch-update(批量更新)/refresh(刷新缓存)/backup(备份配置)/restore(恢复配置)/statistics(统计)/export(导出) |

**Action字典说明：**
```typescript
type SystemConfigAction = 
  | 'list'           // 获取系统配置列表
  | 'detail'         // 获取配置详情
  | 'create'         // 创建系统配置
  | 'update'         // 更新配置信息
  | 'delete'         // 删除配置
  | 'groups'         // 获取配置分组
  | 'group'          // 获取分组配置
  | 'batch-update'   // 批量更新配置
  | 'refresh'        // 刷新配置缓存
  | 'backup'         // 备份配置
  | 'restore'        // 恢复配置
  | 'statistics'     // 配置使用统计
  | 'export'         // 配置数据导出
```

**不同action的请求示例：**
- **获取列表**: `{"action": "list", "params": {...}}`
- **获取详情**: `{"action": "detail", "params": {"id": 123}}`
- **创建配置**: `{"action": "create", "data": {...}}`
- **更新配置**: `{"action": "update", "params": {"id": 123}, "data": {...}}`
- **删除配置**: `{"action": "delete", "params": {"id": 123}}`
- **配置分组**: `{"action": "groups", "params": {"type": "system"}}`
- **分组配置**: `{"action": "group", "params": {"group": "database"}}`
- **批量更新**: `{"action": "batch-update", "data": {"configs": [{...}, {...}]}}`
- **刷新缓存**: `{"action": "refresh", "data": {"cache_type": "config"}}`
- **备份配置**: `{"action": "backup", "data": {"backup_name": "..."}}`
- **恢复配置**: `{"action": "restore", "data": {"backup_id": 123}}`
- **使用统计**: `{"action": "statistics", "params": {"type": "usage"}}`
- **数据导出**: `{"action": "export", "params": {"format": "json", "filters": {...}}}`

#### 操作日志接口
| 方法 | 路径 | 描述 | 参数说明 |
|------|------|------|----------|
| POST | `/api/system/operation-logs` | 操作日志统一接口 | `action`: list(列表)/detail(详情)/create(创建)/user-logs(用户日志)/module-logs(模块日志)/date-range(日期范围)/search(高级搜索)/statistics(统计)/export(导出)/cleanup(清理日志) |

**Action字典说明：**
```typescript
type OperationLogAction = 
  | 'list'           // 获取操作日志列表
  | 'detail'         // 获取日志详情
  | 'create'         // 创建操作日志
  | 'user-logs'      // 获取用户操作日志
  | 'module-logs'    // 获取模块操作日志
  | 'date-range'     // 按日期范围查询
  | 'search'         // 高级搜索日志
  | 'statistics'     // 日志统计分析
  | 'export'         // 日志数据导出
  | 'cleanup'        // 清理历史日志
```

**不同action的请求示例：**
- **获取列表**: `{"action": "list", "params": {...}}`
- **获取详情**: `{"action": "detail", "params": {"id": 123}}`
- **创建日志**: `{"action": "create", "data": {...}}`
- **用户日志**: `{"action": "user-logs", "params": {"user_id": 123}}`
- **模块日志**: `{"action": "module-logs", "params": {"module": "procurement"}}`
- **日期范围**: `{"action": "date-range", "params": {"start_date": "2024-01-01", "end_date": "2024-12-31"}}`
- **高级搜索**: `{"action": "search", "data": {"search_criteria": {...}}`
- **统计分析**: `{"action": "statistics", "params": {"type": "monthly"}}`
- **数据导出**: `{"action": "export", "params": {"format": "excel", "filters": {...}}}`
- **清理日志**: `{"action": "cleanup", "data": {"retention_days": 90}}`

#### 数据备份接口
| 方法 | 路径 | 描述 | 参数说明 |
|------|------|------|----------|
| POST | `/api/system/backups` | 数据备份统一接口 | `action`: list(列表)/detail(详情)/create(创建)/delete(删除)/download(下载备份)/restore(恢复备份)/incremental(增量备份)/full(全量备份)/schedule(备份计划)/test-restore(测试恢复)/statistics(统计)/export(导出) |

**Action字典说明：**
```typescript
type DataBackupAction = 
  | 'list'           // 获取备份记录列表
  | 'detail'         // 获取备份详情
  | 'create'         // 创建数据备份
  | 'delete'         // 删除备份
  | 'download'       // 下载备份文件
  | 'restore'        // 恢复数据备份
  | 'incremental'    // 增量备份
  | 'full'           // 全量备份
  | 'schedule'       // 获取备份计划
  | 'test-restore'   // 测试恢复
  | 'statistics'     // 备份统计分析
  | 'export'         // 备份记录导出
```

**不同action的请求示例：**
- **获取列表**: `{"action": "list", "params": {...}}`
- **获取详情**: `{"action": "detail", "params": {"id": 123}}`
- **创建备份**: `{"action": "create", "data": {"backup_type": "full"}}`
- **删除备份**: `{"action": "delete", "params": {"id": 123}}`
- **下载备份**: `{"action": "download", "params": {"id": 123}}`
- **恢复备份**: `{"action": "restore", "params": {"id": 123}}`
- **增量备份**: `{"action": "incremental", "data": {"backup_config": {...}}`
- **全量备份**: `{"action": "full", "data": {"backup_config": {...}}`
- **备份计划**: `{"action": "schedule", "params": {"schedule_type": "daily"}}`
- **测试恢复**: `{"action": "test-restore", "params": {"id": 123}}`
- **统计分析**: `{"action": "statistics", "params": {"type": "monthly"}}`
- **记录导出**: `{"action": "export", "params": {"format": "excel", "filters": {...}}}`

#### 系统监控接口
| 方法 | 路径 | 描述 | 参数说明 |
|------|------|------|----------|
| POST | `/api/system/monitoring` | 系统监控统一接口 | `action`: health(健康检查)/performance(性能监控)/resources(资源监控)/database(数据库监控) |

**Action字典说明：**
```typescript
type SystemMonitoringAction = 
  | 'health'         // 系统健康检查
  | 'performance'    // 系统性能监控
  | 'resources'      // 资源使用监控
  | 'database'       // 数据库监控
```

**不同action的请求示例：**
- **健康检查**: `{"action": "health", "params": {"check_type": "full"}}`
- **性能监控**: `{"action": "performance", "params": {"metrics": ["cpu", "memory", "disk"]}}`
- **资源监控**: `{"action": "resources", "params": {"resource_type": "all"}}`
- **数据库监控**: `{"action": "database", "params": {"db_type": "postgresql"}}`

---

## 🎯 接口统计

### 按模块统计
| 模块 | 原接口数量 | 整合后接口数量 | 状态 |
|------|------------|----------------|------|
| 01-基础数据管理 | 44个 | 3个 | ✅ 已完成 |
| 02-采购管理 | 40个 | 5个 | ✅ 已完成 |
| 03-库存管理 | 71个 | 7个 | ✅ 已完成 |
| 04-销售管理 | 66个 | 5个 | ✅ 已完成 |
| 05-质量控制 | 56个 | 4个 | ✅ 已完成 |
| 06-安全管理 | 66个 | 6个 | ✅ 已完成 |
| 07-报表统计 | 69个 | 5个 | ✅ 已完成 |
| 08-系统管理 | 91个 | 6个 | ✅ 已完成 |
| **总计** | **503个** | **42个** | **92%减少** |

### 按功能统计
- **统一接口**：42个 (POST方法，通过action区分)
- **查询接口**：保留部分简单查询 (GET方法)
- **导出接口**：集成到统一接口中
- **统计分析**：集成到统一接口中

---

**文档状态：** ✅ 已完成  
**接口总数：** 41个（整合后）  
**减少比例：** 92%以上  
**最后更新：** 2025-08-24
