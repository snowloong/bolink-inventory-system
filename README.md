<!--
 * @Author: yaoruidong yaord@meix.com
 * @Date: 2025-07-28 23:25:06
 * @LastEditors: yaoruidong yaord@meix.com
 * @LastEditTime: 2025-07-28 23:56:58
 * @FilePath: /bolink-inventory-system/README.md
 * @Description: 
 * 
-->
# 博链科技新能源电池进销存管理系统

## 项目概述

本项目为博链科技公司设计的新能源电池进销存信息管理系统，采用现代化技术栈构建，支持多端部署。

## 技术架构

### 后端服务
- **框架**: Nest.js
- **数据库**: PostgreSQL + Redis
- **认证**: JWT + Passport
- **API文档**: Swagger

### 桌面端管理后台
- **框架**: Tauri + HTML/CSS/JavaScript
- **UI库**: Element Plus / Ant Design
- **打包**: Tauri CLI

### 移动端应用
- **框架**: Taro + React Native
- **UI库**: Taro UI
- **打包**: Taro CLI

## 项目结构

```
bolink-inventory-system/
├── backend/                 # Nest.js 后端服务
├── desktop/                 # Tauri 桌面应用
├── mobile/                  # Taro 移动应用
├── docs/                    # 项目文档
└── 论文大纲.md             # 论文大纲
```

## 核心功能模块

### 1. 基础数据管理
- 产品信息管理
- 供应商管理
- 客户管理
- 仓库管理

### 2. 采购管理
- 采购计划
- 采购订单
- 批次入库
- 质检管理

### 3. 库存管理
- 实时库存
- 批次追溯
- FIFO策略
- 库存预警

### 4. 销售管理
- 销售订单
- 信用控制
- 出库管理
- 退货处理

### 5. 报表分析
- 库存报表
- 销售报表
- 采购报表

## 快速开始

### 后端服务
```bash
cd backend
npm install
npm run start:dev
```

### 桌面应用
```bash
cd desktop
npm install
npm run tauri dev
```

### 移动应用
```bash
cd mobile
npm install
npm run dev:weapp
```

## 论文相关

详细论文大纲请参考 `论文大纲.md` 文件。 