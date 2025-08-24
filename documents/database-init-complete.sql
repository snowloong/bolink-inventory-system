-- =====================================================
-- 新能源电池进销存信息管理系统 - 数据库初始化脚本（完整版）
-- 版本: 1.0.1
-- 数据库: PostgreSQL 14+
-- 创建时间: 2025-08-24
-- 兼容性: 适配PostgreSQL 14及以上版本
-- 更新: 重新组织执行顺序，确保依赖关系正确
-- =====================================================

-- =====================================================
-- 清理阶段：删除已存在的数据库对象
-- =====================================================

-- 删除物化视图（如果存在）
DROP MATERIALIZED VIEW IF EXISTS mv_inventory_summary CASCADE;

-- 删除视图（如果存在）
DROP VIEW IF EXISTS view_inventory_alerts CASCADE;
DROP VIEW IF EXISTS view_expiring_inventory CASCADE;
DROP VIEW IF EXISTS view_order_completion CASCADE;
DROP VIEW IF EXISTS view_supplier_performance CASCADE;
DROP VIEW IF EXISTS view_customer_sales CASCADE;
DROP VIEW IF EXISTS view_product_sales CASCADE;

-- 删除触发器（如果存在）
DROP TRIGGER IF EXISTS trigger_update_products_updated_at ON products;
DROP TRIGGER IF EXISTS trigger_update_suppliers_updated_at ON suppliers;
DROP TRIGGER IF EXISTS trigger_update_customers_updated_at ON customers;
DROP TRIGGER IF EXISTS trigger_update_warehouses_updated_at ON warehouses;
DROP TRIGGER IF EXISTS trigger_update_inventory_alerts_updated_at ON inventory_alerts;
DROP TRIGGER IF EXISTS trigger_update_purchase_orders_updated_at ON purchase_orders;
DROP TRIGGER IF EXISTS trigger_update_sales_orders_updated_at ON sales_orders;
DROP TRIGGER IF EXISTS trigger_update_roles_updated_at ON roles;
DROP TRIGGER IF EXISTS trigger_update_system_configs_updated_at ON system_configs;
DROP TRIGGER IF EXISTS trigger_update_batch_traceability_updated_at ON batch_traceability;
DROP TRIGGER IF EXISTS trigger_update_inventory_timestamp ON inventory_transactions;
DROP TRIGGER IF EXISTS trigger_update_safety_inspections_updated_at ON safety_inspections;
DROP TRIGGER IF EXISTS trigger_update_environment_monitoring_updated_at ON environment_monitoring;
DROP TRIGGER IF EXISTS trigger_update_hazmat_shipments_updated_at ON hazmat_shipments;
DROP TRIGGER IF EXISTS trigger_update_safety_incidents_updated_at ON safety_incidents;
DROP TRIGGER IF EXISTS trigger_update_safety_training_updated_at ON safety_training;
DROP TRIGGER IF EXISTS trigger_update_safety_certificates_updated_at ON safety_certificates;
DROP TRIGGER IF EXISTS trigger_update_report_templates_updated_at ON report_templates;
DROP TRIGGER IF EXISTS trigger_update_scheduled_tasks_updated_at ON scheduled_tasks;
DROP TRIGGER IF EXISTS trigger_update_analysis_metrics_updated_at ON analysis_metrics;
DROP TRIGGER IF EXISTS trigger_update_dashboard_configs_updated_at ON dashboard_configs;
DROP TRIGGER IF EXISTS trigger_update_return_orders_updated_at ON return_orders;
DROP TRIGGER IF EXISTS trigger_update_customer_visits_updated_at ON customer_visits;

-- 删除函数（如果存在）
DROP FUNCTION IF EXISTS update_updated_at_column() CASCADE;
DROP FUNCTION IF EXISTS update_inventory_from_transaction() CASCADE;
DROP FUNCTION IF EXISTS sync_inventory_quantities() CASCADE;
DROP FUNCTION IF EXISTS auto_expire_reservations() CASCADE;
DROP FUNCTION IF EXISTS get_available_inventory(INTEGER, INTEGER) CASCADE;
DROP FUNCTION IF EXISTS validate_product_code(VARCHAR) CASCADE;
DROP FUNCTION IF EXISTS validate_supplier_code(VARCHAR) CASCADE;
DROP FUNCTION IF EXISTS validate_customer_code(VARCHAR) CASCADE;
DROP FUNCTION IF EXISTS calculate_inventory_turnover(INTEGER, INTEGER) CASCADE;
DROP FUNCTION IF EXISTS create_quarterly_partition(INTEGER, INTEGER) CASCADE;
DROP FUNCTION IF EXISTS auto_create_log_partitions() CASCADE;
DROP FUNCTION IF EXISTS cleanup_old_log_partitions(INTEGER) CASCADE;

-- 删除表（按依赖关系倒序删除）
-- 先删除有外键依赖的表
DROP TABLE IF EXISTS customer_visits CASCADE;
DROP TABLE IF EXISTS return_orders CASCADE;
DROP TABLE IF EXISTS dashboard_configs CASCADE;
DROP TABLE IF EXISTS metric_values CASCADE;
DROP TABLE IF EXISTS analysis_metrics CASCADE;
DROP TABLE IF EXISTS scheduled_tasks CASCADE;
DROP TABLE IF EXISTS report_generations CASCADE;
DROP TABLE IF EXISTS report_templates CASCADE;
DROP TABLE IF EXISTS safety_certificates CASCADE;
DROP TABLE IF EXISTS safety_training CASCADE;
DROP TABLE IF EXISTS safety_incidents CASCADE;
DROP TABLE IF EXISTS hazmat_shipments CASCADE;
DROP TABLE IF EXISTS environment_monitoring CASCADE;
DROP TABLE IF EXISTS safety_inspections CASCADE;
DROP TABLE IF EXISTS delivery_order_items CASCADE;
DROP TABLE IF EXISTS delivery_orders CASCADE;
DROP TABLE IF EXISTS receiving_record_items CASCADE;
DROP TABLE IF EXISTS receiving_records CASCADE;
DROP TABLE IF EXISTS product_price_history CASCADE;
DROP TABLE IF EXISTS supplier_evaluations CASCADE;
DROP TABLE IF EXISTS inventory_reservations CASCADE;
DROP TABLE IF EXISTS batch_traceability CASCADE;
DROP TABLE IF EXISTS quality_inspections CASCADE;
DROP TABLE IF EXISTS sales_order_items CASCADE;
DROP TABLE IF EXISTS sales_orders CASCADE;
DROP TABLE IF EXISTS purchase_order_items CASCADE;
DROP TABLE IF EXISTS procurement_plans CASCADE;
DROP TABLE IF EXISTS purchase_orders CASCADE;
DROP TABLE IF EXISTS transfer_order_items CASCADE;
DROP TABLE IF EXISTS transfer_orders CASCADE;
DROP TABLE IF EXISTS stock_count_details CASCADE;
DROP TABLE IF EXISTS stock_counts CASCADE;
DROP TABLE IF EXISTS inventory_alerts CASCADE;
DROP TABLE IF EXISTS inventory_transactions CASCADE;
DROP TABLE IF EXISTS inventory CASCADE;
DROP TABLE IF EXISTS role_permissions CASCADE;
DROP TABLE IF EXISTS user_roles CASCADE;
DROP TABLE IF EXISTS permissions CASCADE;
DROP TABLE IF EXISTS roles CASCADE;
DROP TABLE IF EXISTS system_configs CASCADE;
DROP TABLE IF EXISTS users CASCADE;
DROP TABLE IF EXISTS warehouses CASCADE;
DROP TABLE IF EXISTS customers CASCADE;
DROP TABLE IF EXISTS suppliers CASCADE;
DROP TABLE IF EXISTS products CASCADE;

-- 删除操作日志分区表
DROP TABLE IF EXISTS operation_logs_y2025q4 CASCADE;
DROP TABLE IF EXISTS operation_logs_y2025q3 CASCADE;
DROP TABLE IF EXISTS operation_logs_y2025q2 CASCADE;
DROP TABLE IF EXISTS operation_logs_y2025q1 CASCADE;
DROP TABLE IF EXISTS operation_logs CASCADE;

-- 删除扩展（如果存在，但保留uuid-ossp和pgcrypto）
-- DROP EXTENSION IF EXISTS "uuid-ossp" CASCADE;
-- DROP EXTENSION IF EXISTS "pgcrypto" CASCADE;

-- 输出清理完成信息
DO $$
BEGIN
    RAISE NOTICE '==============================================';
    RAISE NOTICE '数据库对象清理完成！';
    RAISE NOTICE '已删除所有表、视图、触发器、函数';
    RAISE NOTICE '开始创建新的数据库结构...';
    RAISE NOTICE '==============================================';
END $$;

-- =====================================================
-- 第一步：创建数据库扩展
-- =====================================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- =====================================================
-- 第二步：创建基础函数（供后续触发器使用）
-- =====================================================

-- 更新时间戳触发器函数
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 库存更新触发器函数
CREATE OR REPLACE FUNCTION update_inventory_from_transaction()
RETURNS TRIGGER AS $$
BEGIN
    -- 更新库存最后修改时间
    UPDATE inventory 
    SET last_updated = CURRENT_TIMESTAMP
    WHERE product_id = NEW.product_id 
      AND warehouse_id = NEW.warehouse_id 
      AND (batch_number = NEW.batch_number OR (batch_number IS NULL AND NEW.batch_number IS NULL));
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 库存数量变化触发器（可选，用于自动维护库存数量）
CREATE OR REPLACE FUNCTION sync_inventory_quantities()
RETURNS TRIGGER AS $$
BEGIN
    -- 这里可以添加自动更新库存数量的逻辑
    -- 根据库存流水自动计算和更新库存主表的数量
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 库存预留自动过期函数
CREATE OR REPLACE FUNCTION auto_expire_reservations()
RETURNS INTEGER AS $$
DECLARE
    expired_count INTEGER := 0;
BEGIN
    -- 自动释放过期的库存预留
    UPDATE inventory_reservations 
    SET status = 'expired', 
        released_at = CURRENT_TIMESTAMP,
        released_by = 0  -- 系统自动释放
    WHERE status = 'active' 
      AND expiry_date < CURRENT_DATE;
    
    GET DIAGNOSTICS expired_count = ROW_COUNT;
    
    RETURN expired_count;
END;
$$ LANGUAGE plpgsql;

-- 获取产品可用库存函数
CREATE OR REPLACE FUNCTION get_available_inventory(p_product_id INTEGER, p_warehouse_id INTEGER DEFAULT NULL)
RETURNS TABLE (
    warehouse_id INTEGER,
    warehouse_name VARCHAR(200),
    total_quantity DECIMAL(12,3),
    available_quantity DECIMAL(12,3),
    reserved_quantity DECIMAL(12,3)
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        i.warehouse_id,
        w.warehouse_name,
        SUM(i.quantity) as total_quantity,
        SUM(i.available_quantity) as available_quantity,
        SUM(i.reserved_quantity) as reserved_quantity
    FROM inventory i
    JOIN warehouses w ON i.warehouse_id = w.id
    WHERE i.product_id = p_product_id
      AND (p_warehouse_id IS NULL OR i.warehouse_id = p_warehouse_id)
      AND i.status = 'available'
    GROUP BY i.warehouse_id, w.warehouse_name
    ORDER BY i.warehouse_id;
END;
$$ LANGUAGE plpgsql;

-- 验证产品编码格式函数
CREATE OR REPLACE FUNCTION validate_product_code(code VARCHAR(50))
RETURNS BOOLEAN AS $$
BEGIN
    -- 检查产品编码格式：BT-YYYYMMDD-XXX
    RETURN code ~ '^BT-[0-9]{8}-[0-9]{3}$';
END;
$$ LANGUAGE plpgsql;

-- 验证供应商编码格式函数
CREATE OR REPLACE FUNCTION validate_supplier_code(code VARCHAR(50))
RETURNS BOOLEAN AS $$
BEGIN
    -- 检查供应商编码格式：SUP-YYYYMMDD-XXX
    RETURN code ~ '^SUP-[0-9]{8}-[0-9]{3}$';
END;
$$ LANGUAGE plpgsql;

-- 验证客户编码格式函数
CREATE OR REPLACE FUNCTION validate_customer_code(code VARCHAR(50))
RETURNS BOOLEAN AS $$
BEGIN
    -- 检查客户编码格式：CUS-YYYYMMDD-XXX
    RETURN code ~ '^CUS-[0-9]{8}-[0-9]{3}$';
END;
$$ LANGUAGE plpgsql;

-- 计算库存周转率函数
CREATE OR REPLACE FUNCTION calculate_inventory_turnover(p_product_id INTEGER, p_days INTEGER DEFAULT 365)
RETURNS DECIMAL(10,4) AS $$
DECLARE
    avg_inventory DECIMAL(12,3);
    total_outbound DECIMAL(12,3);
    turnover_rate DECIMAL(10,4);
BEGIN
    -- 计算平均库存
    SELECT AVG(quantity) INTO avg_inventory
    FROM inventory 
    WHERE product_id = p_product_id 
      AND status = 'available';
    
    -- 计算指定期间的出库总量
    SELECT COALESCE(SUM(ABS(quantity)), 0) INTO total_outbound
    FROM inventory_transactions 
    WHERE product_id = p_product_id 
      AND transaction_type IN ('outbound', 'transfer_out')
      AND created_at >= CURRENT_DATE - p_days;
    
    -- 计算周转率
    IF avg_inventory > 0 THEN
        turnover_rate := total_outbound / avg_inventory;
    ELSE
        turnover_rate := 0;
    END IF;
    
    RETURN turnover_rate;
END;
$$ LANGUAGE plpgsql;

-- 自动创建季度分区的函数
CREATE OR REPLACE FUNCTION create_quarterly_partition(target_year INTEGER, target_quarter INTEGER)
RETURNS TEXT AS $$
DECLARE
    table_name TEXT;
    start_date DATE;
    end_date DATE;
    sql_stmt TEXT;
BEGIN
    -- 计算表名
    table_name := 'operation_logs_y' || target_year || 'q' || target_quarter;
    
    -- 计算季度开始和结束日期
    CASE target_quarter
        WHEN 1 THEN
            start_date := (target_year || '-01-01')::DATE;
            end_date := (target_year || '-04-01')::DATE;
        WHEN 2 THEN
            start_date := (target_year || '-04-01')::DATE;
            end_date := (target_year || '-07-01')::DATE;
        WHEN 3 THEN
            start_date := (target_year || '-07-01')::DATE;
            end_date := (target_year || '-10-01')::DATE;
        WHEN 4 THEN
            start_date := (target_year || '-10-01')::DATE;
            end_date := ((target_year + 1) || '-01-01')::DATE;
        ELSE
            RAISE EXCEPTION '季度参数无效: %, 必须是1-4', target_quarter;
    END CASE;
    
    -- 检查分区是否已存在
    IF EXISTS (SELECT 1 FROM pg_tables WHERE tablename = table_name) THEN
        RETURN '分区表 ' || table_name || ' 已存在';
    END IF;
    
    -- 创建分区表
    sql_stmt := 'CREATE TABLE ' || table_name || ' PARTITION OF operation_logs FOR VALUES FROM (''' 
                || start_date || ''') TO (''' || end_date || ''')';
    EXECUTE sql_stmt;
    
    -- 创建索引
    sql_stmt := 'CREATE INDEX idx_' || table_name || '_user_time ON ' || table_name || '(user_id, operation_time)';
    EXECUTE sql_stmt;
    
    sql_stmt := 'CREATE INDEX idx_' || table_name || '_resource ON ' || table_name || '(resource, action)';
    EXECUTE sql_stmt;
    
    sql_stmt := 'CREATE INDEX idx_' || table_name || '_module ON ' || table_name || '(module)';
    EXECUTE sql_stmt;
    
    sql_stmt := 'CREATE INDEX idx_' || table_name || '_operation_type ON ' || table_name || '(operation_type)';
    EXECUTE sql_stmt;
    
    RETURN '成功创建分区表: ' || table_name || ' (时间范围: ' || start_date || ' 到 ' || end_date || ')';
END;
$$ LANGUAGE plpgsql;

-- 自动创建未来分区的函数
CREATE OR REPLACE FUNCTION auto_create_log_partitions()
RETURNS TEXT AS $$
DECLARE
    current_year INTEGER;
    current_quarter INTEGER;
    next_year INTEGER;
    next_quarter INTEGER;
    result TEXT := '';
    temp_result TEXT;
BEGIN
    -- 获取当前年份和季度
    current_year := EXTRACT(YEAR FROM CURRENT_DATE);
    current_quarter := EXTRACT(QUARTER FROM CURRENT_DATE);
    
    -- 计算下一个季度
    IF current_quarter = 4 THEN
        next_year := current_year + 1;
        next_quarter := 1;
    ELSE
        next_year := current_year;
        next_quarter := current_quarter + 1;
    END IF;
    
    -- 创建下一个季度的分区
    SELECT create_quarterly_partition(next_year, next_quarter) INTO temp_result;
    result := result || temp_result || E'\n';
    
    -- 创建再下一个季度的分区（提前准备）
    IF next_quarter = 4 THEN
        next_year := next_year + 1;
        next_quarter := 1;
    ELSE
        next_quarter := next_quarter + 1;
    END IF;
    
    SELECT create_quarterly_partition(next_year, next_quarter) INTO temp_result;
    result := result || temp_result || E'\n';
    
    RETURN result;
END;
$$ LANGUAGE plpgsql;

-- 清理旧分区的函数（可选）
CREATE OR REPLACE FUNCTION cleanup_old_log_partitions(retention_years INTEGER DEFAULT 3)
RETURNS TEXT AS $$
DECLARE
    cutoff_date DATE;
    table_record RECORD;
    sql_stmt TEXT;
    result TEXT := '';
BEGIN
    -- 计算保留期限
    cutoff_date := CURRENT_DATE - (retention_years || ' years')::INTERVAL;
    
    -- 查找需要删除的旧分区
    FOR table_record IN 
        SELECT schemaname, tablename 
        FROM pg_tables 
        WHERE tablename LIKE 'operation_logs_y%q%'
        AND tablename < 'operation_logs_y' || EXTRACT(YEAR FROM cutoff_date) || 'q1'
    LOOP
        sql_stmt := 'DROP TABLE IF EXISTS ' || table_record.schemaname || '.' || table_record.tablename;
        EXECUTE sql_stmt;
        result := result || '删除旧分区: ' || table_record.tablename || E'\n';
    END LOOP;
    
    IF result = '' THEN
        result := '没有需要清理的旧分区';
    END IF;
    
    RETURN result;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- 第三步：创建基础数据表（无外键依赖）
-- =====================================================

-- 产品信息表
CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    product_code VARCHAR(50) UNIQUE NOT NULL,
    product_name VARCHAR(200) NOT NULL,
    model VARCHAR(100),
    series VARCHAR(100),
    battery_type VARCHAR(50),
    capacity DECIMAL(10,2),
    voltage DECIMAL(8,2),
    dimensions JSONB,
    weight DECIMAL(8,3),
    cycle_life INTEGER,
    energy_density DECIMAL(8,2),
    operating_temperature JSONB,
    storage_temperature JSONB,
    certifications JSONB,
    specifications JSONB,
    safety_level VARCHAR(20),
    status VARCHAR(20) DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 产品表注释
COMMENT ON TABLE products IS '产品信息表 - 存储新能源电池产品的基本信息和技术参数';
COMMENT ON COLUMN products.id IS '主键ID';
COMMENT ON COLUMN products.product_code IS '产品编码 - 系统生成的唯一产品标识，格式：BT-YYYYMMDD-XXX';
COMMENT ON COLUMN products.product_name IS '产品名称';
COMMENT ON COLUMN products.model IS '产品型号';
COMMENT ON COLUMN products.series IS '产品系列';
COMMENT ON COLUMN products.battery_type IS '电池类型 - 如锂离子、磷酸铁锂、三元锂等';
COMMENT ON COLUMN products.capacity IS '电池容量 - 单位Ah（安时）';
COMMENT ON COLUMN products.voltage IS '电池电压 - 单位V（伏特）';
COMMENT ON COLUMN products.dimensions IS '尺寸信息 - JSON格式存储长宽高';
COMMENT ON COLUMN products.weight IS '重量 - 单位kg';
COMMENT ON COLUMN products.cycle_life IS '循环寿命 - 充放电循环次数';
COMMENT ON COLUMN products.energy_density IS '能量密度 - 单位Wh/kg';
COMMENT ON COLUMN products.operating_temperature IS '工作温度范围 - JSON格式存储最低和最高温度';
COMMENT ON COLUMN products.storage_temperature IS '存储温度范围 - JSON格式存储最低和最高温度';
COMMENT ON COLUMN products.certifications IS '认证信息 - JSON格式存储各种认证证书';
COMMENT ON COLUMN products.specifications IS '技术规格 - JSON格式存储详细技术参数';
COMMENT ON COLUMN products.safety_level IS '安全等级 - 产品安全等级分类';
COMMENT ON COLUMN products.status IS '状态 - active:有效, inactive:无效, discontinued:停产';

-- 供应商表
CREATE TABLE suppliers (
    id SERIAL PRIMARY KEY,
    supplier_code VARCHAR(50) UNIQUE NOT NULL,
    supplier_name VARCHAR(200) NOT NULL,
    supplier_type VARCHAR(50) NOT NULL,
    registration_info JSONB,
    contact_info JSONB,
    qualifications JSONB,
    cooperation_level VARCHAR(20) DEFAULT 'general',
    credit_rating VARCHAR(10),
    supply_capacity JSONB,
    payment_terms VARCHAR(100),
    status VARCHAR(20) DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 供应商表注释
COMMENT ON TABLE suppliers IS '供应商信息表 - 存储供应商基本信息、资质和合作关系';
COMMENT ON COLUMN suppliers.id IS '主键ID';
COMMENT ON COLUMN suppliers.supplier_code IS '供应商编码 - 系统生成的唯一标识，格式：SUP-YYYYMMDD-XXX';
COMMENT ON COLUMN suppliers.supplier_name IS '供应商名称';
COMMENT ON COLUMN suppliers.supplier_type IS '供应商类型 - manufacturer:制造商, trader:贸易商, agent:代理商';
COMMENT ON COLUMN suppliers.registration_info IS '注册信息 - JSON格式存储注册地址、法人代表等';
COMMENT ON COLUMN suppliers.contact_info IS '联系信息 - JSON格式存储联系人、电话、邮箱、地址等';
COMMENT ON COLUMN suppliers.qualifications IS '资质信息 - JSON格式存储营业执照、认证证书等';
COMMENT ON COLUMN suppliers.cooperation_level IS '合作等级 - strategic:战略, important:重要, general:一般, observation:观察';
COMMENT ON COLUMN suppliers.credit_rating IS '信用评级 - AAA, AA, A, B, C';
COMMENT ON COLUMN suppliers.supply_capacity IS '供应能力 - JSON格式存储月供应能力、主要产品线等';
COMMENT ON COLUMN suppliers.payment_terms IS '付款条件';

-- 客户表
CREATE TABLE customers (
    id SERIAL PRIMARY KEY,
    customer_code VARCHAR(50) UNIQUE NOT NULL,
    customer_name VARCHAR(200) NOT NULL,
    customer_type VARCHAR(50) NOT NULL,
    industry VARCHAR(50),
    registration_info JSONB,
    contact_info JSONB,
    credit_info JSONB,
    requirements JSONB,
    sales_person_id INTEGER,
    status VARCHAR(20) DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 客户表注释
COMMENT ON TABLE customers IS '客户信息表 - 存储客户基本信息、信用状况和需求特征';
COMMENT ON COLUMN customers.id IS '主键ID';
COMMENT ON COLUMN customers.customer_code IS '客户编码 - 系统生成的唯一标识，格式：CUS-YYYYMMDD-XXX';
COMMENT ON COLUMN customers.customer_name IS '客户名称';
COMMENT ON COLUMN customers.customer_type IS '客户类型 - manufacturer:制造商, integrator:集成商, distributor:分销商, end_user:终端用户';
COMMENT ON COLUMN customers.industry IS '所属行业 - 新能源汽车、储能、3C电子、工业设备等';
COMMENT ON COLUMN customers.registration_info IS '注册信息 - JSON格式存储公司注册信息';
COMMENT ON COLUMN customers.contact_info IS '联系信息 - JSON格式存储联系人信息';
COMMENT ON COLUMN customers.credit_info IS '信用信息 - JSON格式存储信用等级、授信额度等';
COMMENT ON COLUMN customers.requirements IS '需求特征 - JSON格式存储客户需求偏好';
COMMENT ON COLUMN customers.sales_person_id IS '负责销售员ID';

-- 仓库表
CREATE TABLE warehouses (
    id SERIAL PRIMARY KEY,
    warehouse_code VARCHAR(50) UNIQUE NOT NULL,
    warehouse_name VARCHAR(200) NOT NULL,
    warehouse_type VARCHAR(50) NOT NULL,
    address JSONB,
    specifications JSONB,
    facilities JSONB,
    zones JSONB,
    capacity_info JSONB,
    safety_config JSONB,
    status VARCHAR(20) DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 仓库表注释
COMMENT ON TABLE warehouses IS '仓库信息表 - 存储仓库基本信息、规格和安全配置';
COMMENT ON COLUMN warehouses.id IS '主键ID';
COMMENT ON COLUMN warehouses.warehouse_code IS '仓库编码 - 系统生成的唯一标识，格式：WH-YYYYMMDD-XXX';
COMMENT ON COLUMN warehouses.warehouse_name IS '仓库名称';
COMMENT ON COLUMN warehouses.warehouse_type IS '仓库类型 - main:主仓, branch:分仓, transit:中转仓, customer:客户仓';
COMMENT ON COLUMN warehouses.address IS '仓库地址 - JSON格式存储详细地址和GPS坐标';
COMMENT ON COLUMN warehouses.specifications IS '仓库规格 - JSON格式存储面积、容量、层高等';
COMMENT ON COLUMN warehouses.facilities IS '环境设施 - JSON格式存储温湿度控制、通风、照明等设施';
COMMENT ON COLUMN warehouses.zones IS '库区规划 - JSON格式存储功能分区、货架布局等';
COMMENT ON COLUMN warehouses.capacity_info IS '容量信息 - JSON格式存储理论容量、实际可用容量等';
COMMENT ON COLUMN warehouses.safety_config IS '安全配置 - JSON格式存储消防、监控、门禁等安全设施';

-- 用户表
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(20),
    password_hash VARCHAR(255) NOT NULL,
    salt VARCHAR(100),
    full_name VARCHAR(100),
    avatar_url VARCHAR(500),
    department_id INTEGER,
    department_name VARCHAR(100),
    position VARCHAR(100),
    employee_id VARCHAR(50),
    hire_date DATE,
    manager_id INTEGER REFERENCES users(id),
    status VARCHAR(20) DEFAULT 'active',
    is_admin BOOLEAN DEFAULT false,
    last_login_time TIMESTAMP,
    last_login_ip INET,
    login_count INTEGER DEFAULT 0,
    password_changed_at TIMESTAMP,
    password_expires_at TIMESTAMP,
    failed_login_attempts INTEGER DEFAULT 0,
    locked_until TIMESTAMP,
    two_factor_enabled BOOLEAN DEFAULT false,
    two_factor_secret VARCHAR(100),
    preferences JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE users IS '用户表 - 存储系统用户的基本信息和权限设置';
COMMENT ON COLUMN users.username IS '用户名 - 系统登录用户名，唯一';
COMMENT ON COLUMN users.password_hash IS '密码哈希 - 加密后的密码';
COMMENT ON COLUMN users.status IS '状态 - active:激活, inactive:未激活, locked:锁定, expired:过期';

-- 角色表
CREATE TABLE roles (
    id SERIAL PRIMARY KEY,
    role_code VARCHAR(50) UNIQUE NOT NULL,
    role_name VARCHAR(100) NOT NULL,
    description TEXT,
    parent_role_id INTEGER REFERENCES roles(id),
    level INTEGER DEFAULT 0,
    is_system_role BOOLEAN DEFAULT false,
    permissions JSONB,
    data_scope VARCHAR(20) DEFAULT 'all',
    data_scope_config JSONB,
    max_users INTEGER,
    validity_period INTEGER,
    status VARCHAR(20) DEFAULT 'active',
    created_by INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE roles IS '角色表 - 定义系统角色和权限范围';
COMMENT ON COLUMN roles.role_code IS '角色编码 - 系统内部使用的角色标识';
COMMENT ON COLUMN roles.data_scope IS '数据权限范围 - all:全部, department:部门, self:个人';

-- 权限表
CREATE TABLE permissions (
    id SERIAL PRIMARY KEY,
    permission_code VARCHAR(100) UNIQUE NOT NULL,
    permission_name VARCHAR(100) NOT NULL,
    permission_type VARCHAR(20) NOT NULL,
    resource VARCHAR(100),
    action VARCHAR(50),
    description TEXT,
    parent_permission_id INTEGER REFERENCES permissions(id),
    module VARCHAR(50),
    sort_order INTEGER DEFAULT 0,
    is_menu BOOLEAN DEFAULT false,
    menu_icon VARCHAR(50),
    menu_url VARCHAR(200),
    status VARCHAR(20) DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE permissions IS '权限表 - 定义系统功能权限和菜单权限';
COMMENT ON COLUMN permissions.permission_type IS '权限类型 - menu:菜单, button:按钮, api:接口, data:数据';

-- 用户角色关联表
CREATE TABLE user_roles (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role_id INTEGER NOT NULL REFERENCES roles(id) ON DELETE CASCADE,
    assigned_by INTEGER REFERENCES users(id),
    assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP,
    status VARCHAR(20) DEFAULT 'active',
    remarks TEXT,
    UNIQUE(user_id, role_id)
);

-- 角色权限关联表
CREATE TABLE role_permissions (
    id SERIAL PRIMARY KEY,
    role_id INTEGER NOT NULL REFERENCES roles(id) ON DELETE CASCADE,
    permission_id INTEGER NOT NULL REFERENCES permissions(id) ON DELETE CASCADE,
    granted BOOLEAN DEFAULT true,
    granted_by INTEGER REFERENCES users(id),
    granted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_scope_override JSONB,
    UNIQUE(role_id, permission_id)
);

-- 系统配置表
CREATE TABLE system_configs (
    id SERIAL PRIMARY KEY,
    config_group VARCHAR(50) NOT NULL,
    config_key VARCHAR(100) NOT NULL,
    config_value TEXT,
    config_type VARCHAR(20) DEFAULT 'string',
    description TEXT,
    options JSONB,
    validation_rule VARCHAR(500),
    is_encrypted BOOLEAN DEFAULT false,
    is_readonly BOOLEAN DEFAULT false,
    is_public BOOLEAN DEFAULT false,
    display_order INTEGER DEFAULT 0,
    status VARCHAR(20) DEFAULT 'active',
    updated_by INTEGER REFERENCES users(id),
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(config_group, config_key)
);

COMMENT ON TABLE system_configs IS '系统配置表 - 存储系统运行参数和业务配置项';

-- =====================================================
-- 第四步：创建业务表（有外键依赖）
-- =====================================================

-- 库存主表
CREATE TABLE inventory (
    id SERIAL PRIMARY KEY,
    product_id INTEGER NOT NULL REFERENCES products(id),
    warehouse_id INTEGER NOT NULL REFERENCES warehouses(id),
    location_code VARCHAR(50),
    batch_number VARCHAR(100) NOT NULL,
    quantity DECIMAL(12,3) NOT NULL DEFAULT 0,
    available_quantity DECIMAL(12,3) NOT NULL DEFAULT 0,
    reserved_quantity DECIMAL(12,3) NOT NULL DEFAULT 0,
    damaged_quantity DECIMAL(12,3) NOT NULL DEFAULT 0,
    unit_cost DECIMAL(12,4),
    production_date DATE,
    expiry_date DATE,
    supplier_id INTEGER REFERENCES suppliers(id),
    status VARCHAR(20) DEFAULT 'available',
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(product_id, warehouse_id, batch_number, location_code)
);

-- 库存表注释
COMMENT ON TABLE inventory IS '库存主表 - 存储库存数量和状态信息，支持批次和库位管理';
COMMENT ON COLUMN inventory.id IS '主键ID';
COMMENT ON COLUMN inventory.product_id IS '产品ID - 关联products表';
COMMENT ON COLUMN inventory.warehouse_id IS '仓库ID - 关联warehouses表';
COMMENT ON COLUMN inventory.location_code IS '库位编码 - 具体存放位置';
COMMENT ON COLUMN inventory.batch_number IS '批次号 - 产品批次标识';
COMMENT ON COLUMN inventory.quantity IS '总数量 - 该批次在该库位的总数量';
COMMENT ON COLUMN inventory.available_quantity IS '可用数量 - 可用于销售的数量';
COMMENT ON COLUMN inventory.reserved_quantity IS '预留数量 - 已预留但未出库的数量';
COMMENT ON COLUMN inventory.damaged_quantity IS '损坏数量 - 损坏无法使用的数量';
COMMENT ON COLUMN inventory.unit_cost IS '单位成本 - 该批次的单位成本';
COMMENT ON COLUMN inventory.production_date IS '生产日期';
COMMENT ON COLUMN inventory.expiry_date IS '到期日期';
COMMENT ON COLUMN inventory.supplier_id IS '供应商ID - 该批次的供应商';
COMMENT ON COLUMN inventory.status IS '状态 - available:可用, reserved:预留, damaged:损坏, expired:过期';

-- 库存流水表
CREATE TABLE inventory_transactions (
    id BIGSERIAL PRIMARY KEY,
    transaction_code VARCHAR(50) UNIQUE NOT NULL,
    product_id INTEGER NOT NULL REFERENCES products(id),
    warehouse_id INTEGER NOT NULL REFERENCES warehouses(id),
    batch_number VARCHAR(100),
    location_code VARCHAR(50),
    transaction_type VARCHAR(50) NOT NULL,
    quantity DECIMAL(12,3) NOT NULL,
    unit_cost DECIMAL(12,4),
    total_cost DECIMAL(15,2),
    reference_type VARCHAR(50),
    reference_id INTEGER,
    reference_code VARCHAR(50),
    remarks TEXT,
    operator_id INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 库存流水表注释
COMMENT ON TABLE inventory_transactions IS '库存流水表 - 记录所有库存变动明细，用于库存追溯';
COMMENT ON COLUMN inventory_transactions.id IS '主键ID';
COMMENT ON COLUMN inventory_transactions.transaction_code IS '流水号 - 唯一的交易流水号';
COMMENT ON COLUMN inventory_transactions.transaction_type IS '交易类型 - inbound:入库, outbound:出库, transfer_in:调入, transfer_out:调出, adjustment:盘点调整, 预留/释放';
COMMENT ON COLUMN inventory_transactions.quantity IS '数量 - 正数表示增加，负数表示减少';
COMMENT ON COLUMN inventory_transactions.reference_type IS '单据类型 - purchase_order:采购单, sales_order:销售单, transfer_order:调拨单等';
COMMENT ON COLUMN inventory_transactions.reference_id IS '单据ID - 关联具体业务单据';
COMMENT ON COLUMN inventory_transactions.reference_code IS '单据编号 - 业务单据的编号';
COMMENT ON COLUMN inventory_transactions.operator_id IS '操作人ID';

-- 库存预警设置表
CREATE TABLE inventory_alerts (
    id SERIAL PRIMARY KEY,
    product_id INTEGER NOT NULL REFERENCES products(id),
    warehouse_id INTEGER REFERENCES warehouses(id),
    min_quantity DECIMAL(12,3) NOT NULL,
    max_quantity DECIMAL(12,3),
    reorder_point DECIMAL(12,3),
    economic_order_quantity DECIMAL(12,3),
    lead_time_days INTEGER,
    safety_stock DECIMAL(12,3),
    alert_enabled BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 库存预警表注释
COMMENT ON TABLE inventory_alerts IS '库存预警设置表 - 配置库存预警规则和参数';
COMMENT ON COLUMN inventory_alerts.min_quantity IS '最小库存量 - 低于此数量将触发紧急预警';
COMMENT ON COLUMN inventory_alerts.max_quantity IS '最大库存量 - 超过此数量将触发库存过多预警';
COMMENT ON COLUMN inventory_alerts.reorder_point IS '补货点 - 达到此数量时需要补货';
COMMENT ON COLUMN inventory_alerts.economic_order_quantity IS '经济订货量 - 建议的单次订货数量';
COMMENT ON COLUMN inventory_alerts.lead_time_days IS '采购周期 - 从下单到到货的天数';
COMMENT ON COLUMN inventory_alerts.safety_stock IS '安全库存 - 为应对需求波动的缓冲库存';

-- 盘点记录表
CREATE TABLE stock_counts (
    id SERIAL PRIMARY KEY,
    count_code VARCHAR(50) UNIQUE NOT NULL,
    warehouse_id INTEGER NOT NULL REFERENCES warehouses(id),
    count_type VARCHAR(20) NOT NULL,
    count_date DATE NOT NULL,
    count_scope JSONB,
    count_by INTEGER,
    supervisor INTEGER,
    status VARCHAR(20) DEFAULT 'planning',
    total_items INTEGER DEFAULT 0,
    difference_items INTEGER DEFAULT 0,
    total_difference_value DECIMAL(15,2) DEFAULT 0,
    remarks TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    approved_at TIMESTAMP
);

-- 盘点记录表注释
COMMENT ON TABLE stock_counts IS '盘点记录表 - 记录库存盘点任务和结果汇总';
COMMENT ON COLUMN stock_counts.count_code IS '盘点单号 - 格式：SC-YYYYMMDD-XXX';
COMMENT ON COLUMN stock_counts.count_type IS '盘点类型 - full:全盘, partial:抽盘, cycle:循环盘点';
COMMENT ON COLUMN stock_counts.count_scope IS '盘点范围 - JSON格式存储盘点的产品、区域等范围';
COMMENT ON COLUMN stock_counts.status IS '状态 - planning:计划中, executing:执行中, completed:已完成, approved:已审批';
COMMENT ON COLUMN stock_counts.total_items IS '盘点品项总数';
COMMENT ON COLUMN stock_counts.difference_items IS '有差异的品项数';
COMMENT ON COLUMN stock_counts.total_difference_value IS '差异总价值';

-- 盘点明细表
CREATE TABLE stock_count_details (
    id SERIAL PRIMARY KEY,
    count_id INTEGER NOT NULL REFERENCES stock_counts(id) ON DELETE CASCADE,
    product_id INTEGER NOT NULL REFERENCES products(id),
    batch_number VARCHAR(100),
    location_code VARCHAR(50),
    system_quantity DECIMAL(12,3) NOT NULL,
    actual_quantity DECIMAL(12,3) NOT NULL,
    difference_quantity DECIMAL(12,3) NOT NULL,
    unit_cost DECIMAL(12,4),
    difference_value DECIMAL(15,2),
    difference_reason VARCHAR(200),
    adjusted BOOLEAN DEFAULT false,
    remarks TEXT
);

-- 盘点明细表注释
COMMENT ON TABLE stock_count_details IS '盘点明细表 - 记录每个产品批次的盘点详细结果';
COMMENT ON COLUMN stock_count_details.system_quantity IS '系统数量 - 系统记录的理论库存数量';
COMMENT ON COLUMN stock_count_details.actual_quantity IS '实盘数量 - 实际盘点的数量';
COMMENT ON COLUMN stock_count_details.difference_quantity IS '差异数量 - 实盘数量减去系统数量';
COMMENT ON COLUMN stock_count_details.difference_value IS '差异价值 - 差异数量乘以单位成本';
COMMENT ON COLUMN stock_count_details.difference_reason IS '差异原因 - 盘盈盘亏的原因说明';
COMMENT ON COLUMN stock_count_details.adjusted IS '是否已调整 - 差异是否已调整到系统';

-- 调拨单表
CREATE TABLE transfer_orders (
    id SERIAL PRIMARY KEY,
    transfer_code VARCHAR(50) UNIQUE NOT NULL,
    from_warehouse_id INTEGER NOT NULL REFERENCES warehouses(id),
    to_warehouse_id INTEGER NOT NULL REFERENCES warehouses(id),
    transfer_date DATE NOT NULL,
    expected_arrival_date DATE,
    actual_arrival_date DATE,
    reason VARCHAR(200),
    status VARCHAR(20) DEFAULT 'draft',
    total_quantity DECIMAL(12,3) DEFAULT 0,
    total_value DECIMAL(15,2) DEFAULT 0,
    transport_method VARCHAR(50),
    transport_cost DECIMAL(10,2),
    created_by INTEGER,
    approved_by INTEGER,
    shipped_by INTEGER,
    received_by INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    approved_at TIMESTAMP,
    shipped_at TIMESTAMP,
    received_at TIMESTAMP
);

-- 调拨单表注释
COMMENT ON TABLE transfer_orders IS '调拨单表 - 记录仓库间库存调拨业务';
COMMENT ON COLUMN transfer_orders.transfer_code IS '调拨单号 - 格式：TF-YYYYMMDD-XXX';
COMMENT ON COLUMN transfer_orders.from_warehouse_id IS '调出仓库ID';
COMMENT ON COLUMN transfer_orders.to_warehouse_id IS '调入仓库ID';
COMMENT ON COLUMN transfer_orders.reason IS '调拨原因 - 库存平衡、客户需求、仓库搬迁等';
COMMENT ON COLUMN transfer_orders.status IS '状态 - draft:草稿, approved:已审批, shipped:已发货, received:已收货, completed:已完成';
COMMENT ON COLUMN transfer_orders.transport_method IS '运输方式 - 汽运、铁运、航运等';
COMMENT ON COLUMN transfer_orders.transport_cost IS '运输费用';

-- 调拨明细表
CREATE TABLE transfer_order_items (
    id SERIAL PRIMARY KEY,
    transfer_id INTEGER NOT NULL REFERENCES transfer_orders(id) ON DELETE CASCADE,
    product_id INTEGER NOT NULL REFERENCES products(id),
    batch_number VARCHAR(100) NOT NULL,
    from_location_code VARCHAR(50),
    to_location_code VARCHAR(50),
    quantity DECIMAL(12,3) NOT NULL,
    unit_cost DECIMAL(12,4),
    total_cost DECIMAL(15,2),
    shipped_quantity DECIMAL(12,3) DEFAULT 0,
    received_quantity DECIMAL(12,3) DEFAULT 0,
    remarks TEXT
);

-- 调拨明细表注释
COMMENT ON TABLE transfer_order_items IS '调拨明细表 - 记录调拨单的产品明细信息';
COMMENT ON COLUMN transfer_order_items.from_location_code IS '调出库位编码';
COMMENT ON COLUMN transfer_order_items.to_location_code IS '调入库位编码';
COMMENT ON COLUMN transfer_order_items.shipped_quantity IS '已发货数量';
COMMENT ON COLUMN transfer_order_items.received_quantity IS '已收货数量';

-- 采购订单表
CREATE TABLE purchase_orders (
    id SERIAL PRIMARY KEY,
    order_code VARCHAR(50) UNIQUE NOT NULL,
    supplier_id INTEGER NOT NULL REFERENCES suppliers(id),
    order_date DATE NOT NULL,
    expected_date DATE,
    delivery_address JSONB,
    total_amount DECIMAL(15,2) DEFAULT 0,
    tax_amount DECIMAL(15,2) DEFAULT 0,
    discount_amount DECIMAL(15,2) DEFAULT 0,
    final_amount DECIMAL(15,2) DEFAULT 0,
    payment_terms VARCHAR(100),
    delivery_terms VARCHAR(100),
    currency VARCHAR(10) DEFAULT 'CNY',
    exchange_rate DECIMAL(10,4) DEFAULT 1,
    status VARCHAR(20) DEFAULT 'draft',
    priority VARCHAR(20) DEFAULT 'normal',
    contract_number VARCHAR(50),
    remarks TEXT,
    created_by INTEGER,
    approved_by INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    approved_at TIMESTAMP
);

COMMENT ON TABLE purchase_orders IS '采购订单表 - 记录采购订单主要信息';
COMMENT ON COLUMN purchase_orders.order_code IS '采购订单号 - 格式：PO-YYYYMMDD-XXX';
COMMENT ON COLUMN purchase_orders.status IS '状态 - draft:草稿, submitted:已提交, approved:已审批, ordered:已下单, partial_received:部分收货, completed:已完成, cancelled:已取消';

-- 采购订单明细表
CREATE TABLE purchase_order_items (
    id SERIAL PRIMARY KEY,
    order_id INTEGER NOT NULL REFERENCES purchase_orders(id) ON DELETE CASCADE,
    product_id INTEGER NOT NULL REFERENCES products(id),
    quantity DECIMAL(12,3) NOT NULL,
    unit_price DECIMAL(12,4) NOT NULL,
    total_price DECIMAL(12,4) NOT NULL,
    received_quantity DECIMAL(12,3) DEFAULT 0,
    required_date DATE,
    remarks TEXT
);

COMMENT ON TABLE purchase_order_items IS '采购订单明细表 - 记录采购订单的产品明细信息';

-- 采购计划表 - 新增
CREATE TABLE procurement_plans (
    id SERIAL PRIMARY KEY,
    plan_code VARCHAR(50) UNIQUE NOT NULL,           -- 计划编号
    plan_period VARCHAR(20) NOT NULL,                -- 计划期间(月度/季度/年度)
    plan_type VARCHAR(20) NOT NULL,                  -- 计划类型(库存驱动/销售预测/季节性/紧急)
    product_id INTEGER NOT NULL REFERENCES products(id),
    supplier_id INTEGER REFERENCES suppliers(id),    -- 推荐供应商
    planned_quantity DECIMAL(12,3) NOT NULL,         -- 计划数量
    planned_amount DECIMAL(12,4),                    -- 计划金额
    estimated_unit_price DECIMAL(12,4),              -- 预估单价
    priority INTEGER DEFAULT 5,                      -- 优先级(1-10)
    reason TEXT NOT NULL,                            -- 采购原因
    demand_source VARCHAR(50),                       -- 需求来源(安全库存/销售预测/客户订单)
    safety_stock_trigger BOOLEAN DEFAULT false,      -- 是否安全库存触发
    sales_forecast_id INTEGER,                       -- 销售预测ID
    customer_order_id INTEGER,                       -- 客户订单ID
    status VARCHAR(20) DEFAULT 'draft',              -- 状态(draft/submitted/approved/rejected/completed)
    approval_level INTEGER DEFAULT 1,                -- 审批级别
    approved_quantity DECIMAL(12,3),                 -- 审批数量
    approved_amount DECIMAL(12,4),                   -- 审批金额
    actual_quantity DECIMAL(12,3),                   -- 实际采购数量
    actual_amount DECIMAL(12,4),                     -- 实际采购金额
    completion_rate DECIMAL(5,2),                    -- 完成率
    created_by INTEGER NOT NULL REFERENCES users(id),
    approved_by INTEGER REFERENCES users(id),
    submitted_at TIMESTAMP,                          -- 提交时间
    approved_at TIMESTAMP,                           -- 审批时间
    completed_at TIMESTAMP,                          -- 完成时间
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 销售订单表
CREATE TABLE sales_orders (
    id SERIAL PRIMARY KEY,
    order_code VARCHAR(50) UNIQUE NOT NULL,
    customer_id INTEGER NOT NULL REFERENCES customers(id),
    order_date DATE NOT NULL,
    delivery_date DATE,
    delivery_address JSONB,
    total_amount DECIMAL(15,2) DEFAULT 0,
    tax_amount DECIMAL(15,2) DEFAULT 0,
    discount_amount DECIMAL(15,2) DEFAULT 0,
    final_amount DECIMAL(15,2) DEFAULT 0,
    discount_rate DECIMAL(5,4) DEFAULT 0,
    payment_terms VARCHAR(100),
    delivery_terms VARCHAR(100),
    currency VARCHAR(10) DEFAULT 'CNY',
    exchange_rate DECIMAL(10,4) DEFAULT 1,
    status VARCHAR(20) DEFAULT 'draft',
    priority VARCHAR(20) DEFAULT 'normal',
    contract_number VARCHAR(50),
    sales_person INTEGER,
    source_channel VARCHAR(50),
    customer_po_number VARCHAR(50),
    remarks TEXT,
    created_by INTEGER,
    approved_by INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    approved_at TIMESTAMP
);

COMMENT ON TABLE sales_orders IS '销售订单表 - 记录销售订单主要信息';
COMMENT ON COLUMN sales_orders.order_code IS '销售订单号 - 格式：SO-YYYYMMDD-XXX';
COMMENT ON COLUMN sales_orders.status IS '状态 - draft:草稿, submitted:已提交, approved:已审批, confirmed:已确认, partial_shipped:部分发货, completed:已完成, cancelled:已取消';

-- 销售订单明细表
CREATE TABLE sales_order_items (
    id SERIAL PRIMARY KEY,
    order_id INTEGER NOT NULL REFERENCES sales_orders(id) ON DELETE CASCADE,
    product_id INTEGER NOT NULL REFERENCES products(id),
    quantity DECIMAL(12,3) NOT NULL,
    unit_price DECIMAL(12,4) NOT NULL,
    total_price DECIMAL(15,2) NOT NULL,
    tax_rate DECIMAL(5,4) DEFAULT 0,
    tax_amount DECIMAL(15,2) DEFAULT 0,
    delivery_date DATE,
    shipped_quantity DECIMAL(12,3) DEFAULT 0,
    returned_quantity DECIMAL(12,3) DEFAULT 0,
    technical_requirements TEXT,
    packaging_requirements TEXT,
    remarks TEXT
);

COMMENT ON TABLE sales_order_items IS '销售订单明细表 - 记录销售订单的产品明细信息';

-- 质量检验记录表
CREATE TABLE quality_inspections (
    id SERIAL PRIMARY KEY,
    inspection_code VARCHAR(50) UNIQUE NOT NULL,
    product_id INTEGER NOT NULL REFERENCES products(id),
    batch_number VARCHAR(100) NOT NULL,
    supplier_id INTEGER REFERENCES suppliers(id),
    inspection_type VARCHAR(50) NOT NULL,
    inspection_date DATE NOT NULL,
    inspector INTEGER,
    supervisor INTEGER,
    sample_quantity DECIMAL(12,3) NOT NULL,
    total_quantity DECIMAL(12,3),
    inspection_standard VARCHAR(100),
    inspection_method VARCHAR(100),
    inspection_equipment JSONB,
    environment_conditions JSONB,
    inspection_result VARCHAR(20),
    defect_description TEXT,
    defect_rate DECIMAL(5,4),
    conclusion VARCHAR(20) NOT NULL,
    corrective_actions TEXT,
    follow_up_required BOOLEAN DEFAULT false,
    next_inspection_date DATE,
    certificate_number VARCHAR(50),
    remarks TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP
);

COMMENT ON TABLE quality_inspections IS '质量检验记录表 - 记录产品质量检验的详细信息和结果';
COMMENT ON COLUMN quality_inspections.inspection_code IS '检验单号 - 格式：QI-YYYYMMDD-XXX';
COMMENT ON COLUMN quality_inspections.conclusion IS '检验结论 - qualified:合格, unqualified:不合格, conditional:有条件合格';

-- 批次追溯表
CREATE TABLE batch_traceability (
    id SERIAL PRIMARY KEY,
    batch_number VARCHAR(100) UNIQUE NOT NULL,
    product_id INTEGER NOT NULL REFERENCES products(id),
    manufacturer VARCHAR(200),
    production_date DATE,
    production_line VARCHAR(50),
    production_shift VARCHAR(20),
    quality_grade VARCHAR(20),
    raw_materials JSONB,
    production_process JSONB,
    quality_records JSONB,
    flow_records JSONB,
    upstream_batches JSONB,
    downstream_records JSONB,
    certifications JSONB,
    expiry_date DATE,
    shelf_life_days INTEGER,
    storage_requirements JSONB,
    handling_instructions TEXT,
    regulatory_info JSONB,
    status VARCHAR(20) DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE batch_traceability IS '批次追溯表 - 记录电池产品的完整生产和流转信息，满足法规追溯要求';
COMMENT ON COLUMN batch_traceability.batch_number IS '批次号 - 全局唯一的批次标识';
COMMENT ON COLUMN batch_traceability.manufacturer IS '生产厂商 - 实际生产该批次的厂商';
COMMENT ON COLUMN batch_traceability.production_line IS '生产线编号';
COMMENT ON COLUMN batch_traceability.production_shift IS '生产班次';
COMMENT ON COLUMN batch_traceability.quality_grade IS '质量等级 - A级/B级/C级';
COMMENT ON COLUMN batch_traceability.raw_materials IS '原材料信息 - JSON格式存储原材料批次和供应商';
COMMENT ON COLUMN batch_traceability.production_process IS '生产工艺 - JSON格式存储关键工艺参数';
COMMENT ON COLUMN batch_traceability.upstream_batches IS '上游批次 - 关联的原材料批次信息';
COMMENT ON COLUMN batch_traceability.downstream_records IS '下游流向 - 该批次的销售和流向记录';
COMMENT ON COLUMN batch_traceability.regulatory_info IS '法规信息 - 符合的法规标准和认证';

-- 库存预留表
CREATE TABLE inventory_reservations (
    id SERIAL PRIMARY KEY,
    reservation_code VARCHAR(50) UNIQUE NOT NULL,
    inventory_id INTEGER NOT NULL REFERENCES inventory(id),
    reference_type VARCHAR(50) NOT NULL,
    reference_id INTEGER NOT NULL,
    reference_code VARCHAR(50),
    reserved_quantity DECIMAL(12,3) NOT NULL,
    reservation_date DATE NOT NULL,
    expiry_date DATE,
    status VARCHAR(20) DEFAULT 'active',
    priority INTEGER DEFAULT 5,
    reserved_by INTEGER,
    released_by INTEGER,
    reserved_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    released_at TIMESTAMP,
    remarks TEXT
);

COMMENT ON TABLE inventory_reservations IS '库存预留表 - 管理销售订单等业务对库存的预留';
COMMENT ON COLUMN inventory_reservations.reservation_code IS '预留单号 - 格式：RSV-YYYYMMDD-XXX';
COMMENT ON COLUMN inventory_reservations.reference_type IS '业务类型 - sales_order:销售订单, transfer_order:调拨单, manual:手工预留';
COMMENT ON COLUMN inventory_reservations.reference_id IS '业务单据ID';
COMMENT ON COLUMN inventory_reservations.reserved_quantity IS '预留数量';
COMMENT ON COLUMN inventory_reservations.expiry_date IS '预留到期日期 - 超期自动释放';
COMMENT ON COLUMN inventory_reservations.priority IS '优先级 - 1-10，数字越小优先级越高';

-- 供应商评估记录表
CREATE TABLE supplier_evaluations (
    id SERIAL PRIMARY KEY,
    supplier_id INTEGER NOT NULL REFERENCES suppliers(id),
    evaluation_period VARCHAR(20) NOT NULL,
    evaluation_date DATE NOT NULL,
    evaluator INTEGER,
    delivery_score DECIMAL(5,2) DEFAULT 0,
    quality_score DECIMAL(5,2) DEFAULT 0,
    service_score DECIMAL(5,2) DEFAULT 0,
    cost_score DECIMAL(5,2) DEFAULT 0,
    compliance_score DECIMAL(5,2) DEFAULT 0,
    total_score DECIMAL(5,2) DEFAULT 0,
    grade VARCHAR(10),
    delivery_performance JSONB,
    quality_performance JSONB,
    service_performance JSONB,
    cost_performance JSONB,
    compliance_performance JSONB,
    strengths TEXT,
    weaknesses TEXT,
    improvement_suggestions TEXT,
    next_evaluation_date DATE,
    status VARCHAR(20) DEFAULT 'active',
    approved_by INTEGER,
    approved_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE supplier_evaluations IS '供应商评估记录表 - 定期评估供应商的综合表现';
COMMENT ON COLUMN supplier_evaluations.evaluation_period IS '评估期间 - 如2024Q1、2024年度等';
COMMENT ON COLUMN supplier_evaluations.delivery_score IS '交付评分 - 0-100分';
COMMENT ON COLUMN supplier_evaluations.quality_score IS '质量评分 - 0-100分';
COMMENT ON COLUMN supplier_evaluations.service_score IS '服务评分 - 0-100分';
COMMENT ON COLUMN supplier_evaluations.cost_score IS '成本评分 - 0-100分';
COMMENT ON COLUMN supplier_evaluations.compliance_score IS '合规评分 - 0-100分';
COMMENT ON COLUMN supplier_evaluations.grade IS '综合评级 - A/B/C/D';

-- 价格历史表
CREATE TABLE product_price_history (
    id SERIAL PRIMARY KEY,
    product_id INTEGER NOT NULL REFERENCES products(id),
    supplier_id INTEGER REFERENCES suppliers(id),
    customer_id INTEGER REFERENCES customers(id),
    price_type VARCHAR(20) NOT NULL,
    unit_price DECIMAL(12,4) NOT NULL,
    currency VARCHAR(10) DEFAULT 'CNY',
    min_quantity DECIMAL(12,3),
    max_quantity DECIMAL(12,3),
    effective_date DATE NOT NULL,
    expiry_date DATE,
    contract_number VARCHAR(50),
    price_terms TEXT,
    status VARCHAR(20) DEFAULT 'active',
    created_by INTEGER,
    approved_by INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    approved_at TIMESTAMP
);

COMMENT ON TABLE product_price_history IS '产品价格历史表 - 记录产品价格变动历史';
COMMENT ON COLUMN product_price_history.price_type IS '价格类型 - purchase:采购价, sales:销售价, list:标准价';
COMMENT ON COLUMN product_price_history.min_quantity IS '最小数量 - 价格阶梯的最小数量';
COMMENT ON COLUMN product_price_history.max_quantity IS '最大数量 - 价格阶梯的最大数量';
COMMENT ON COLUMN product_price_history.price_terms IS '价格条款 - 包含运费、税费等说明';

-- 收货记录表
CREATE TABLE receiving_records (
    id SERIAL PRIMARY KEY,
    record_code VARCHAR(50) UNIQUE NOT NULL,
    order_id INTEGER REFERENCES purchase_orders(id),
    supplier_id INTEGER NOT NULL REFERENCES suppliers(id),
    warehouse_id INTEGER NOT NULL REFERENCES warehouses(id),
    received_date DATE NOT NULL,
    delivery_note_number VARCHAR(50),
    transport_method VARCHAR(50),
    carrier VARCHAR(100),
    tracking_number VARCHAR(100),
    total_quantity DECIMAL(12,3) DEFAULT 0,
    total_packages INTEGER DEFAULT 0,
    status VARCHAR(20) DEFAULT 'pending',
    received_by INTEGER,
    inspected_by INTEGER,
    approved_by INTEGER,
    remarks TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    inspected_at TIMESTAMP,
    approved_at TIMESTAMP
);

COMMENT ON TABLE receiving_records IS '收货记录表 - 记录采购商品的收货信息和检验结果';
COMMENT ON COLUMN receiving_records.record_code IS '收货单号 - 格式：REC-YYYYMMDD-XXX';
COMMENT ON COLUMN receiving_records.status IS '状态 - pending:待收货, received:已收货, inspected:已检验, approved:已审批';

-- 收货明细表
CREATE TABLE receiving_record_items (
    id SERIAL PRIMARY KEY,
    receiving_id INTEGER NOT NULL REFERENCES receiving_records(id) ON DELETE CASCADE,
    order_item_id INTEGER REFERENCES purchase_order_items(id),
    product_id INTEGER NOT NULL REFERENCES products(id),
    batch_number VARCHAR(100) NOT NULL,
    ordered_quantity DECIMAL(12,3),
    received_quantity DECIMAL(12,3) NOT NULL,
    qualified_quantity DECIMAL(12,3) DEFAULT 0,
    damaged_quantity DECIMAL(12,3) DEFAULT 0,
    unit_price DECIMAL(12,4),
    total_value DECIMAL(15,2),
    production_date DATE,
    expiry_date DATE,
    quality_status VARCHAR(20) DEFAULT 'pending',
    location_code VARCHAR(50),
    packaging_info JSONB,
    remarks TEXT
);

COMMENT ON TABLE receiving_record_items IS '收货明细表 - 记录收货的产品明细信息';

-- 出库单表
CREATE TABLE delivery_orders (
    id SERIAL PRIMARY KEY,
    delivery_code VARCHAR(50) UNIQUE NOT NULL,
    order_id INTEGER REFERENCES sales_orders(id),
    customer_id INTEGER NOT NULL REFERENCES customers(id),
    warehouse_id INTEGER NOT NULL REFERENCES warehouses(id),
    delivery_date DATE NOT NULL,
    planned_ship_date DATE,
    actual_ship_date DATE,
    delivery_address JSONB,
    total_quantity DECIMAL(12,3) DEFAULT 0,
    total_packages INTEGER DEFAULT 0,
    total_weight DECIMAL(10,3),
    carrier VARCHAR(100),
    transport_method VARCHAR(50),
    tracking_number VARCHAR(100),
    shipping_cost DECIMAL(10,2),
    status VARCHAR(20) DEFAULT 'pending',
    priority VARCHAR(20) DEFAULT 'normal',
    special_requirements TEXT,
    picked_by INTEGER,
    packed_by INTEGER,
    shipped_by INTEGER,
    delivered_by INTEGER,
    remarks TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    picked_at TIMESTAMP,
    packed_at TIMESTAMP,
    shipped_at TIMESTAMP,
    delivered_at TIMESTAMP
);

COMMENT ON TABLE delivery_orders IS '出库单表 - 记录销售商品的出库和配送信息';
COMMENT ON COLUMN delivery_orders.delivery_code IS '出库单号 - 格式：DEL-YYYYMMDD-XXX';
COMMENT ON COLUMN delivery_orders.status IS '状态 - pending:待出库, picked:已拣货, packed:已包装, shipped:已发货, delivered:已送达';

-- 出库明细表
CREATE TABLE delivery_order_items (
    id SERIAL PRIMARY KEY,
    delivery_id INTEGER NOT NULL REFERENCES delivery_orders(id) ON DELETE CASCADE,
    order_item_id INTEGER REFERENCES sales_order_items(id),
    product_id INTEGER NOT NULL REFERENCES products(id),
    batch_number VARCHAR(100) NOT NULL,
    location_code VARCHAR(50),
    ordered_quantity DECIMAL(12,3),
    shipped_quantity DECIMAL(12,3) NOT NULL,
    unit_price DECIMAL(12,4),
    total_value DECIMAL(15,2),
    packaging_info JSONB,
    serial_numbers TEXT,
    remarks TEXT
);

COMMENT ON TABLE delivery_order_items IS '出库明细表 - 记录出库的产品明细信息';

-- =====================================================
-- 第五步：创建操作日志表（分区表）
-- =====================================================

-- 操作日志表 (分区表)
CREATE TABLE operation_logs (
    id BIGSERIAL,
    user_id INTEGER REFERENCES users(id),
    session_id VARCHAR(100),
    operation_type VARCHAR(50) NOT NULL,
    module VARCHAR(50),
    resource VARCHAR(100) NOT NULL,
    action VARCHAR(50) NOT NULL,
    resource_id VARCHAR(50),
    resource_name VARCHAR(200),
    old_values JSONB,
    new_values JSONB,
    request_method VARCHAR(10),
    request_url VARCHAR(500),
    request_params JSONB,
    response_status INTEGER,
    ip_address INET,
    user_agent TEXT,
    location_info JSONB,
    operation_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    operation_result VARCHAR(20) DEFAULT 'success',
    error_code VARCHAR(50),
    error_message TEXT,
    duration INTEGER,
    PRIMARY KEY (id, operation_time)
) PARTITION BY RANGE (operation_time);

COMMENT ON TABLE operation_logs IS '操作日志表 - 记录用户操作行为和系统变更日志，按时间分区';

-- 创建2025年的季度分区表
CREATE TABLE operation_logs_y2025q1 PARTITION OF operation_logs
    FOR VALUES FROM ('2025-01-01') TO ('2025-04-01');

CREATE TABLE operation_logs_y2025q2 PARTITION OF operation_logs
    FOR VALUES FROM ('2025-04-01') TO ('2025-07-01');

CREATE TABLE operation_logs_y2025q3 PARTITION OF operation_logs
    FOR VALUES FROM ('2025-07-01') TO ('2025-10-01');

CREATE TABLE operation_logs_y2025q4 PARTITION OF operation_logs
    FOR VALUES FROM ('2025-10-01') TO ('2026-01-01');

-- =====================================================
-- 第六步：创建安全管理表
-- =====================================================

-- 安全检查记录表
CREATE TABLE safety_inspections (
    id SERIAL PRIMARY KEY,
    inspection_code VARCHAR(50) UNIQUE NOT NULL,
    inspection_type VARCHAR(50) NOT NULL,
    inspection_date DATE NOT NULL,
    warehouse_id INTEGER REFERENCES warehouses(id),
    inspector INTEGER REFERENCES users(id),
    supervisor INTEGER REFERENCES users(id),
    inspection_scope JSONB,
    inspection_findings JSONB,
    risk_level VARCHAR(20),
    corrective_actions TEXT,
    follow_up_required BOOLEAN DEFAULT false,
    next_inspection_date DATE,
    status VARCHAR(20) DEFAULT 'completed',
    remarks TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP
);

COMMENT ON TABLE safety_inspections IS '安全检查记录表 - 记录各类安全检查的详细信息和结果';
COMMENT ON COLUMN safety_inspections.inspection_code IS '检查单号 - 格式：SI-YYYYMMDD-XXX';
COMMENT ON COLUMN safety_inspections.inspection_type IS '检查类型 - warehouse:仓库检查, equipment:设备检查, transport:运输检查, emergency:应急检查';
COMMENT ON COLUMN safety_inspections.risk_level IS '风险等级 - low:低风险, medium:中风险, high:高风险, critical:极高风险';

-- 环境监控记录表
CREATE TABLE environment_monitoring (
    id SERIAL PRIMARY KEY,
    monitoring_code VARCHAR(50) UNIQUE NOT NULL,
    warehouse_id INTEGER NOT NULL REFERENCES warehouses(id),
    monitoring_type VARCHAR(50) NOT NULL,
    monitoring_date TIMESTAMP NOT NULL,
    temperature DECIMAL(5,2),
    humidity DECIMAL(5,2),
    air_quality JSONB,
    gas_concentration JSONB,
    smoke_level DECIMAL(5,2),
    alert_threshold JSONB,
    alert_triggered BOOLEAN DEFAULT false,
    alert_message TEXT,
    equipment_status VARCHAR(20),
    data_source VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE environment_monitoring IS '环境监控记录表 - 记录仓库环境参数的实时监控数据';
COMMENT ON COLUMN environment_monitoring.monitoring_type IS '监控类型 - temperature:温度, humidity:湿度, air_quality:空气质量, gas:气体浓度, smoke:烟雾';
COMMENT ON COLUMN environment_monitoring.alert_triggered IS '是否触发警报';

-- 危险品运输记录表
CREATE TABLE hazmat_shipments (
    id SERIAL PRIMARY KEY,
    shipment_code VARCHAR(50) UNIQUE NOT NULL,
    order_id INTEGER REFERENCES sales_orders(id),
    customer_id INTEGER NOT NULL REFERENCES customers(id),
    carrier VARCHAR(200) NOT NULL,
    vehicle_number VARCHAR(50),
    driver_name VARCHAR(100),
    driver_license VARCHAR(50),
    contact_phone VARCHAR(20),
    shipment_date DATE NOT NULL,
    expected_delivery_date DATE,
    actual_delivery_date DATE,
    route_plan JSONB,
    tracking_info JSONB,
    safety_equipment JSONB,
    emergency_contacts JSONB,
    risk_assessment JSONB,
    status VARCHAR(20) DEFAULT 'planned',
    created_by INTEGER REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    delivered_at TIMESTAMP
);

COMMENT ON TABLE hazmat_shipments IS '危险品运输记录表 - 记录危险品运输的详细信息和安全措施';
COMMENT ON COLUMN hazmat_shipments.shipment_code IS '运输单号 - 格式：HM-YYYYMMDD-XXX';
COMMENT ON COLUMN hazmat_shipments.status IS '状态 - planned:计划中, in_transit:运输中, delivered:已送达, cancelled:已取消';

-- 安全事故记录表
CREATE TABLE safety_incidents (
    id SERIAL PRIMARY KEY,
    incident_code VARCHAR(50) UNIQUE NOT NULL,
    incident_type VARCHAR(50) NOT NULL,
    incident_date TIMESTAMP NOT NULL,
    location VARCHAR(200),
    warehouse_id INTEGER REFERENCES warehouses(id),
    severity_level VARCHAR(20) NOT NULL,
    incident_description TEXT NOT NULL,
    root_cause TEXT,
    immediate_actions TEXT,
    affected_persons JSONB,
    property_damage JSONB,
    environmental_impact JSONB,
    emergency_response JSONB,
    investigation_status VARCHAR(20) DEFAULT 'pending',
    corrective_actions TEXT,
    preventive_measures TEXT,
    reported_by INTEGER REFERENCES users(id),
    investigated_by INTEGER REFERENCES users(id),
    status VARCHAR(20) DEFAULT 'open',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    resolved_at TIMESTAMP
);

COMMENT ON TABLE safety_incidents IS '安全事故记录表 - 记录安全事故的详细信息和处理过程';
COMMENT ON COLUMN safety_incidents.incident_code IS '事故编号 - 格式：SA-YYYYMMDD-XXX';
COMMENT ON COLUMN safety_incidents.severity_level IS '严重程度 - minor:轻微, moderate:中等, serious:严重, critical:危急';

-- 安全培训记录表
CREATE TABLE safety_training (
    id SERIAL PRIMARY KEY,
    training_code VARCHAR(50) UNIQUE NOT NULL,
    training_topic VARCHAR(200) NOT NULL,
    training_date DATE NOT NULL,
    trainer VARCHAR(100),
    attendees JSONB,
    training_content TEXT,
    training_materials JSONB,
    assessment_results JSONB,
    effectiveness_evaluation TEXT,
    follow_up_actions TEXT,
    created_by INTEGER REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE safety_training IS '安全培训记录表 - 记录安全培训的详细信息和效果评估';
COMMENT ON COLUMN safety_training.training_code IS '培训编号 - 格式：ST-YYYYMMDD-XXX';
COMMENT ON COLUMN safety_training.attendees IS '参训人员 - JSON格式存储参训人员信息';

-- 安全资质证照表
CREATE TABLE safety_certificates (
    id SERIAL PRIMARY KEY,
    certificate_type VARCHAR(100) NOT NULL,
    certificate_number VARCHAR(100) UNIQUE NOT NULL,
    issuing_authority VARCHAR(200),
    issue_date DATE,
    expiry_date DATE,
    scope TEXT,
    status VARCHAR(20) DEFAULT 'active',
    renewal_reminder BOOLEAN DEFAULT true,
    related_documents JSONB,
    responsible_person INTEGER REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE safety_certificates IS '安全资质证照表 - 管理各类安全相关的资质证照';
COMMENT ON COLUMN safety_certificates.certificate_type IS '证照类型 - hazmat_license:危险品经营许可, safety_license:安全生产许可, transport_license:运输许可';

-- =====================================================
-- 第七步：创建报表统计表
-- =====================================================

-- 报表模板表
CREATE TABLE report_templates (
    id SERIAL PRIMARY KEY,
    template_code VARCHAR(50) UNIQUE NOT NULL,
    template_name VARCHAR(200) NOT NULL,
    template_type VARCHAR(50) NOT NULL,
    template_config JSONB NOT NULL,
    data_source VARCHAR(100),
    parameters JSONB,
    output_format VARCHAR(20) DEFAULT 'excel',
    access_roles JSONB,
    is_public BOOLEAN DEFAULT false,
    status VARCHAR(20) DEFAULT 'active',
    created_by INTEGER REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE report_templates IS '报表模板表 - 存储报表模板的配置信息';
COMMENT ON COLUMN report_templates.template_code IS '模板编码 - 格式：RT-YYYYMMDD-XXX';
COMMENT ON COLUMN report_templates.template_type IS '模板类型 - inventory:库存报表, sales:销售报表, procurement:采购报表, quality:质量报表';

-- 报表生成记录表
CREATE TABLE report_generations (
    id SERIAL PRIMARY KEY,
    generation_code VARCHAR(50) UNIQUE NOT NULL,
    template_id INTEGER NOT NULL REFERENCES report_templates(id),
    generation_date TIMESTAMP NOT NULL,
    parameters JSONB,
    file_path VARCHAR(500),
    file_size BIGINT,
    generation_status VARCHAR(20) DEFAULT 'processing',
    error_message TEXT,
    generated_by INTEGER REFERENCES users(id),
    download_count INTEGER DEFAULT 0,
    last_download_at TIMESTAMP,
    expires_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP
);

COMMENT ON TABLE report_generations IS '报表生成记录表 - 记录报表生成的历史记录';
COMMENT ON COLUMN report_generations.generation_code IS '生成编号 - 格式：RG-YYYYMMDD-XXX';
COMMENT ON COLUMN report_generations.generation_status IS '生成状态 - processing:处理中, completed:已完成, failed:失败, expired:已过期';

-- 定时任务表
CREATE TABLE scheduled_tasks (
    id SERIAL PRIMARY KEY,
    task_code VARCHAR(50) UNIQUE NOT NULL,
    task_name VARCHAR(200) NOT NULL,
    task_type VARCHAR(50) NOT NULL,
    task_config JSONB NOT NULL,
    schedule_config JSONB NOT NULL,
    last_run_time TIMESTAMP,
    next_run_time TIMESTAMP,
    run_count INTEGER DEFAULT 0,
    success_count INTEGER DEFAULT 0,
    failure_count INTEGER DEFAULT 0,
    last_error_message TEXT,
    is_active BOOLEAN DEFAULT true,
    created_by INTEGER REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE scheduled_tasks IS '定时任务表 - 管理报表的定时生成任务';
COMMENT ON COLUMN scheduled_tasks.task_code IS '任务编码 - 格式：ST-YYYYMMDD-XXX';
COMMENT ON COLUMN scheduled_tasks.task_type IS '任务类型 - report_generation:报表生成, data_sync:数据同步, cleanup:数据清理';

-- 分析指标表
CREATE TABLE analysis_metrics (
    id SERIAL PRIMARY KEY,
    metric_code VARCHAR(50) UNIQUE NOT NULL,
    metric_name VARCHAR(200) NOT NULL,
    metric_type VARCHAR(50) NOT NULL,
    calculation_formula TEXT,
    data_source VARCHAR(100),
    unit VARCHAR(20),
    target_value DECIMAL(15,4),
    warning_threshold DECIMAL(15,4),
    critical_threshold DECIMAL(15,4),
    update_frequency VARCHAR(20) DEFAULT 'daily',
    is_active BOOLEAN DEFAULT true,
    description TEXT,
    created_by INTEGER REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE analysis_metrics IS '分析指标表 - 定义各种业务分析指标';
COMMENT ON COLUMN analysis_metrics.metric_code IS '指标编码 - 格式：AM-YYYYMMDD-XXX';
COMMENT ON COLUMN analysis_metrics.metric_type IS '指标类型 - inventory:库存指标, sales:销售指标, quality:质量指标, financial:财务指标';

-- 指标数据表
CREATE TABLE metric_values (
    id SERIAL PRIMARY KEY,
    metric_id INTEGER NOT NULL REFERENCES analysis_metrics(id),
    metric_value DECIMAL(15,4) NOT NULL,
    calculation_date DATE NOT NULL,
    data_period VARCHAR(20),
    dimension_values JSONB,
    status VARCHAR(20) DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(metric_id, calculation_date, data_period)
);

COMMENT ON TABLE metric_values IS '指标数据表 - 存储分析指标的历史数据';
COMMENT ON COLUMN metric_values.data_period IS '数据期间 - daily:日, weekly:周, monthly:月, quarterly:季, yearly:年';

-- 仪表板配置表
CREATE TABLE dashboard_configs (
    id SERIAL PRIMARY KEY,
    dashboard_code VARCHAR(50) UNIQUE NOT NULL,
    dashboard_name VARCHAR(200) NOT NULL,
    layout_config JSONB NOT NULL,
    widget_configs JSONB NOT NULL,
    access_roles JSONB,
    refresh_interval INTEGER DEFAULT 300,
    is_public BOOLEAN DEFAULT false,
    status VARCHAR(20) DEFAULT 'active',
    created_by INTEGER REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE dashboard_configs IS '仪表板配置表 - 存储仪表板的布局和组件配置';
COMMENT ON COLUMN dashboard_configs.dashboard_code IS '仪表板编码 - 格式：DC-YYYYMMDD-XXX';
COMMENT ON COLUMN dashboard_configs.refresh_interval IS '刷新间隔 - 单位秒';

-- =====================================================
-- 第八步：创建补充业务表
-- =====================================================

-- 退换货记录表
CREATE TABLE return_orders (
    id SERIAL PRIMARY KEY,
    return_code VARCHAR(50) UNIQUE NOT NULL,
    order_id INTEGER REFERENCES sales_orders(id),
    customer_id INTEGER NOT NULL REFERENCES customers(id),
    return_type VARCHAR(20) NOT NULL,
    return_reason TEXT,
    return_date DATE NOT NULL,
    total_quantity DECIMAL(12,3) DEFAULT 0,
    total_amount DECIMAL(15,2) DEFAULT 0,
    status VARCHAR(20) DEFAULT 'pending',
    handled_by INTEGER REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    processed_at TIMESTAMP
);

COMMENT ON TABLE return_orders IS '退换货记录表 - 记录客户退换货的详细信息';
COMMENT ON COLUMN return_orders.return_code IS '退换货单号 - 格式：RO-YYYYMMDD-XXX';
COMMENT ON COLUMN return_orders.return_type IS '退换货类型 - return:退货, exchange:换货';

-- 客户回访记录表
CREATE TABLE customer_visits (
    id SERIAL PRIMARY KEY,
    customer_id INTEGER NOT NULL REFERENCES customers(id),
    visit_date DATE NOT NULL,
    visit_type VARCHAR(50),
    visit_purpose TEXT,
    visit_content TEXT,
    customer_feedback TEXT,
    next_action TEXT,
    sales_person INTEGER REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE customer_visits IS '客户回访记录表 - 记录客户回访的详细信息';

-- =====================================================
-- 第九步：添加约束
-- =====================================================

-- 库存数量约束
ALTER TABLE inventory ADD CONSTRAINT chk_inventory_quantity 
    CHECK (quantity >= 0 AND available_quantity >= 0 AND reserved_quantity >= 0 AND damaged_quantity >= 0);

ALTER TABLE inventory ADD CONSTRAINT chk_inventory_quantity_relationship 
    CHECK (quantity = available_quantity + reserved_quantity + damaged_quantity);

-- 库存预警数量约束
ALTER TABLE inventory_alerts ADD CONSTRAINT chk_alerts_quantity 
    CHECK (min_quantity > 0 AND (max_quantity IS NULL OR max_quantity > min_quantity) AND 
           (reorder_point IS NULL OR reorder_point >= min_quantity));

-- 盘点数量约束
ALTER TABLE stock_count_details ADD CONSTRAINT chk_count_quantity 
    CHECK (system_quantity >= 0 AND actual_quantity >= 0);

-- 调拨数量约束
ALTER TABLE transfer_order_items ADD CONSTRAINT chk_transfer_quantity 
    CHECK (quantity > 0 AND shipped_quantity >= 0 AND received_quantity >= 0 AND 
           shipped_quantity <= quantity AND received_quantity <= shipped_quantity);

-- 日期约束
ALTER TABLE inventory ADD CONSTRAINT chk_inventory_dates 
    CHECK (production_date IS NULL OR expiry_date IS NULL OR production_date <= expiry_date);

ALTER TABLE transfer_orders ADD CONSTRAINT chk_transfer_dates 
    CHECK (transfer_date <= COALESCE(expected_arrival_date, transfer_date + INTERVAL '365 days'));

-- 仓库约束
ALTER TABLE transfer_orders ADD CONSTRAINT chk_transfer_warehouses 
    CHECK (from_warehouse_id != to_warehouse_id);

-- 批次追溯表约束
ALTER TABLE batch_traceability ADD CONSTRAINT chk_batch_dates 
    CHECK (production_date IS NULL OR expiry_date IS NULL OR production_date <= expiry_date);

ALTER TABLE batch_traceability ADD CONSTRAINT chk_batch_shelf_life 
    CHECK (shelf_life_days IS NULL OR shelf_life_days > 0);

-- 库存预留表约束
ALTER TABLE inventory_reservations ADD CONSTRAINT chk_reservation_quantity 
    CHECK (reserved_quantity > 0);

ALTER TABLE inventory_reservations ADD CONSTRAINT chk_reservation_dates 
    CHECK (reservation_date <= COALESCE(expiry_date, reservation_date + INTERVAL '1 year'));

ALTER TABLE inventory_reservations ADD CONSTRAINT chk_reservation_priority 
    CHECK (priority >= 1 AND priority <= 10);

-- 供应商评估表约束
ALTER TABLE supplier_evaluations ADD CONSTRAINT chk_evaluation_scores 
    CHECK (delivery_score >= 0 AND delivery_score <= 100 AND 
           quality_score >= 0 AND quality_score <= 100 AND 
           service_score >= 0 AND service_score <= 100 AND 
           cost_score >= 0 AND cost_score <= 100 AND 
           compliance_score >= 0 AND compliance_score <= 100 AND 
           total_score >= 0 AND total_score <= 100);

-- 价格历史表约束
ALTER TABLE product_price_history ADD CONSTRAINT chk_price_positive 
    CHECK (unit_price > 0);

ALTER TABLE product_price_history ADD CONSTRAINT chk_price_quantity_range 
    CHECK (min_quantity IS NULL OR max_quantity IS NULL OR min_quantity <= max_quantity);

ALTER TABLE product_price_history ADD CONSTRAINT chk_price_dates 
    CHECK (effective_date <= COALESCE(expiry_date, effective_date + INTERVAL '10 years'));

-- 订单金额计算约束
ALTER TABLE purchase_order_items ADD CONSTRAINT chk_poi_amount_calculation 
    CHECK (ABS(total_price - (quantity * unit_price)) < 0.01);

ALTER TABLE sales_order_items ADD CONSTRAINT chk_soi_amount_calculation 
    CHECK (ABS(total_price - (quantity * unit_price)) < 0.01);

-- 收货数量约束
ALTER TABLE receiving_record_items ADD CONSTRAINT chk_receiving_quantities 
    CHECK (received_quantity >= 0 AND qualified_quantity >= 0 AND damaged_quantity >= 0 AND 
           qualified_quantity + damaged_quantity <= received_quantity);

-- 出库数量约束
ALTER TABLE delivery_order_items ADD CONSTRAINT chk_delivery_quantities 
    CHECK (shipped_quantity > 0);

-- 安全管理表约束
ALTER TABLE safety_inspections ADD CONSTRAINT chk_inspection_dates 
    CHECK (inspection_date <= COALESCE(next_inspection_date, inspection_date + INTERVAL '1 year'));

ALTER TABLE hazmat_shipments ADD CONSTRAINT chk_shipment_dates 
    CHECK (shipment_date <= COALESCE(expected_delivery_date, shipment_date + INTERVAL '30 days'));

ALTER TABLE safety_incidents ADD CONSTRAINT chk_incident_severity 
    CHECK (severity_level IN ('minor', 'moderate', 'serious', 'critical'));

ALTER TABLE safety_certificates ADD CONSTRAINT chk_certificate_dates 
    CHECK (issue_date <= COALESCE(expiry_date, issue_date + INTERVAL '10 years'));

-- 报表统计表约束
ALTER TABLE report_generations ADD CONSTRAINT chk_generation_dates 
    CHECK (generation_date <= COALESCE(completed_at, generation_date + INTERVAL '24 hours'));

ALTER TABLE scheduled_tasks ADD CONSTRAINT chk_task_counts 
    CHECK (run_count >= 0 AND success_count >= 0 AND failure_count >= 0);

ALTER TABLE metric_values ADD CONSTRAINT chk_metric_value 
    CHECK (metric_value >= 0);

-- 补充业务表约束
ALTER TABLE return_orders ADD CONSTRAINT chk_return_quantities 
    CHECK (total_quantity >= 0 AND total_amount >= 0);

-- 退换货类型约束
ALTER TABLE return_orders ADD CONSTRAINT chk_return_type 
    CHECK (return_type IN ('return', 'exchange'));

-- 客户回访类型约束
ALTER TABLE customer_visits ADD CONSTRAINT chk_visit_type 
    CHECK (visit_type IN ('regular', 'complaint', 'follow_up', 'technical_support', 'business_development'));

-- 安全检查类型约束
ALTER TABLE safety_inspections ADD CONSTRAINT chk_inspection_type 
    CHECK (inspection_type IN ('warehouse', 'equipment', 'transport', 'emergency', 'routine'));

-- 环境监控类型约束
ALTER TABLE environment_monitoring ADD CONSTRAINT chk_monitoring_type 
    CHECK (monitoring_type IN ('temperature', 'humidity', 'air_quality', 'gas', 'smoke', 'comprehensive'));

-- 安全事故类型约束
ALTER TABLE safety_incidents ADD CONSTRAINT chk_incident_type 
    CHECK (incident_type IN ('fire', 'explosion', 'leak', 'spill', 'injury', 'equipment_failure', 'environmental', 'other'));

-- 报表模板类型约束
ALTER TABLE report_templates ADD CONSTRAINT chk_template_type 
    CHECK (template_type IN ('inventory', 'sales', 'procurement', 'quality', 'safety', 'financial', 'custom'));

-- 定时任务类型约束
ALTER TABLE scheduled_tasks ADD CONSTRAINT chk_task_type 
    CHECK (task_type IN ('report_generation', 'data_sync', 'cleanup', 'backup', 'notification', 'calculation'));

-- 分析指标类型约束
ALTER TABLE analysis_metrics ADD CONSTRAINT chk_metric_type 
    CHECK (metric_type IN ('inventory', 'sales', 'quality', 'financial', 'safety', 'performance', 'custom'));

-- =====================================================
-- 第十步：创建索引
-- =====================================================

-- 基础数据表索引
CREATE INDEX idx_products_code ON products(product_code);
CREATE INDEX idx_products_type ON products(battery_type);
CREATE INDEX idx_products_status ON products(status);
CREATE INDEX idx_products_name ON products(product_name);
CREATE INDEX idx_products_model ON products(model);
CREATE INDEX idx_products_series ON products(series);
CREATE INDEX idx_products_capacity ON products(capacity);
CREATE INDEX idx_products_voltage ON products(voltage);
CREATE INDEX idx_products_safety_level ON products(safety_level);

CREATE INDEX idx_suppliers_code ON suppliers(supplier_code);
CREATE INDEX idx_suppliers_name ON suppliers(supplier_name);
CREATE INDEX idx_suppliers_type ON suppliers(supplier_type);
CREATE INDEX idx_suppliers_level ON suppliers(cooperation_level);
CREATE INDEX idx_suppliers_credit ON suppliers(credit_rating);
CREATE INDEX idx_suppliers_status ON suppliers(status);

CREATE INDEX idx_customers_code ON customers(customer_code);
CREATE INDEX idx_customers_name ON customers(customer_name);
CREATE INDEX idx_customers_type ON customers(customer_type);
CREATE INDEX idx_customers_industry ON customers(industry);
CREATE INDEX idx_customers_sales_person ON customers(sales_person_id);
CREATE INDEX idx_customers_status ON customers(status);

CREATE INDEX idx_warehouses_code ON warehouses(warehouse_code);
CREATE INDEX idx_warehouses_name ON warehouses(warehouse_name);
CREATE INDEX idx_warehouses_type ON warehouses(warehouse_type);
CREATE INDEX idx_warehouses_status ON warehouses(status);

-- 库存管理表索引
CREATE INDEX idx_inventory_product ON inventory(product_id);
CREATE INDEX idx_inventory_warehouse ON inventory(warehouse_id);
CREATE INDEX idx_inventory_batch ON inventory(batch_number);
CREATE INDEX idx_inventory_location ON inventory(location_code);
CREATE INDEX idx_inventory_supplier ON inventory(supplier_id);
CREATE INDEX idx_inventory_expiry ON inventory(expiry_date);
CREATE INDEX idx_inventory_status ON inventory(status);
CREATE INDEX idx_inventory_production_date ON inventory(production_date);
-- 复合索引
CREATE INDEX idx_inventory_product_warehouse ON inventory(product_id, warehouse_id);
CREATE INDEX idx_inventory_warehouse_location ON inventory(warehouse_id, location_code);
CREATE INDEX idx_inventory_product_batch ON inventory(product_id, batch_number);
CREATE INDEX idx_inventory_warehouse_batch ON inventory(warehouse_id, batch_number);
CREATE INDEX idx_inventory_expiry_status ON inventory(expiry_date, status);

-- 库存流水表索引
CREATE INDEX idx_inv_trans_product ON inventory_transactions(product_id);
CREATE INDEX idx_inv_trans_warehouse ON inventory_transactions(warehouse_id);
CREATE INDEX idx_inv_trans_batch ON inventory_transactions(batch_number);
CREATE INDEX idx_inv_trans_type ON inventory_transactions(transaction_type);
CREATE INDEX idx_inv_trans_date ON inventory_transactions(created_at);
CREATE INDEX idx_inv_trans_operator ON inventory_transactions(operator_id);
CREATE INDEX idx_inv_trans_reference ON inventory_transactions(reference_type, reference_id);
CREATE INDEX idx_inv_trans_reference_code ON inventory_transactions(reference_code);
-- 复合索引
CREATE INDEX idx_inv_trans_product_date ON inventory_transactions(product_id, created_at);
CREATE INDEX idx_inv_trans_warehouse_date ON inventory_transactions(warehouse_id, created_at);
CREATE INDEX idx_inv_trans_type_date ON inventory_transactions(transaction_type, created_at);
CREATE INDEX idx_inv_trans_product_type ON inventory_transactions(product_id, transaction_type);

-- 库存预警表索引
CREATE INDEX idx_inv_alerts_product ON inventory_alerts(product_id);
CREATE INDEX idx_inv_alerts_warehouse ON inventory_alerts(warehouse_id);
CREATE INDEX idx_inv_alerts_enabled ON inventory_alerts(alert_enabled);
CREATE INDEX idx_inv_alerts_product_warehouse ON inventory_alerts(product_id, warehouse_id);

-- 盘点相关表索引
CREATE INDEX idx_stock_counts_warehouse ON stock_counts(warehouse_id);
CREATE INDEX idx_stock_counts_date ON stock_counts(count_date);
CREATE INDEX idx_stock_counts_type ON stock_counts(count_type);
CREATE INDEX idx_stock_counts_status ON stock_counts(status);
CREATE INDEX idx_stock_counts_count_by ON stock_counts(count_by);

CREATE INDEX idx_stock_count_details_count ON stock_count_details(count_id);
CREATE INDEX idx_stock_count_details_product ON stock_count_details(product_id);
CREATE INDEX idx_stock_count_details_batch ON stock_count_details(batch_number);
CREATE INDEX idx_stock_count_details_location ON stock_count_details(location_code);
CREATE INDEX idx_stock_count_details_adjusted ON stock_count_details(adjusted);

-- 调拨相关表索引
CREATE INDEX idx_transfer_orders_from_warehouse ON transfer_orders(from_warehouse_id);
CREATE INDEX idx_transfer_orders_to_warehouse ON transfer_orders(to_warehouse_id);
CREATE INDEX idx_transfer_orders_date ON transfer_orders(transfer_date);
CREATE INDEX idx_transfer_orders_status ON transfer_orders(status);
CREATE INDEX idx_transfer_orders_created_by ON transfer_orders(created_by);
CREATE INDEX idx_transfer_orders_approved_by ON transfer_orders(approved_by);

CREATE INDEX idx_transfer_items_transfer ON transfer_order_items(transfer_id);
CREATE INDEX idx_transfer_items_product ON transfer_order_items(product_id);
CREATE INDEX idx_transfer_items_batch ON transfer_order_items(batch_number);

-- 采购订单表索引
CREATE INDEX idx_po_supplier ON purchase_orders(supplier_id);
CREATE INDEX idx_po_status ON purchase_orders(status);
CREATE INDEX idx_po_date ON purchase_orders(order_date);
CREATE INDEX idx_po_expected_date ON purchase_orders(expected_date);
CREATE INDEX idx_po_code ON purchase_orders(order_code);
CREATE INDEX idx_po_created_by ON purchase_orders(created_by);
CREATE INDEX idx_po_approved_by ON purchase_orders(approved_by);
CREATE INDEX idx_po_contract_number ON purchase_orders(contract_number);
-- 复合索引
CREATE INDEX idx_po_supplier_date ON purchase_orders(supplier_id, order_date);
CREATE INDEX idx_po_status_date ON purchase_orders(status, order_date);
CREATE INDEX idx_po_date_status ON purchase_orders(order_date, status);

CREATE INDEX idx_poi_order ON purchase_order_items(order_id);
CREATE INDEX idx_poi_product ON purchase_order_items(product_id);

-- 采购计划表索引
CREATE INDEX idx_procurement_plans_product ON procurement_plans(product_id);
CREATE INDEX idx_procurement_plans_supplier ON procurement_plans(supplier_id);
CREATE INDEX idx_procurement_plans_period ON procurement_plans(plan_period);
CREATE INDEX idx_procurement_plans_type ON procurement_plans(plan_type);
CREATE INDEX idx_procurement_plans_status ON procurement_plans(status);
CREATE INDEX idx_procurement_plans_created_by ON procurement_plans(created_by);
CREATE INDEX idx_procurement_plans_approved_by ON procurement_plans(approved_by);
CREATE INDEX idx_procurement_plans_created_at ON procurement_plans(created_at);
CREATE INDEX idx_procurement_plans_submitted_at ON procurement_plans(submitted_at);
CREATE INDEX idx_procurement_plans_approved_at ON procurement_plans(approved_at);

CREATE INDEX idx_procurement_plans_product_period ON procurement_plans(product_id, plan_period);
CREATE INDEX idx_procurement_plans_supplier_period ON procurement_plans(supplier_id, plan_period);
CREATE INDEX idx_procurement_plans_status_period ON procurement_plans(status, plan_period);
CREATE INDEX idx_procurement_plans_priority_status ON procurement_plans(priority, status);

-- 销售订单表索引
CREATE INDEX idx_so_customer ON sales_orders(customer_id);
CREATE INDEX idx_so_status ON sales_orders(status);
CREATE INDEX idx_so_date ON sales_orders(order_date);
CREATE INDEX idx_so_delivery_date ON sales_orders(delivery_date);
CREATE INDEX idx_so_sales_person ON sales_orders(sales_person);
CREATE INDEX idx_so_code ON sales_orders(order_code);
CREATE INDEX idx_so_created_by ON sales_orders(created_by);
CREATE INDEX idx_so_approved_by ON sales_orders(approved_by);
-- 复合索引
CREATE INDEX idx_so_customer_date ON sales_orders(customer_id, order_date);
CREATE INDEX idx_so_status_date ON sales_orders(status, order_date);
CREATE INDEX idx_so_sales_person_date ON sales_orders(sales_person, order_date);

CREATE INDEX idx_soi_order ON sales_order_items(order_id);
CREATE INDEX idx_soi_product ON sales_order_items(product_id);

-- 收货记录表索引
CREATE INDEX idx_receiving_records_order ON receiving_records(order_id);
CREATE INDEX idx_receiving_records_supplier ON receiving_records(supplier_id);
CREATE INDEX idx_receiving_records_warehouse ON receiving_records(warehouse_id);
CREATE INDEX idx_receiving_records_date ON receiving_records(received_date);
CREATE INDEX idx_receiving_records_status ON receiving_records(status);
CREATE INDEX idx_receiving_records_code ON receiving_records(record_code);

CREATE INDEX idx_receiving_items_receiving ON receiving_record_items(receiving_id);
CREATE INDEX idx_receiving_items_product ON receiving_record_items(product_id);
CREATE INDEX idx_receiving_items_batch ON receiving_record_items(batch_number);

-- 出库单表索引
CREATE INDEX idx_delivery_orders_order ON delivery_orders(order_id);
CREATE INDEX idx_delivery_orders_customer ON delivery_orders(customer_id);
CREATE INDEX idx_delivery_orders_warehouse ON delivery_orders(warehouse_id);
CREATE INDEX idx_delivery_orders_date ON delivery_orders(delivery_date);
CREATE INDEX idx_delivery_orders_status ON delivery_orders(status);
CREATE INDEX idx_delivery_orders_code ON delivery_orders(delivery_code);
CREATE INDEX idx_delivery_orders_ship_date ON delivery_orders(actual_ship_date);

CREATE INDEX idx_delivery_items_delivery ON delivery_order_items(delivery_id);
CREATE INDEX idx_delivery_items_product ON delivery_order_items(product_id);
CREATE INDEX idx_delivery_items_batch ON delivery_order_items(batch_number);

-- 批次追溯表索引
CREATE INDEX idx_batch_traceability_batch ON batch_traceability(batch_number);
CREATE INDEX idx_batch_traceability_product ON batch_traceability(product_id);
CREATE INDEX idx_batch_traceability_manufacturer ON batch_traceability(manufacturer);
CREATE INDEX idx_batch_traceability_production_date ON batch_traceability(production_date);
CREATE INDEX idx_batch_traceability_expiry_date ON batch_traceability(expiry_date);
CREATE INDEX idx_batch_traceability_grade ON batch_traceability(quality_grade);
CREATE INDEX idx_batch_traceability_status ON batch_traceability(status);

-- 库存预留表索引
CREATE INDEX idx_inventory_reservations_inventory ON inventory_reservations(inventory_id);
CREATE INDEX idx_inventory_reservations_reference ON inventory_reservations(reference_type, reference_id);
CREATE INDEX idx_inventory_reservations_date ON inventory_reservations(reservation_date);
CREATE INDEX idx_inventory_reservations_expiry ON inventory_reservations(expiry_date);
CREATE INDEX idx_inventory_reservations_status ON inventory_reservations(status);
CREATE INDEX idx_inventory_reservations_priority ON inventory_reservations(priority);

-- 供应商评估表索引
CREATE INDEX idx_supplier_evaluations_supplier ON supplier_evaluations(supplier_id);
CREATE INDEX idx_supplier_evaluations_period ON supplier_evaluations(evaluation_period);
CREATE INDEX idx_supplier_evaluations_date ON supplier_evaluations(evaluation_date);
CREATE INDEX idx_supplier_evaluations_grade ON supplier_evaluations(grade);
CREATE INDEX idx_supplier_evaluations_score ON supplier_evaluations(total_score);
CREATE INDEX idx_supplier_evaluations_status ON supplier_evaluations(status);

-- 价格历史表索引
CREATE INDEX idx_product_price_history_product ON product_price_history(product_id);
CREATE INDEX idx_product_price_history_supplier ON product_price_history(supplier_id);
CREATE INDEX idx_product_price_history_customer ON product_price_history(customer_id);
CREATE INDEX idx_product_price_history_type ON product_price_history(price_type);
CREATE INDEX idx_product_price_history_effective ON product_price_history(effective_date);
CREATE INDEX idx_product_price_history_status ON product_price_history(status);
CREATE INDEX idx_product_price_history_product_type ON product_price_history(product_id, price_type);

-- 质量检验表索引
CREATE INDEX idx_qi_product ON quality_inspections(product_id);
CREATE INDEX idx_qi_batch ON quality_inspections(batch_number);
CREATE INDEX idx_qi_supplier ON quality_inspections(supplier_id);
CREATE INDEX idx_qi_date ON quality_inspections(inspection_date);
CREATE INDEX idx_qi_type ON quality_inspections(inspection_type);
CREATE INDEX idx_qi_result ON quality_inspections(conclusion);
CREATE INDEX idx_qi_inspector ON quality_inspections(inspector);
CREATE INDEX idx_qi_supervisor ON quality_inspections(supervisor);

-- 用户管理表索引
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_status ON users(status);
CREATE INDEX idx_users_department ON users(department_id);
CREATE INDEX idx_users_manager ON users(manager_id);
CREATE INDEX idx_users_is_admin ON users(is_admin);
CREATE INDEX idx_users_last_login ON users(last_login_time);

-- 角色表索引
CREATE INDEX idx_roles_code ON roles(role_code);
CREATE INDEX idx_roles_name ON roles(role_name);
CREATE INDEX idx_roles_parent ON roles(parent_role_id);
CREATE INDEX idx_roles_level ON roles(level);
CREATE INDEX idx_roles_status ON roles(status);

-- 权限表索引
CREATE INDEX idx_permissions_code ON permissions(permission_code);
CREATE INDEX idx_permissions_type ON permissions(permission_type);
CREATE INDEX idx_permissions_module ON permissions(module);
CREATE INDEX idx_permissions_parent ON permissions(parent_permission_id);
CREATE INDEX idx_permissions_menu ON permissions(is_menu);

-- 关联表索引
CREATE INDEX idx_user_roles_user ON user_roles(user_id);
CREATE INDEX idx_user_roles_role ON user_roles(role_id);
CREATE INDEX idx_user_roles_status ON user_roles(status);

CREATE INDEX idx_role_permissions_role ON role_permissions(role_id);
CREATE INDEX idx_role_permissions_permission ON role_permissions(permission_id);

-- 系统配置表索引
CREATE INDEX idx_system_configs_group ON system_configs(config_group);
CREATE INDEX idx_system_configs_key ON system_configs(config_key);
CREATE INDEX idx_system_configs_group_key ON system_configs(config_group, config_key);

-- =====================================================
-- 第十一步：创建触发器
-- =====================================================

-- 为表创建更新时间戳触发器
CREATE TRIGGER trigger_update_products_updated_at 
    BEFORE UPDATE ON products 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trigger_update_suppliers_updated_at 
    BEFORE UPDATE ON suppliers 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trigger_update_customers_updated_at 
    BEFORE UPDATE ON customers 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trigger_update_warehouses_updated_at 
    BEFORE UPDATE ON warehouses 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trigger_update_inventory_alerts_updated_at 
    BEFORE UPDATE ON inventory_alerts 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trigger_update_purchase_orders_updated_at 
    BEFORE UPDATE ON purchase_orders 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trigger_update_procurement_plans_updated_at 
    BEFORE UPDATE ON procurement_plans 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trigger_update_sales_orders_updated_at 
    BEFORE UPDATE ON sales_orders 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trigger_update_roles_updated_at 
    BEFORE UPDATE ON roles 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trigger_update_system_configs_updated_at 
    BEFORE UPDATE ON system_configs 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trigger_update_batch_traceability_updated_at 
    BEFORE UPDATE ON batch_traceability 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 创建库存流水触发器
CREATE TRIGGER trigger_update_inventory_timestamp
    AFTER INSERT ON inventory_transactions
    FOR EACH ROW EXECUTE FUNCTION update_inventory_from_transaction();

-- 为新增表创建更新时间戳触发器
CREATE TRIGGER trigger_update_safety_inspections_updated_at 
    BEFORE UPDATE ON safety_inspections 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trigger_update_environment_monitoring_updated_at 
    BEFORE UPDATE ON environment_monitoring 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trigger_update_hazmat_shipments_updated_at 
    BEFORE UPDATE ON hazmat_shipments 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trigger_update_safety_incidents_updated_at 
    BEFORE UPDATE ON safety_incidents 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trigger_update_safety_training_updated_at 
    BEFORE UPDATE ON safety_training 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trigger_update_safety_certificates_updated_at 
    BEFORE UPDATE ON safety_certificates 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trigger_update_report_templates_updated_at 
    BEFORE UPDATE ON report_templates 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trigger_update_scheduled_tasks_updated_at 
    BEFORE UPDATE ON scheduled_tasks 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trigger_update_analysis_metrics_updated_at 
    BEFORE UPDATE ON analysis_metrics 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trigger_update_dashboard_configs_updated_at 
    BEFORE UPDATE ON dashboard_configs 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trigger_update_return_orders_updated_at 
    BEFORE UPDATE ON return_orders 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trigger_update_customer_visits_updated_at 
    BEFORE UPDATE ON customer_visits 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- 第十二步：创建视图
-- =====================================================

-- 库存汇总视图（带索引优化）
CREATE MATERIALIZED VIEW mv_inventory_summary AS
SELECT 
    p.id as product_id,
    p.product_code,
    p.product_name,
    p.battery_type,
    w.id as warehouse_id,
    w.warehouse_code,
    w.warehouse_name,
    SUM(i.quantity) as total_quantity,
    SUM(i.available_quantity) as available_quantity,
    SUM(i.reserved_quantity) as reserved_quantity,
    SUM(i.damaged_quantity) as damaged_quantity,
    AVG(i.unit_cost) as avg_unit_cost,
    SUM(i.quantity * COALESCE(i.unit_cost, 0)) as total_value,
    COUNT(DISTINCT i.batch_number) as batch_count,
    MIN(i.expiry_date) as earliest_expiry_date,
    MAX(i.last_updated) as last_updated
FROM inventory i
JOIN products p ON i.product_id = p.id
JOIN warehouses w ON i.warehouse_id = w.id
WHERE p.status = 'active' AND w.status = 'active'
GROUP BY p.id, p.product_code, p.product_name, p.battery_type, 
         w.id, w.warehouse_code, w.warehouse_name;

-- 为物化视图创建索引
CREATE INDEX idx_mv_inventory_summary_product ON mv_inventory_summary(product_id);
CREATE INDEX idx_mv_inventory_summary_warehouse ON mv_inventory_summary(warehouse_id);
CREATE INDEX idx_mv_inventory_summary_product_warehouse ON mv_inventory_summary(product_id, warehouse_id);
CREATE INDEX idx_mv_inventory_summary_available_qty ON mv_inventory_summary(available_quantity);

-- 库存预警视图
CREATE VIEW view_inventory_alerts AS
SELECT 
    p.id as product_id,
    p.product_code,
    p.product_name,
    w.id as warehouse_id,
    w.warehouse_code,
    w.warehouse_name,
    SUM(i.available_quantity) as current_stock,
    a.min_quantity,
    a.reorder_point,
    CASE 
        WHEN SUM(i.available_quantity) <= a.min_quantity THEN 'critical'
        WHEN SUM(i.available_quantity) <= a.reorder_point THEN 'warning'
        ELSE 'normal'
    END as alert_level,
    GREATEST(0, a.reorder_point - SUM(i.available_quantity)) as shortage_quantity
FROM inventory i
JOIN products p ON i.product_id = p.id
JOIN warehouses w ON i.warehouse_id = w.id
JOIN inventory_alerts a ON a.product_id = p.id AND (a.warehouse_id = w.id OR a.warehouse_id IS NULL)
WHERE p.status = 'active' AND w.status = 'active' AND a.alert_enabled = true
GROUP BY p.id, p.product_code, p.product_name, w.id, w.warehouse_code, w.warehouse_name,
         a.min_quantity, a.reorder_point
HAVING SUM(i.available_quantity) <= COALESCE(a.reorder_point, a.min_quantity);

-- 即将过期库存视图
CREATE VIEW view_expiring_inventory AS
SELECT 
    i.id,
    p.product_code,
    p.product_name,
    w.warehouse_code,
    w.warehouse_name,
    i.batch_number,
    i.location_code,
    i.available_quantity,
    i.production_date,
    i.expiry_date,
    (i.expiry_date - CURRENT_DATE) as days_to_expire,
    CASE 
        WHEN i.expiry_date <= CURRENT_DATE THEN 'expired'
        WHEN i.expiry_date <= CURRENT_DATE + INTERVAL '7 days' THEN 'critical'
        WHEN i.expiry_date <= CURRENT_DATE + INTERVAL '30 days' THEN 'warning'
        ELSE 'normal'
    END as expiry_status
FROM inventory i
JOIN products p ON i.product_id = p.id
JOIN warehouses w ON i.warehouse_id = w.id
WHERE i.expiry_date IS NOT NULL 
  AND i.available_quantity > 0
  AND i.expiry_date <= CURRENT_DATE + INTERVAL '90 days'
ORDER BY i.expiry_date;

-- 订单完成度视图
CREATE VIEW view_order_completion AS
SELECT 
    'purchase' as order_type,
    po.id as order_id,
    po.order_code,
    po.supplier_id as partner_id,
    s.supplier_name as partner_name,
    po.order_date,
    po.expected_date,
    po.status,
    SUM(poi.quantity) as total_quantity,
    SUM(poi.received_quantity) as completed_quantity,
    CASE 
        WHEN SUM(poi.quantity) = 0 THEN 0
        ELSE (SUM(poi.received_quantity) / SUM(poi.quantity) * 100)::DECIMAL(5,2)
    END as completion_rate,
    po.final_amount as total_amount
FROM purchase_orders po
JOIN purchase_order_items poi ON po.id = poi.order_id
JOIN suppliers s ON po.supplier_id = s.id
GROUP BY po.id, po.order_code, po.supplier_id, s.supplier_name, po.order_date, po.expected_date, po.status, po.final_amount

UNION ALL

SELECT 
    'sales' as order_type,
    so.id as order_id,
    so.order_code,
    so.customer_id as partner_id,
    c.customer_name as partner_name,
    so.order_date,
    so.delivery_date as expected_date,
    so.status,
    SUM(soi.quantity) as total_quantity,
    SUM(soi.shipped_quantity) as completed_quantity,
    CASE 
        WHEN SUM(soi.quantity) = 0 THEN 0
        ELSE (SUM(soi.shipped_quantity) / SUM(soi.quantity) * 100)::DECIMAL(5,2)
    END as completion_rate,
    so.final_amount as total_amount
FROM sales_orders so
JOIN sales_order_items soi ON so.id = soi.order_id
JOIN customers c ON so.customer_id = c.id
GROUP BY so.id, so.order_code, so.customer_id, c.customer_name, so.order_date, so.delivery_date, so.status, so.final_amount;

-- 供应商业绩统计视图
CREATE VIEW view_supplier_performance AS
SELECT 
    s.id as supplier_id,
    s.supplier_code,
    s.supplier_name,
    s.cooperation_level,
    COUNT(DISTINCT po.id) as total_orders,
    COUNT(DISTINCT CASE WHEN po.status = 'completed' THEN po.id END) as completed_orders,
    SUM(po.final_amount) as total_amount,
    SUM(CASE WHEN po.status = 'completed' THEN po.final_amount ELSE 0 END) as completed_amount,
    AVG(CASE 
        WHEN po.expected_date IS NOT NULL AND po.approved_at IS NOT NULL 
        THEN po.expected_date - po.approved_at::date 
    END) as avg_delivery_days,
    COUNT(DISTINCT qi.id) as quality_inspections,
    COUNT(DISTINCT CASE WHEN qi.conclusion = 'qualified' THEN qi.id END) as qualified_inspections,
    CASE 
        WHEN COUNT(DISTINCT qi.id) = 0 THEN NULL
        ELSE (COUNT(DISTINCT CASE WHEN qi.conclusion = 'qualified' THEN qi.id END)::DECIMAL / COUNT(DISTINCT qi.id) * 100)::DECIMAL(5,2)
    END as qualification_rate
FROM suppliers s
LEFT JOIN purchase_orders po ON s.id = po.supplier_id
LEFT JOIN quality_inspections qi ON s.id = qi.supplier_id
WHERE s.status = 'active'
GROUP BY s.id, s.supplier_code, s.supplier_name, s.cooperation_level;

-- 客户销售统计视图
CREATE VIEW view_customer_sales AS
SELECT 
    c.id as customer_id,
    c.customer_code,
    c.customer_name,
    c.customer_type,
    c.industry,
    COUNT(DISTINCT so.id) as total_orders,
    COUNT(DISTINCT CASE WHEN so.status = 'completed' THEN so.id END) as completed_orders,
    SUM(so.final_amount) as total_amount,
    SUM(CASE WHEN so.status = 'completed' THEN so.final_amount ELSE 0 END) as completed_amount,
    AVG(so.final_amount) as avg_order_amount,
    MAX(so.order_date) as last_order_date,
    COUNT(DISTINCT EXTRACT(YEAR FROM so.order_date)||'-'||EXTRACT(MONTH FROM so.order_date)) as active_months
FROM customers c
LEFT JOIN sales_orders so ON c.id = so.customer_id
WHERE c.status = 'active'
GROUP BY c.id, c.customer_code, c.customer_name, c.customer_type, c.industry;

-- 产品销售统计视图
CREATE VIEW view_product_sales AS
SELECT 
    p.id as product_id,
    p.product_code,
    p.product_name,
    p.battery_type,
    p.series,
    COUNT(DISTINCT soi.order_id) as order_count,
    SUM(soi.quantity) as total_sold_quantity,
    SUM(soi.shipped_quantity) as total_shipped_quantity,
    SUM(soi.total_price) as total_sales_amount,
    AVG(soi.unit_price) as avg_unit_price,
    MAX(so.order_date) as last_sale_date,
    COUNT(DISTINCT so.customer_id) as customer_count
FROM products p
LEFT JOIN sales_order_items soi ON p.id = soi.product_id
LEFT JOIN sales_orders so ON soi.order_id = so.id AND so.status IN ('approved', 'completed')
WHERE p.status = 'active'
GROUP BY p.id, p.product_code, p.product_name, p.battery_type, p.series;

-- =====================================================
-- 第十三步：插入初始数据
-- =====================================================

-- 插入系统管理员用户
INSERT INTO users (username, email, password_hash, full_name, is_admin, status) VALUES 
('admin', 'admin@bolink.com', '$2b$10$rOKsEZpR1hJlTnF8kBYOQu9XPn8sNXz5PnJ5lCJqCcK3WnW8vDlp6', '系统管理员', true, 'active');

-- 插入系统角色
INSERT INTO roles (role_code, role_name, description, is_system_role, status) VALUES 
('ADMIN', '系统管理员', '系统管理员角色，拥有所有权限', true, 'active'),
('MANAGER', '管理者', '部门管理者角色', true, 'active'),
('USER', '普通用户', '普通用户角色', true, 'active'),
('WAREHOUSE_MANAGER', '仓库管理员', '仓库管理员角色', true, 'active'),
('PURCHASER', '采购员', '采购员角色', true, 'active'),
('SALES_REP', '销售代表', '销售代表角色', true, 'active'),
('QC_INSPECTOR', '质检员', '质量检验员角色', true, 'active');

-- 插入基础权限
INSERT INTO permissions (permission_code, permission_name, permission_type, resource, action, module) VALUES 
('SYSTEM:ALL', '系统全部权限', 'system', '*', '*', 'system'),
('BASIC_DATA:READ', '基础数据查看', 'business', 'basic_data', 'read', 'basic_data'),
('BASIC_DATA:WRITE', '基础数据编辑', 'business', 'basic_data', 'write', 'basic_data'),
('INVENTORY:READ', '库存查看', 'business', 'inventory', 'read', 'inventory'),
('INVENTORY:WRITE', '库存编辑', 'business', 'inventory', 'write', 'inventory'),
('INVENTORY:COUNT', '库存盘点', 'business', 'inventory', 'count', 'inventory'),
('INVENTORY:TRANSFER', '库存调拨', 'business', 'inventory', 'transfer', 'inventory'),
('PROCUREMENT:READ', '采购查看', 'business', 'procurement', 'read', 'procurement'),
('PROCUREMENT:WRITE', '采购编辑', 'business', 'procurement', 'write', 'procurement'),
('PROCUREMENT:APPROVE', '采购审批', 'business', 'procurement', 'approve', 'procurement'),
('SALES:READ', '销售查看', 'business', 'sales', 'read', 'sales'),
('SALES:WRITE', '销售编辑', 'business', 'sales', 'write', 'sales'),
('SALES:APPROVE', '销售审批', 'business', 'sales', 'approve', 'sales'),
('QUALITY:READ', '质量查看', 'business', 'quality', 'read', 'quality'),
('QUALITY:WRITE', '质量编辑', 'business', 'quality', 'write', 'quality'),
('QUALITY:INSPECT', '质量检验', 'business', 'quality', 'inspect', 'quality'),
('SAFETY:READ', '安全查看', 'business', 'safety', 'read', 'safety'),
('SAFETY:WRITE', '安全编辑', 'business', 'safety', 'write', 'safety'),
('REPORTS:READ', '报表查看', 'business', 'reports', 'read', 'reports'),
('REPORTS:EXPORT', '报表导出', 'business', 'reports', 'export', 'reports'),
('SYSTEM:USER_MANAGE', '用户管理', 'system', 'users', 'manage', 'system'),
('SYSTEM:ROLE_MANAGE', '角色管理', 'system', 'roles', 'manage', 'system'),
('SYSTEM:CONFIG', '系统配置', 'system', 'config', 'manage', 'system');

-- 分配管理员角色给管理员用户
INSERT INTO user_roles (user_id, role_id, assigned_by) VALUES 
(1, 1, 1);

-- 分配所有权限给管理员角色
INSERT INTO role_permissions (role_id, permission_id, granted_by) 
SELECT 1, id, 1 FROM permissions;

-- 插入基础系统配置
INSERT INTO system_configs (config_group, config_key, config_value, description) VALUES 
('system', 'system_name', '新能源电池进销存管理系统', '系统名称'),
('system', 'version', '1.0.1', '系统版本'),
('system', 'company_name', 'Bolink新能源', '公司名称'),
('security', 'password_min_length', '8', '密码最小长度'),
('security', 'password_max_attempts', '5', '密码最大尝试次数'),
('security', 'session_timeout', '3600', '会话超时时间（秒）'),
('security', 'password_complexity', 'true', '是否启用密码复杂度检查'),
('business', 'default_currency', 'CNY', '默认货币'),
('business', 'inventory_warning_days', '7', '库存预警天数'),
('business', 'backup_retention_days', '30', '备份保留天数'),
('business', 'auto_approve_limit', '10000', '自动审批金额上限'),
('notification', 'email_enabled', 'true', '是否启用邮件通知'),
('notification', 'sms_enabled', 'false', '是否启用短信通知'),
('report', 'default_export_format', 'excel', '默认报表导出格式'),
('report', 'max_export_rows', '50000', '最大导出行数');

-- 插入示例产品数据
INSERT INTO products (product_code, product_name, model, series, battery_type, capacity, voltage, safety_level, status) VALUES 
('BT-20241201-001', '磷酸铁锂电池模组', 'LFP-100Ah-3.2V', 'LFP系列', '磷酸铁锂', 100.00, 3.20, 'A级', 'active'),
('BT-20241201-002', '三元锂电池包', 'NCM-50Ah-48V', 'NCM系列', '三元锂', 50.00, 48.00, 'A级', 'active'),
('BT-20241201-003', '储能电池系统', 'ESS-200Ah-400V', 'ESS系列', '磷酸铁锂', 200.00, 400.00, 'A级', 'active');

-- 插入示例仓库数据
INSERT INTO warehouses (warehouse_code, warehouse_name, warehouse_type, status) VALUES 
('WH-20241201-001', '北京主仓库', 'main', 'active'),
('WH-20241201-002', '上海分仓库', 'branch', 'active'),
('WH-20241201-003', '深圳中转仓', 'transit', 'active');

-- 插入示例供应商数据
INSERT INTO suppliers (supplier_code, supplier_name, supplier_type, cooperation_level, status) VALUES 
('SUP-20241201-001', '宁德时代新能源科技股份有限公司', 'manufacturer', 'strategic', 'active'),
('SUP-20241201-002', '比亚迪股份有限公司', 'manufacturer', 'important', 'active'),
('SUP-20241201-003', '国轩高科股份有限公司', 'manufacturer', 'general', 'active');

-- 插入示例客户数据
INSERT INTO customers (customer_code, customer_name, customer_type, industry, status) VALUES 
('CUS-20241201-001', '特斯拉（上海）有限公司', 'manufacturer', '新能源汽车', 'active'),
('CUS-20241201-002', '蔚来汽车有限公司', 'manufacturer', '新能源汽车', 'active'),
('CUS-20241201-003', '阳光电源股份有限公司', 'integrator', '储能系统', 'active');

-- 插入示例库存数据
INSERT INTO inventory (product_id, warehouse_id, location_code, batch_number, quantity, available_quantity, reserved_quantity, damaged_quantity, unit_cost, production_date, expiry_date, supplier_id, status) VALUES 
(1, 1, 'A-01-01', 'BATCH-20241101-001', 500.000, 450.000, 50.000, 0.000, 1200.0000, '2024-11-01', '2027-11-01', 1, 'available'),
(1, 1, 'A-01-02', 'BATCH-20241115-002', 300.000, 300.000, 0.000, 0.000, 1180.0000, '2024-11-15', '2027-11-15', 1, 'available'),
(2, 1, 'B-02-01', 'BATCH-20241110-003', 200.000, 150.000, 30.000, 20.000, 2500.0000, '2024-11-10', '2027-11-10', 2, 'available'),
(3, 2, 'A-01-01', 'BATCH-20241120-004', 50.000, 45.000, 5.000, 0.000, 15000.0000, '2024-11-20', '2027-11-20', 1, 'available'),
(1, 2, 'A-02-01', 'BATCH-20241125-005', 400.000, 380.000, 20.000, 0.000, 1190.0000, '2024-11-25', '2027-11-25', 1, 'available');

-- 插入库存预警设置
INSERT INTO inventory_alerts (product_id, warehouse_id, min_quantity, max_quantity, reorder_point, economic_order_quantity, lead_time_days, safety_stock, alert_enabled) VALUES 
(1, 1, 100.000, 1000.000, 200.000, 500.000, 15, 50.000, true),
(1, 2, 50.000, 500.000, 100.000, 300.000, 20, 30.000, true),
(2, 1, 50.000, 300.000, 80.000, 150.000, 10, 20.000, true),
(3, 2, 10.000, 100.000, 20.000, 50.000, 30, 5.000, true);

-- 插入批次追溯数据
INSERT INTO batch_traceability (batch_number, product_id, manufacturer, production_date, production_line, production_shift, quality_grade, expiry_date, shelf_life_days, status) VALUES 
('BATCH-20241101-001', 1, '宁德时代新能源科技股份有限公司', '2024-11-01', 'LINE-01', 'DAY-SHIFT', 'A级', '2027-11-01', 1095, 'active'),
('BATCH-20241115-002', 1, '宁德时代新能源科技股份有限公司', '2024-11-15', 'LINE-02', 'NIGHT-SHIFT', 'A级', '2027-11-15', 1095, 'active'),
('BATCH-20241110-003', 2, '比亚迪股份有限公司', '2024-11-10', 'LINE-01', 'DAY-SHIFT', 'A级', '2027-11-10', 1095, 'active'),
('BATCH-20241120-004', 3, '宁德时代新能源科技股份有限公司', '2024-11-20', 'LINE-03', 'DAY-SHIFT', 'A级', '2027-11-20', 1095, 'active'),
('BATCH-20241125-005', 1, '宁德时代新能源科技股份有限公司', '2024-11-25', 'LINE-01', 'DAY-SHIFT', 'A级', '2027-11-25', 1095, 'active');

-- 插入示例价格数据
INSERT INTO product_price_history (product_id, supplier_id, price_type, unit_price, currency, effective_date, status, created_by) VALUES 
(1, 1, 'purchase', 1200.0000, 'CNY', '2024-11-01', 'active', 1),
(1, 1, 'purchase', 1180.0000, 'CNY', '2024-11-15', 'active', 1),
(2, 2, 'purchase', 2500.0000, 'CNY', '2024-11-01', 'active', 1),
(3, 1, 'purchase', 15000.0000, 'CNY', '2024-11-01', 'active', 1);

INSERT INTO product_price_history (product_id, customer_id, price_type, unit_price, currency, effective_date, status, created_by) VALUES 
(1, 1, 'sales', 1450.0000, 'CNY', '2024-11-01', 'active', 1),
(2, 2, 'sales', 3200.0000, 'CNY', '2024-11-01', 'active', 1),
(3, 3, 'sales', 18000.0000, 'CNY', '2024-11-01', 'active', 1);

-- 插入供应商评估数据
INSERT INTO supplier_evaluations (supplier_id, evaluation_period, evaluation_date, evaluator, delivery_score, quality_score, service_score, cost_score, compliance_score, total_score, grade, status) VALUES 
(1, '2024Q3', '2024-10-01', 1, 95.00, 98.00, 92.00, 88.00, 96.00, 93.80, 'A', 'active'),
(2, '2024Q3', '2024-10-01', 1, 88.00, 95.00, 90.00, 92.00, 94.00, 91.80, 'A', 'active'),
(3, '2024Q3', '2024-10-01', 1, 85.00, 88.00, 86.00, 90.00, 89.00, 87.60, 'B', 'active');

-- 插入安全培训记录
INSERT INTO safety_training (training_code, training_topic, training_date, trainer, attendees, training_content, created_by) VALUES 
('ST-20241201-001', '危险品安全操作培训', '2024-11-15', '张安全', '["张三", "李四", "王五"]', '电池安全操作规范、应急处理流程、个人防护要求', 1),
('ST-20241201-002', '消防安全培训', '2024-11-20', '李消防', '["赵六", "钱七", "孙八"]', '消防设备使用、火灾预防、疏散演练', 1);

-- 插入安全资质证照
INSERT INTO safety_certificates (certificate_type, certificate_number, issuing_authority, issue_date, expiry_date, scope, status, responsible_person) VALUES 
('hazmat_license', 'HZ-2024-001', '应急管理部', '2024-01-01', '2027-01-01', '危险品经营许可', 'active', 1),
('safety_license', 'SA-2024-001', '应急管理部', '2024-01-01', '2027-01-01', '安全生产许可', 'active', 1);

-- 插入报表模板示例数据
INSERT INTO report_templates (template_code, template_name, template_type, template_config, data_source, output_format, created_by) VALUES 
('RT-20241201-001', '库存日报表', 'inventory', '{"layout": "table", "columns": ["产品编码", "产品名称", "库存数量", "可用数量"]}', 'inventory', 'excel', 1),
('RT-20241201-002', '销售月报表', 'sales', '{"layout": "chart", "chart_type": "bar", "dimensions": ["客户", "销售额"]}', 'sales_orders', 'excel', 1);

-- 插入分析指标示例数据
INSERT INTO analysis_metrics (metric_code, metric_name, metric_type, calculation_formula, unit, target_value, created_by) VALUES 
('AM-20241201-001', '库存周转率', 'inventory', '出库数量 / 平均库存', '次/年', 12.00, 1),
('AM-20241201-002', '客户满意度', 'sales', '满意客户数 / 总客户数 * 100', '%', 95.00, 1);

-- 插入更多安全管理示例数据
INSERT INTO safety_inspections (inspection_code, inspection_type, inspection_date, warehouse_id, inspector, supervisor, inspection_scope, inspection_findings, risk_level, status, created_at) VALUES 
('SI-20241201-001', 'warehouse', '2024-11-25', 1, 1, 1, '{"areas": ["A区", "B区"], "equipment": ["消防设备", "通风系统"]}', '{"消防设备": "正常", "通风系统": "需要维护", "温度控制": "正常"}', 'medium', 'completed', '2024-11-25 09:00:00'),
('SI-20241201-002', 'equipment', '2024-11-26', 1, 1, 1, '{"equipment": ["叉车", "升降机", "监控系统"]}', '{"叉车": "正常", "升降机": "需要检修", "监控系统": "正常"}', 'low', 'completed', '2024-11-26 14:00:00');

INSERT INTO environment_monitoring (monitoring_code, warehouse_id, monitoring_type, monitoring_date, temperature, humidity, air_quality, alert_threshold, equipment_status, data_source) VALUES 
('EM-20241201-001', 1, 'comprehensive', '2025-08-24 08:00:00', 22.5, 45.2, '{"pm25": 15, "co2": 800, "voc": 0.5}', '{"temperature": {"min": 15, "max": 30}, "humidity": {"min": 30, "max": 70}}', 'normal', 'sensor_system'),
('EM-20241201-002', 1, 'comprehensive', '2025-08-24 12:00:00', 25.8, 48.1, '{"pm25": 18, "co2": 850, "voc": 0.6}', '{"temperature": {"min": 15, "max": 30}, "humidity": {"min": 30, "max": 70}}', 'normal', 'sensor_system');

INSERT INTO hazmat_shipments (shipment_code, customer_id, carrier, vehicle_number, driver_name, driver_license, contact_phone, shipment_date, expected_delivery_date, route_plan, safety_equipment, emergency_contacts, status, created_by) VALUES 
('HM-20241201-001', 1, '顺丰速运', '京A12345', '张师傅', 'A123456789', '13800138001', '2024-11-28', '2024-11-30', '{"route": ["北京", "天津", "上海"], "rest_stops": ["天津服务区", "济南服务区"]}', '{"fire_extinguisher": true, "first_aid_kit": true, "spill_kit": true}', '{"emergency_contact": "李经理", "phone": "13900139001", "backup": "王经理", "backup_phone": "13700137001"}', 'delivered', 1);

INSERT INTO safety_incidents (incident_code, incident_type, incident_date, location, warehouse_id, severity_level, incident_description, root_cause, immediate_actions, affected_persons, investigation_status, status, reported_by) VALUES 
('SA-20241201-001', 'equipment_failure', '2024-11-20 10:30:00', 'B区货架区域', 1, 'minor', '货架轻微变形，无人员伤亡', '货物堆放过重', '立即停止使用该货架，转移货物', '["操作员张三"]', 'completed', 'resolved', 1);

-- 插入退换货示例数据
INSERT INTO return_orders (return_code, customer_id, return_type, return_reason, return_date, total_quantity, total_amount, status, handled_by) VALUES 
('RO-20241201-001', 1, 'return', '客户需求变更，取消订单', '2024-11-25', 50.000, 72500.00, 'processed', 1),
('RO-20241201-002', 2, 'exchange', '产品规格不符合要求', '2024-11-26', 20.000, 64000.00, 'pending', 1);

-- 插入客户回访示例数据
INSERT INTO customer_visits (customer_id, visit_date, visit_type, visit_purpose, visit_content, customer_feedback, next_action, sales_person) VALUES 
(1, '2024-11-20', 'regular', '定期客户回访', '了解客户使用情况，收集反馈意见', '对产品质量和服务很满意，希望增加技术支持', '安排技术人员上门培训', 1),
(2, '2024-11-22', 'follow_up', '订单跟进回访', '确认订单执行情况，了解客户需求', '希望提供更多产品选择，价格有竞争力', '提供新产品目录和报价', 1);

-- 插入定时任务示例数据
INSERT INTO scheduled_tasks (task_code, task_name, task_type, task_config, schedule_config, is_active, created_by) VALUES 
('ST-20241201-001', '库存日报生成', 'report_generation', '{"template_id": 1, "parameters": {"warehouse_id": "all"}}', '{"type": "daily", "time": "06:00:00"}', true, 1),
('ST-20241201-002', '数据清理任务', 'cleanup', '{"retention_days": 90, "tables": ["operation_logs", "report_generations"]}', '{"type": "weekly", "day": "sunday", "time": "02:00:00"}', true, 1);

-- 插入采购计划示例数据
INSERT INTO procurement_plans (plan_code, plan_period, plan_type, product_id, supplier_id, planned_quantity, planned_amount, estimated_unit_price, priority, reason, demand_source, safety_stock_trigger, status, created_by) VALUES 
('PP-20241201-001', '2024Q4', 'inventory_driven', 1, 1, 1000.000, 1200000.00, 1200.0000, 3, '安全库存触发，需要补充库存', 'safety_stock', true, 'approved', 1),
('PP-20241201-002', '2024Q4', 'sales_forecast', 2, 2, 500.000, 1250000.00, 2500.0000, 2, '销售预测显示需求增长', 'sales_forecast', false, 'submitted', 1),
('PP-20241201-003', '2024Q4', 'seasonal', 3, 1, 100.000, 1500000.00, 15000.0000, 1, '季节性需求高峰准备', 'seasonal', false, 'draft', 1);

-- 插入仪表板配置示例数据
INSERT INTO dashboard_configs (dashboard_code, dashboard_name, layout_config, widget_configs, access_roles, refresh_interval, created_by) VALUES 
('DC-20241201-001', '管理层仪表板', '{"layout": "grid", "columns": 3, "rows": 4}', '{"widgets": [{"type": "chart", "title": "销售趋势", "config": {"chart_type": "line"}}, {"type": "metric", "title": "库存周转率", "config": {"metric_id": 1}}]}', '["ADMIN", "MANAGER"]', 300, 1),
('DC-20241201-002', '仓库管理仪表板', '{"layout": "grid", "columns": 2, "rows": 3}', '{"widgets": [{"type": "table", "title": "库存预警", "config": {"data_source": "inventory_alerts"}}, {"type": "chart", "title": "库存分布", "config": {"chart_type": "pie"}}]}', '["WAREHOUSE_MANAGER"]', 600, 1);

-- =====================================================
