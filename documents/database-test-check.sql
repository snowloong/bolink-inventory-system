-- =====================================================
-- 新能源电池进销存信息管理系统 - 数据库测试检查脚本
-- 版本: 1.0.0
-- 数据库: PostgreSQL 14+
-- 创建时间: 2025-08-24
-- 用途: 检查数据库对象是否存在
-- =====================================================

-- =====================================================
-- 第一部分：检查表是否存在
-- =====================================================

DO $$
DECLARE
    table_record RECORD;
    missing_tables TEXT[] := ARRAY[]::TEXT[];
    existing_tables TEXT[] := ARRAY[]::TEXT[];
    expected_tables TEXT[] := ARRAY[
        -- 基础数据表
        'products',
        'suppliers', 
        'customers',
        'warehouses',
        'users',
        'roles',
        'permissions',
        'user_roles',
        'role_permissions',
        'system_configs',
        
        -- 库存管理表
        'inventory',
        'inventory_transactions',
        'inventory_alerts',
        'stock_counts',
        'stock_count_details',
        'transfer_orders',
        'transfer_order_items',
        'inventory_reservations',
        
        -- 采购管理表
        'purchase_orders',
        'purchase_order_items',
        'procurement_plans',
        'receiving_records',
        'receiving_record_items',
        'supplier_evaluations',
        
        -- 销售管理表
        'sales_orders',
        'sales_order_items',
        'delivery_orders',
        'delivery_order_items',
        'return_orders',
        'customer_visits',
        
        -- 质量管理表
        'quality_inspections',
        'batch_traceability',
        
        -- 安全管理表
        'safety_inspections',
        'environment_monitoring',
        'hazmat_shipments',
        'safety_incidents',
        'safety_training',
        'safety_certificates',
        
        -- 报表统计表
        'report_templates',
        'report_generations',
        'scheduled_tasks',
        'analysis_metrics',
        'metric_values',
        'dashboard_configs',
        
        -- 价格管理表
        'product_price_history',
        
        -- 操作日志表
        'operation_logs',
        'operation_logs_y2025q1',
        'operation_logs_y2025q2',
        'operation_logs_y2025q3',
        'operation_logs_y2025q4'
    ];
BEGIN
    RAISE NOTICE '==============================================';
    RAISE NOTICE '开始检查数据库表...';
    RAISE NOTICE '==============================================';
    
    -- 检查每个预期的表
    FOR i IN 1..array_length(expected_tables, 1)
    LOOP
        IF EXISTS (SELECT 1 FROM information_schema.tables 
                   WHERE table_schema = 'public' AND table_name = expected_tables[i]) THEN
            existing_tables := array_append(existing_tables, expected_tables[i]);
            RAISE NOTICE '✓ 表 % 存在', expected_tables[i];
        ELSE
            missing_tables := array_append(missing_tables, expected_tables[i]);
            RAISE NOTICE '✗ 表 % 不存在', expected_tables[i];
        END IF;
    END LOOP;
    
    -- 输出检查结果
    RAISE NOTICE '==============================================';
    RAISE NOTICE '表检查结果汇总:';
    RAISE NOTICE '预期表数量: %', array_length(expected_tables, 1);
    RAISE NOTICE '存在的表数量: %', array_length(existing_tables, 1);
    RAISE NOTICE '缺失的表数量: %', array_length(missing_tables, 1);
    RAISE NOTICE '完成率: %%%', ROUND((array_length(existing_tables, 1)::DECIMAL / array_length(expected_tables, 1) * 100)::NUMERIC, 2);
    
    IF array_length(missing_tables, 1) > 0 THEN
        RAISE NOTICE '缺失的表: %', array_to_string(missing_tables, ', ');
    END IF;
    
    RAISE NOTICE '==============================================';
END $$;

-- =====================================================
-- 第二部分：检查视图是否存在
-- =====================================================

DO $$
DECLARE
    view_record RECORD;
    missing_views TEXT[] := ARRAY[]::TEXT[];
    existing_views TEXT[] := ARRAY[]::TEXT[];
    expected_views TEXT[] := ARRAY[
        'view_inventory_alerts',
        'view_expiring_inventory',
        'view_order_completion',
        'view_supplier_performance',
        'view_customer_sales',
        'view_product_sales'
    ];
BEGIN
    RAISE NOTICE '==============================================';
    RAISE NOTICE '开始检查数据库视图...';
    RAISE NOTICE '==============================================';
    
    -- 检查每个预期的视图
    FOR i IN 1..array_length(expected_views, 1)
    LOOP
        IF EXISTS (SELECT 1 FROM information_schema.views 
                   WHERE table_schema = 'public' AND table_name = expected_views[i]) THEN
            existing_views := array_append(existing_views, expected_views[i]);
            RAISE NOTICE '✓ 视图 % 存在', expected_views[i];
        ELSE
            missing_views := array_append(missing_views, expected_views[i]);
            RAISE NOTICE '✗ 视图 % 不存在', expected_views[i];
        END IF;
    END LOOP;
    
    -- 输出检查结果
    RAISE NOTICE '==============================================';
    RAISE NOTICE '视图检查结果汇总:';
    RAISE NOTICE '预期视图数量: %', array_length(expected_views, 1);
    RAISE NOTICE '存在的视图数量: %', array_length(existing_views, 1);
    RAISE NOTICE '缺失的视图数量: %', array_length(missing_views, 1);
    RAISE NOTICE '完成率: %%%', ROUND((array_length(existing_views, 1)::DECIMAL / array_length(expected_views, 1) * 100)::NUMERIC, 2);
    
    IF array_length(missing_views, 1) > 0 THEN
        RAISE NOTICE '缺失的视图: %', array_to_string(missing_views, ', ');
    END IF;
    
    RAISE NOTICE '==============================================';
END $$;

-- =====================================================
-- 第三部分：检查物化视图是否存在
-- =====================================================

DO $$
DECLARE
    matview_record RECORD;
    missing_matviews TEXT[] := ARRAY[]::TEXT[];
    existing_matviews TEXT[] := ARRAY[]::TEXT[];
    expected_matviews TEXT[] := ARRAY[
        'mv_inventory_summary'
    ];
BEGIN
    RAISE NOTICE '==============================================';
    RAISE NOTICE '开始检查物化视图...';
    RAISE NOTICE '==============================================';
    
    -- 检查每个预期的物化视图
    FOR i IN 1..array_length(expected_matviews, 1)
    LOOP
        IF EXISTS (SELECT 1 FROM pg_matviews 
                   WHERE schemaname = 'public' AND matviewname = expected_matviews[i]) THEN
            existing_matviews := array_append(existing_matviews, expected_matviews[i]);
            RAISE NOTICE '✓ 物化视图 % 存在', expected_matviews[i];
        ELSE
            missing_matviews := array_append(missing_matviews, expected_matviews[i]);
            RAISE NOTICE '✗ 物化视图 % 不存在', expected_matviews[i];
        END IF;
    END LOOP;
    
    -- 输出检查结果
    RAISE NOTICE '==============================================';
    RAISE NOTICE '物化视图检查结果汇总:';
    RAISE NOTICE '预期物化视图数量: %', array_length(expected_matviews, 1);
    RAISE NOTICE '存在的物化视图数量: %', array_length(existing_matviews, 1);
    RAISE NOTICE '缺失的物化视图数量: %', array_length(missing_matviews, 1);
    RAISE NOTICE '完成率: %%%', ROUND((array_length(existing_matviews, 1)::DECIMAL / array_length(expected_matviews, 1) * 100)::NUMERIC, 2);
    
    IF array_length(missing_matviews, 1) > 0 THEN
        RAISE NOTICE '缺失的物化视图: %', array_to_string(missing_matviews, ', ');
    END IF;
    
    RAISE NOTICE '==============================================';
END $$;

-- =====================================================
-- 第四部分：检查触发器是否存在
-- =====================================================

DO $$
DECLARE
    trigger_record RECORD;
    missing_triggers TEXT[] := ARRAY[]::TEXT[];
    existing_triggers TEXT[] := ARRAY[]::TEXT[];
    expected_triggers TEXT[] := ARRAY[
        'trigger_update_products_updated_at',
        'trigger_update_suppliers_updated_at',
        'trigger_update_customers_updated_at',
        'trigger_update_warehouses_updated_at',
        'trigger_update_inventory_alerts_updated_at',
        'trigger_update_purchase_orders_updated_at',
        'trigger_update_sales_orders_updated_at',
        'trigger_update_roles_updated_at',
        'trigger_update_system_configs_updated_at',
        'trigger_update_batch_traceability_updated_at',
        'trigger_update_inventory_timestamp',
        'trigger_update_safety_inspections_updated_at',
        'trigger_update_environment_monitoring_updated_at',
        'trigger_update_hazmat_shipments_updated_at',
        'trigger_update_safety_incidents_updated_at',
        'trigger_update_safety_training_updated_at',
        'trigger_update_safety_certificates_updated_at',
        'trigger_update_report_templates_updated_at',
        'trigger_update_scheduled_tasks_updated_at',
        'trigger_update_analysis_metrics_updated_at',
        'trigger_update_dashboard_configs_updated_at',
        'trigger_update_return_orders_updated_at',
        'trigger_update_customer_visits_updated_at'
    ];
BEGIN
    RAISE NOTICE '==============================================';
    RAISE NOTICE '开始检查数据库触发器...';
    RAISE NOTICE '==============================================';
    
    -- 检查每个预期的触发器
    FOR i IN 1..array_length(expected_triggers, 1)
    LOOP
        IF EXISTS (SELECT 1 FROM information_schema.triggers 
                   WHERE trigger_schema = 'public' AND trigger_name = expected_triggers[i]) THEN
            existing_triggers := array_append(existing_triggers, expected_triggers[i]);
            RAISE NOTICE '✓ 触发器 % 存在', expected_triggers[i];
        ELSE
            missing_triggers := array_append(missing_triggers, expected_triggers[i]);
            RAISE NOTICE '✗ 触发器 % 不存在', expected_triggers[i];
        END IF;
    END LOOP;
    
    -- 输出检查结果
    RAISE NOTICE '==============================================';
    RAISE NOTICE '触发器检查结果汇总:';
    RAISE NOTICE '预期触发器数量: %', array_length(expected_triggers, 1);
    RAISE NOTICE '存在的触发器数量: %', array_length(existing_triggers, 1);
    RAISE NOTICE '缺失的触发器数量: %', array_length(missing_triggers, 1);
    RAISE NOTICE '完成率: %%%', ROUND((array_length(existing_triggers, 1)::DECIMAL / array_length(expected_triggers, 1) * 100)::NUMERIC, 2);
    
    IF array_length(missing_triggers, 1) > 0 THEN
        RAISE NOTICE '缺失的触发器: %', array_to_string(missing_triggers, ', ');
    END IF;
    
    RAISE NOTICE '==============================================';
END $$;

-- =====================================================
-- 第五部分：检查函数是否存在
-- =====================================================

DO $$
DECLARE
    function_record RECORD;
    missing_functions TEXT[] := ARRAY[]::TEXT[];
    existing_functions TEXT[] := ARRAY[]::TEXT[];
    expected_functions TEXT[] := ARRAY[
        'update_updated_at_column',
        'update_inventory_from_transaction',
        'sync_inventory_quantities',
        'auto_expire_reservations',
        'get_available_inventory',
        'validate_product_code',
        'validate_supplier_code',
        'validate_customer_code',
        'calculate_inventory_turnover',
        'create_quarterly_partition',
        'auto_create_log_partitions',
        'cleanup_old_log_partitions'
    ];
BEGIN
    RAISE NOTICE '==============================================';
    RAISE NOTICE '开始检查数据库函数...';
    RAISE NOTICE '==============================================';
    
    -- 检查每个预期的函数
    FOR i IN 1..array_length(expected_functions, 1)
    LOOP
        IF EXISTS (SELECT 1 FROM information_schema.routines 
                   WHERE routine_schema = 'public' AND routine_name = expected_functions[i]) THEN
            existing_functions := array_append(existing_functions, expected_functions[i]);
            RAISE NOTICE '✓ 函数 % 存在', expected_functions[i];
        ELSE
            missing_functions := array_append(missing_functions, expected_functions[i]);
            RAISE NOTICE '✗ 函数 % 不存在', expected_functions[i];
        END IF;
    END LOOP;
    
    -- 输出检查结果
    RAISE NOTICE '==============================================';
    RAISE NOTICE '函数检查结果汇总:';
    RAISE NOTICE '预期函数数量: %', array_length(expected_functions, 1);
    RAISE NOTICE '存在的函数数量: %', array_length(existing_functions, 1);
    RAISE NOTICE '缺失的函数数量: %', array_length(missing_functions, 1);
    RAISE NOTICE '完成率: %%%', ROUND((array_length(existing_functions, 1)::DECIMAL / array_length(expected_functions, 1) * 100)::NUMERIC, 2);
    
    IF array_length(missing_functions, 1) > 0 THEN
        RAISE NOTICE '缺失的函数: %', array_to_string(missing_functions, ', ');
    END IF;
    
    RAISE NOTICE '==============================================';
END $$;

-- =====================================================
-- 第六部分：检查索引是否存在
-- =====================================================

DO $$
DECLARE
    index_record RECORD;
    missing_indexes TEXT[] := ARRAY[]::TEXT[];
    existing_indexes TEXT[] := ARRAY[]::TEXT[];
    expected_indexes TEXT[] := ARRAY[
        -- 基础数据表索引
        'idx_products_code',
        'idx_products_type',
        'idx_products_status',
        'idx_suppliers_code',
        'idx_suppliers_name',
        'idx_customers_code',
        'idx_customers_name',
        'idx_warehouses_code',
        'idx_warehouses_name',
        
        -- 库存管理表索引
        'idx_inventory_product',
        'idx_inventory_warehouse',
        'idx_inventory_batch',
        'idx_inventory_status',
        'idx_inv_trans_product',
        'idx_inv_trans_type',
        'idx_inv_trans_date',
        'idx_inv_alerts_product',
        'idx_inv_alerts_warehouse',
        
        -- 采购订单表索引
        'idx_po_supplier',
        'idx_po_status',
        'idx_po_date',
        'idx_poi_order',
        'idx_poi_product',
        
        -- 销售订单表索引
        'idx_so_customer',
        'idx_so_status',
        'idx_so_date',
        'idx_soi_order',
        'idx_soi_product',
        
        -- 物化视图索引
        'idx_mv_inventory_summary_product',
        'idx_mv_inventory_summary_warehouse',
        'idx_mv_inventory_summary_product_warehouse'
    ];
BEGIN
    RAISE NOTICE '==============================================';
    RAISE NOTICE '开始检查数据库索引...';
    RAISE NOTICE '==============================================';
    
    -- 检查每个预期的索引
    FOR i IN 1..array_length(expected_indexes, 1)
    LOOP
        IF EXISTS (SELECT 1 FROM pg_indexes 
                   WHERE schemaname = 'public' AND indexname = expected_indexes[i]) THEN
            existing_indexes := array_append(existing_indexes, expected_indexes[i]);
            RAISE NOTICE '✓ 索引 % 存在', expected_indexes[i];
        ELSE
            missing_indexes := array_append(missing_indexes, expected_indexes[i]);
            RAISE NOTICE '✗ 索引 % 不存在', expected_indexes[i];
        END IF;
    END LOOP;
    
    -- 输出检查结果
    RAISE NOTICE '==============================================';
    RAISE NOTICE '索引检查结果汇总:';
    RAISE NOTICE '预期索引数量: %', array_length(expected_indexes, 1);
    RAISE NOTICE '存在的索引数量: %', array_length(existing_indexes, 1);
    RAISE NOTICE '缺失的索引数量: %', array_length(missing_indexes, 1);
    RAISE NOTICE '完成率: %%%', ROUND((array_length(existing_indexes, 1)::DECIMAL / array_length(expected_indexes, 1) * 100)::NUMERIC, 2);
    
    IF array_length(missing_indexes, 1) > 0 THEN
        RAISE NOTICE '缺失的索引: %', array_to_string(missing_indexes, ', ');
    END IF;
    
    RAISE NOTICE '==============================================';
END $$;

-- =====================================================
-- 第七部分：检查约束是否存在
-- =====================================================

DO $$
DECLARE
    constraint_record RECORD;
    missing_constraints TEXT[] := ARRAY[]::TEXT[];
    existing_constraints TEXT[] := ARRAY[]::TEXT[];
    expected_constraints TEXT[] := ARRAY[
        -- 库存数量约束
        'chk_inventory_quantity',
        'chk_inventory_quantity_relationship',
        
        -- 库存预警数量约束
        'chk_alerts_quantity',
        
        -- 盘点数量约束
        'chk_count_quantity',
        
        -- 调拨数量约束
        'chk_transfer_quantity',
        
        -- 日期约束
        'chk_inventory_dates',
        'chk_transfer_dates',
        
        -- 仓库约束
        'chk_transfer_warehouses',
        
        -- 批次追溯表约束
        'chk_batch_dates',
        'chk_batch_shelf_life',
        
        -- 库存预留表约束
        'chk_reservation_quantity',
        'chk_reservation_dates',
        'chk_reservation_priority',
        
        -- 供应商评估表约束
        'chk_evaluation_scores',
        
        -- 价格历史表约束
        'chk_price_positive',
        'chk_price_quantity_range',
        'chk_price_dates',
        
        -- 订单金额计算约束
        'chk_poi_amount_calculation',
        'chk_soi_amount_calculation',
        
        -- 收货数量约束
        'chk_receiving_quantities',
        
        -- 出库数量约束
        'chk_delivery_quantities',
        
        -- 安全管理表约束
        'chk_inspection_dates',
        'chk_shipment_dates',
        'chk_incident_severity',
        'chk_certificate_dates',
        
        -- 报表统计表约束
        'chk_generation_dates',
        'chk_task_counts',
        'chk_metric_value',
        
        -- 补充业务表约束
        'chk_return_quantities',
        'chk_return_type',
        'chk_visit_type',
        
        -- 安全检查类型约束
        'chk_inspection_type',
        
        -- 环境监控类型约束
        'chk_monitoring_type',
        
        -- 安全事故类型约束
        'chk_incident_type',
        
        -- 报表模板类型约束
        'chk_template_type',
        
        -- 定时任务类型约束
        'chk_task_type',
        
        -- 分析指标类型约束
        'chk_metric_type'
    ];
BEGIN
    RAISE NOTICE '==============================================';
    RAISE NOTICE '开始检查数据库约束...';
    RAISE NOTICE '==============================================';
    
    -- 检查每个预期的约束
    FOR i IN 1..array_length(expected_constraints, 1)
    LOOP
        IF EXISTS (SELECT 1 FROM information_schema.table_constraints 
                   WHERE constraint_schema = 'public' AND constraint_name = expected_constraints[i]) THEN
            existing_constraints := array_append(existing_constraints, expected_constraints[i]);
            RAISE NOTICE '✓ 约束 % 存在', expected_constraints[i];
        ELSE
            missing_constraints := array_append(missing_constraints, expected_constraints[i]);
            RAISE NOTICE '✗ 约束 % 不存在', expected_constraints[i];
        END IF;
    END LOOP;
    
    -- 输出检查结果
    RAISE NOTICE '==============================================';
    RAISE NOTICE '约束检查结果汇总:';
    RAISE NOTICE '预期约束数量: %', array_length(expected_constraints, 1);
    RAISE NOTICE '存在的约束数量: %', array_length(existing_constraints, 1);
    RAISE NOTICE '缺失的约束数量: %', array_length(missing_constraints, 1);
    RAISE NOTICE '完成率: %%%', ROUND((array_length(existing_constraints, 1)::DECIMAL / array_length(expected_constraints, 1) * 100)::NUMERIC, 2);
    
    IF array_length(missing_constraints, 1) > 0 THEN
        RAISE NOTICE '缺失的约束: %', array_to_string(missing_constraints, ', ');
    END IF;
    
    RAISE NOTICE '==============================================';
END $$;

-- =====================================================
-- 第八部分：检查扩展是否存在
-- =====================================================

DO $$
DECLARE
    extension_record RECORD;
    missing_extensions TEXT[] := ARRAY[]::TEXT[];
    existing_extensions TEXT[] := ARRAY[]::TEXT[];
    expected_extensions TEXT[] := ARRAY[
        'uuid-ossp',
        'pgcrypto'
    ];
BEGIN
    RAISE NOTICE '==============================================';
    RAISE NOTICE '开始检查数据库扩展...';
    RAISE NOTICE '==============================================';
    
    -- 检查每个预期的扩展
    FOR i IN 1..array_length(expected_extensions, 1)
    LOOP
        IF EXISTS (SELECT 1 FROM pg_extension 
                   WHERE extname = expected_extensions[i]) THEN
            existing_extensions := array_append(existing_extensions, expected_extensions[i]);
            RAISE NOTICE '✓ 扩展 % 存在', expected_extensions[i];
        ELSE
            missing_extensions := array_append(missing_extensions, expected_extensions[i]);
            RAISE NOTICE '✗ 扩展 % 不存在', expected_extensions[i];
        END IF;
    END LOOP;
    
    -- 输出检查结果
    RAISE NOTICE '==============================================';
    RAISE NOTICE '扩展检查结果汇总:';
    RAISE NOTICE '预期扩展数量: %', array_length(expected_extensions, 1);
    RAISE NOTICE '存在的扩展数量: %', array_length(existing_extensions, 1);
    RAISE NOTICE '缺失的扩展数量: %', array_length(missing_extensions, 1);
    RAISE NOTICE '完成率: %%%', ROUND((array_length(existing_extensions, 1)::DECIMAL / array_length(expected_extensions, 1) * 100)::NUMERIC, 2);
    
    IF array_length(missing_extensions, 1) > 0 THEN
        RAISE NOTICE '缺失的扩展: %', array_to_string(missing_extensions, ', ');
    END IF;
    
    RAISE NOTICE '==============================================';
END $$;

-- =====================================================
-- 第九部分：检查初始数据是否存在
-- =====================================================

DO $$
DECLARE
    data_count INTEGER;
    missing_data TEXT[] := ARRAY[]::TEXT[];
    existing_data TEXT[] := ARRAY[]::TEXT[];
BEGIN
    RAISE NOTICE '==============================================';
    RAISE NOTICE '开始检查初始数据...';
    RAISE NOTICE '==============================================';
    
    -- 检查用户数据
    BEGIN
        SELECT COUNT(*) INTO data_count FROM users WHERE username = 'admin';
        IF data_count > 0 THEN
            existing_data := array_append(existing_data, 'admin用户');
            RAISE NOTICE '✓ admin用户存在';
        ELSE
            missing_data := array_append(missing_data, 'admin用户');
            RAISE NOTICE '✗ admin用户不存在';
        END IF;
    EXCEPTION WHEN undefined_table THEN
        missing_data := array_append(missing_data, 'admin用户');
        RAISE NOTICE '✗ users表不存在，无法检查admin用户';
    END;
    
    -- 检查角色数据
    BEGIN
        SELECT COUNT(*) INTO data_count FROM roles WHERE role_code = 'ADMIN';
        IF data_count > 0 THEN
            existing_data := array_append(existing_data, 'ADMIN角色');
            RAISE NOTICE '✓ ADMIN角色存在';
        ELSE
            missing_data := array_append(missing_data, 'ADMIN角色');
            RAISE NOTICE '✗ ADMIN角色不存在';
        END IF;
    EXCEPTION WHEN undefined_table THEN
        missing_data := array_append(missing_data, 'ADMIN角色');
        RAISE NOTICE '✗ roles表不存在，无法检查ADMIN角色';
    END;
    
    -- 检查产品数据
    BEGIN
        SELECT COUNT(*) INTO data_count FROM products;
        IF data_count > 0 THEN
            existing_data := array_append(existing_data, '产品数据');
            RAISE NOTICE '✓ 产品数据存在 (数量: %)', data_count;
        ELSE
            missing_data := array_append(missing_data, '产品数据');
            RAISE NOTICE '✗ 产品数据不存在';
        END IF;
    EXCEPTION WHEN undefined_table THEN
        missing_data := array_append(missing_data, '产品数据');
        RAISE NOTICE '✗ products表不存在，无法检查产品数据';
    END;
    
    -- 检查供应商数据
    BEGIN
        SELECT COUNT(*) INTO data_count FROM suppliers;
        IF data_count > 0 THEN
            existing_data := array_append(existing_data, '供应商数据');
            RAISE NOTICE '✓ 供应商数据存在 (数量: %)', data_count;
        ELSE
            missing_data := array_append(missing_data, '供应商数据');
            RAISE NOTICE '✗ 供应商数据不存在';
        END IF;
    EXCEPTION WHEN undefined_table THEN
        missing_data := array_append(missing_data, '供应商数据');
        RAISE NOTICE '✗ suppliers表不存在，无法检查供应商数据';
    END;
    
    -- 检查客户数据
    BEGIN
        SELECT COUNT(*) INTO data_count FROM customers;
        IF data_count > 0 THEN
            existing_data := array_append(existing_data, '客户数据');
            RAISE NOTICE '✓ 客户数据存在 (数量: %)', data_count;
        ELSE
            missing_data := array_append(missing_data, '客户数据');
            RAISE NOTICE '✗ 客户数据不存在';
        END IF;
    EXCEPTION WHEN undefined_table THEN
        missing_data := array_append(missing_data, '客户数据');
        RAISE NOTICE '✗ customers表不存在，无法检查客户数据';
    END;
    
    -- 检查仓库数据
    BEGIN
        SELECT COUNT(*) INTO data_count FROM warehouses;
        IF data_count > 0 THEN
            existing_data := array_append(existing_data, '仓库数据');
            RAISE NOTICE '✓ 仓库数据存在 (数量: %)', data_count;
        ELSE
            missing_data := array_append(missing_data, '仓库数据');
            RAISE NOTICE '✗ 仓库数据不存在';
        END IF;
    EXCEPTION WHEN undefined_table THEN
        missing_data := array_append(missing_data, '仓库数据');
        RAISE NOTICE '✗ warehouses表不存在，无法检查仓库数据';
    END;
    
    -- 检查库存数据
    BEGIN
        SELECT COUNT(*) INTO data_count FROM inventory;
        IF data_count > 0 THEN
            existing_data := array_append(existing_data, '库存数据');
            RAISE NOTICE '✓ 库存数据存在 (数量: %)', data_count;
        ELSE
            missing_data := array_append(missing_data, '库存数据');
            RAISE NOTICE '✗ 库存数据不存在';
        END IF;
    EXCEPTION WHEN undefined_table THEN
        missing_data := array_append(missing_data, '库存数据');
        RAISE NOTICE '✗ inventory表不存在，无法检查库存数据';
    END;
    
    -- 检查系统配置数据
    BEGIN
        SELECT COUNT(*) INTO data_count FROM system_configs;
        IF data_count > 0 THEN
            existing_data := array_append(existing_data, '系统配置数据');
            RAISE NOTICE '✓ 系统配置数据存在 (数量: %)', data_count;
        ELSE
            missing_data := array_append(missing_data, '系统配置数据');
            RAISE NOTICE '✗ 系统配置数据不存在';
        END IF;
    EXCEPTION WHEN undefined_table THEN
        missing_data := array_append(missing_data, '系统配置数据');
        RAISE NOTICE '✗ system_configs表不存在，无法检查系统配置数据';
    END;
    
    -- 输出检查结果
    RAISE NOTICE '==============================================';
    RAISE NOTICE '初始数据检查结果汇总:';
    RAISE NOTICE '预期数据项数量: 8';
    RAISE NOTICE '存在的数据项数量: %', array_length(existing_data, 1);
    RAISE NOTICE '缺失的数据项数量: %', array_length(missing_data, 1);
    RAISE NOTICE '完成率: %%%', ROUND((array_length(existing_data, 1)::DECIMAL / 8 * 100)::NUMERIC, 2);
    
    IF array_length(missing_data, 1) > 0 THEN
        RAISE NOTICE '缺失的数据项: %', array_to_string(missing_data, ', ');
    END IF;
    
    RAISE NOTICE '==============================================';
END $$;

-- =====================================================
-- 第十部分：综合检查报告
-- =====================================================

DO $$
DECLARE
    total_tables INTEGER;
    total_views INTEGER;
    total_matviews INTEGER;
    total_triggers INTEGER;
    total_functions INTEGER;
    total_indexes INTEGER;
    total_constraints INTEGER;
    total_extensions INTEGER;
    total_records INTEGER;
BEGIN
    RAISE NOTICE '==============================================';
    RAISE NOTICE '数据库综合检查报告';
    RAISE NOTICE '==============================================';
    
    -- 统计实际存在的对象数量
    SELECT COUNT(*) INTO total_tables FROM information_schema.tables WHERE table_schema = 'public';
    SELECT COUNT(*) INTO total_views FROM information_schema.views WHERE table_schema = 'public';
    SELECT COUNT(*) INTO total_matviews FROM pg_matviews WHERE schemaname = 'public';
    SELECT COUNT(*) INTO total_triggers FROM information_schema.triggers WHERE trigger_schema = 'public';
    SELECT COUNT(*) INTO total_functions FROM information_schema.routines WHERE routine_schema = 'public';
    SELECT COUNT(*) INTO total_indexes FROM pg_indexes WHERE schemaname = 'public';
    SELECT COUNT(*) INTO total_constraints FROM information_schema.table_constraints WHERE constraint_schema = 'public';
    SELECT COUNT(*) INTO total_extensions FROM pg_extension;
    
    -- 统计总记录数
    BEGIN
        SELECT SUM(row_count) INTO total_records FROM (
            SELECT COUNT(*) as row_count FROM users
            UNION ALL
            SELECT COUNT(*) FROM products
            UNION ALL
            SELECT COUNT(*) FROM suppliers
            UNION ALL
            SELECT COUNT(*) FROM customers
            UNION ALL
            SELECT COUNT(*) FROM warehouses
            UNION ALL
            SELECT COUNT(*) FROM inventory
            UNION ALL
            SELECT COUNT(*) FROM system_configs
        ) as counts;
    EXCEPTION WHEN undefined_table THEN
        total_records := 0;
    END;
    
    RAISE NOTICE '数据库对象统计:';
    RAISE NOTICE '  表数量: % (预期: 50)', total_tables;
    RAISE NOTICE '  视图数量: % (预期: 6)', total_views;
    RAISE NOTICE '  物化视图数量: % (预期: 1)', total_matviews;
    RAISE NOTICE '  触发器数量: % (预期: 23)', total_triggers;
    RAISE NOTICE '  函数数量: % (预期: 12)', total_functions;
    RAISE NOTICE '  索引数量: % (预期: 30+)', total_indexes;
    RAISE NOTICE '  约束数量: % (预期: 40+)', total_constraints;
    RAISE NOTICE '  扩展数量: % (预期: 2)', total_extensions;
    RAISE NOTICE '  总记录数: %', total_records;
    
    RAISE NOTICE '==============================================';
    RAISE NOTICE '检查完成！';
    RAISE NOTICE '==============================================';
END $$;
