#!/bin/bash

# 博链科技进销存管理系统后端启动脚本

echo "🚀 启动博链科技进销存管理系统后端..."

# 检查Node.js版本
NODE_VERSION=$(node -v)
echo "📦 Node.js版本: $NODE_VERSION"

# 检查是否安装了依赖
if [ ! -d "node_modules" ]; then
    echo "📥 安装依赖..."
    npm install
fi

# 检查环境变量文件
if [ ! -f ".env" ]; then
    echo "⚙️  创建环境变量文件..."
    cp env.example .env
    echo "请编辑 .env 文件配置数据库连接信息"
fi

# 检查Docker是否运行
if command -v docker &> /dev/null; then
    echo "🐳 检查Docker服务..."
    if ! docker info &> /dev/null; then
        echo "❌ Docker服务未运行，请启动Docker"
        exit 1
    fi
fi

# 启动数据库服务
echo "🗄️  启动数据库服务..."
docker-compose up postgres redis -d

# 等待数据库启动
echo "⏳ 等待数据库启动..."
sleep 10

# 运行数据库迁移
echo "🔄 运行数据库迁移..."
npm run migration:run

# 启动开发服务器
echo "🎯 启动开发服务器..."
npm run start:dev 