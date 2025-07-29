-- 博链科技进销存管理系统数据库初始化脚本

-- 创建数据库
CREATE DATABASE IF NOT EXISTS bolink_inventory;

-- 使用数据库
\c bolink_inventory;

-- 创建用户表
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(100) NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    role VARCHAR(20) DEFAULT 'operator',
    is_active BOOLEAN DEFAULT true,
    last_login_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- 创建产品表
CREATE TABLE IF NOT EXISTS products (
    id SERIAL PRIMARY KEY,
    code VARCHAR(100) UNIQUE NOT NULL,
    name VARCHAR(200) NOT NULL,
    description TEXT,
    battery_type VARCHAR(50) NOT NULL,
    voltage DECIMAL(10,2) NOT NULL,
    capacity DECIMAL(10,2) NOT NULL,
    weight DECIMAL(10,2) NOT NULL,
    dimensions VARCHAR(50) NOT NULL,
    purchase_price DECIMAL(10,2) NOT NULL,
    selling_price DECIMAL(10,2) NOT NULL,
    safety_stock INTEGER NOT NULL,
    max_stock INTEGER NOT NULL,
    status VARCHAR(20) DEFAULT 'active',
    current_stock INTEGER DEFAULT 0,
    production_date DATE,
    expiry_date DATE,
    manufacturer VARCHAR(100),
    brand VARCHAR(100),
    technical_specs TEXT,
    safety_notes TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- 创建供应商表
CREATE TABLE IF NOT EXISTS suppliers (
    id SERIAL PRIMARY KEY,
    code VARCHAR(100) UNIQUE NOT NULL,
    name VARCHAR(200) NOT NULL,
    contact_person VARCHAR(100),
    phone VARCHAR(50),
    email VARCHAR(100),
    address TEXT,
    status VARCHAR(20) DEFAULT 'active',
    notes TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- 创建客户表
CREATE TABLE IF NOT EXISTS customers (
    id SERIAL PRIMARY KEY,
    code VARCHAR(100) UNIQUE NOT NULL,
    name VARCHAR(200) NOT NULL,
    contact_person VARCHAR(100),
    phone VARCHAR(50),
    email VARCHAR(100),
    address TEXT,
    credit_limit DECIMAL(12,2) DEFAULT 0,
    current_credit DECIMAL(12,2) DEFAULT 0,
    status VARCHAR(20) DEFAULT 'active',
    notes TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- 创建批次信息表
CREATE TABLE IF NOT EXISTS batch_info (
    id SERIAL PRIMARY KEY,
    batch_serial VARCHAR(50) UNIQUE NOT NULL,
    product_id INTEGER REFERENCES products(id),
    supplier_id INTEGER REFERENCES suppliers(id),
    production_date DATE NOT NULL,
    expiry_date DATE NOT NULL,
    initial_quantity INTEGER NOT NULL,
    remaining_quantity INTEGER NOT NULL,
    status VARCHAR(20) DEFAULT 'active',
    purchase_price DECIMAL(10,2) NOT NULL,
    quality_report_no VARCHAR(100),
    notes TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- 创建库存表
CREATE TABLE IF NOT EXISTS inventory (
    id SERIAL PRIMARY KEY,
    batch_id INTEGER REFERENCES batch_info(id),
    quantity INTEGER NOT NULL,
    status VARCHAR(20) DEFAULT 'available',
    location_code VARCHAR(100),
    notes TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- 创建采购订单表
CREATE TABLE IF NOT EXISTS purchase_orders (
    id SERIAL PRIMARY KEY,
    order_no VARCHAR(50) UNIQUE NOT NULL,
    supplier_id INTEGER REFERENCES suppliers(id),
    order_date DATE NOT NULL,
    expected_delivery_date DATE,
    total_amount DECIMAL(12,2) NOT NULL,
    status VARCHAR(20) DEFAULT 'pending',
    notes TEXT,
    created_by INTEGER REFERENCES users(id),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- 创建采购订单明细表
CREATE TABLE IF NOT EXISTS purchase_order_items (
    id SERIAL PRIMARY KEY,
    order_id INTEGER REFERENCES purchase_orders(id),
    product_id INTEGER REFERENCES products(id),
    quantity INTEGER NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    total_price DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);

-- 创建销售订单表
CREATE TABLE IF NOT EXISTS sales_orders (
    id SERIAL PRIMARY KEY,
    order_no VARCHAR(50) UNIQUE NOT NULL,
    customer_id INTEGER REFERENCES customers(id),
    order_date DATE NOT NULL,
    delivery_date DATE,
    total_amount DECIMAL(12,2) NOT NULL,
    status VARCHAR(20) DEFAULT 'pending',
    notes TEXT,
    created_by INTEGER REFERENCES users(id),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- 创建销售订单明细表
CREATE TABLE IF NOT EXISTS sales_order_items (
    id SERIAL PRIMARY KEY,
    order_id INTEGER REFERENCES sales_orders(id),
    product_id INTEGER REFERENCES products(id),
    batch_id INTEGER REFERENCES batch_info(id),
    quantity INTEGER NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    total_price DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);

-- 创建库存事务表
CREATE TABLE IF NOT EXISTS inventory_transactions (
    id SERIAL PRIMARY KEY,
    transaction_type VARCHAR(20) NOT NULL, -- 'inbound', 'outbound', 'adjustment'
    batch_id INTEGER REFERENCES batch_info(id),
    quantity INTEGER NOT NULL,
    reference_type VARCHAR(50), -- 'purchase_order', 'sales_order', 'manual'
    reference_id INTEGER,
    notes TEXT,
    created_by INTEGER REFERENCES users(id),
    created_at TIMESTAMP DEFAULT NOW()
);

-- 创建索引
CREATE INDEX IF NOT EXISTS idx_products_code ON products(code);
CREATE INDEX IF NOT EXISTS idx_products_status ON products(status);
CREATE INDEX IF NOT EXISTS idx_batch_info_serial ON batch_info(batch_serial);
CREATE INDEX IF NOT EXISTS idx_batch_info_product ON batch_info(product_id);
CREATE INDEX IF NOT EXISTS idx_batch_info_status ON batch_info(status);
CREATE INDEX IF NOT EXISTS idx_batch_info_expiry ON batch_info(expiry_date);
CREATE INDEX IF NOT EXISTS idx_inventory_batch ON inventory(batch_id);
CREATE INDEX IF NOT EXISTS idx_purchase_orders_supplier ON purchase_orders(supplier_id);
CREATE INDEX IF NOT EXISTS idx_sales_orders_customer ON sales_orders(customer_id);
CREATE INDEX IF NOT EXISTS idx_inventory_transactions_batch ON inventory_transactions(batch_id);
CREATE INDEX IF NOT EXISTS idx_inventory_transactions_type ON inventory_transactions(transaction_type);

-- 插入初始数据
INSERT INTO users (username, email, password, first_name, last_name, role) VALUES
('admin', 'admin@bolink.com', '$2b$10$rQZ9K8mN2vX1pL3qR5sT7u', '系统', '管理员', 'admin'),
('manager', 'manager@bolink.com', '$2b$10$rQZ9K8mN2vX1pL3qR5sT7u', '仓库', '经理', 'manager'),
('operator', 'operator@bolink.com', '$2b$10$rQZ9K8mN2vX1pL3qR5sT7u', '操作', '员', 'operator');

INSERT INTO suppliers (code, name, contact_person, phone, email) VALUES
('SUP001', '宁德时代新能源科技股份有限公司', '张经理', '13800138001', 'contact@catl.com'),
('SUP002', '比亚迪股份有限公司', '李经理', '13800138002', 'contact@byd.com'),
('SUP003', '国轩高科股份有限公司', '王经理', '13800138003', 'contact@gotion.com');

INSERT INTO customers (code, name, contact_person, phone, email) VALUES
('CUS001', '特斯拉汽车公司', 'John Smith', '13900139001', 'john@tesla.com'),
('CUS002', '蔚来汽车', '张先生', '13900139002', 'zhang@nio.com'),
('CUS003', '小鹏汽车', '李女士', '13900139003', 'li@xpeng.com');

INSERT INTO products (code, name, description, battery_type, voltage, capacity, weight, dimensions, purchase_price, selling_price, safety_stock, max_stock, manufacturer, brand) VALUES
('BAT001', '磷酸铁锂电池 3.2V 100Ah', '高安全性磷酸铁锂电池，适用于储能系统', 'lithium_iron_phosphate', 3.2, 100, 2.5, '200x150x50mm', 800.00, 1200.00, 50, 500, '宁德时代', 'CATL'),
('BAT002', '三元锂电池 3.7V 60Ah', '高能量密度三元锂电池，适用于电动汽车', 'lithium_ion', 3.7, 60, 1.8, '180x120x40mm', 600.00, 900.00, 100, 1000, '比亚迪', 'BYD'),
('BAT003', '钛酸锂电池 2.3V 30Ah', '长寿命钛酸锂电池，适用于储能和动力应用', 'lithium_titanate', 2.3, 30, 1.2, '150x100x30mm', 400.00, 600.00, 200, 2000, '国轩高科', 'Gotion'); 