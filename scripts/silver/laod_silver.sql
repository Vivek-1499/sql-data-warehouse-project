/*
===============================================================================
Stored Procedure: load_silver_layer
===============================================================================
Script Purpose:
    This stored procedure performs the ETL process to populate Silver tables
    from Bronze tables.

Actions Performed:
    - Truncates Silver tables.
    - Inserts transformed and cleansed data from Bronze tables.
    - Handles errors and logs failures.

Parameters:
    None.

Usage:
    CALL load_silver_layer();
===============================================================================
*/


DROP PROCEDURE IF EXISTS load_silver_layer;
DELIMITER $$

CREATE PROCEDURE load_silver_layer()
BEGIN
    DECLARE v_start_time DATETIME;
    DECLARE v_end_time DATETIME;
    DECLARE v_batch_start_time DATETIME;
    DECLARE v_batch_end_time DATETIME;
    DECLARE v_error_message TEXT;
    DECLARE v_error_code INT;
    /*
    =====================================================
    Error Handler
    =====================================================
    */
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1
            v_error_code = MYSQL_ERRNO,
            v_error_message = MESSAGE_TEXT;
        ROLLBACK;
        INSERT INTO etl_error_log
        (procedure_name,
            error_code,
            error_message,
            error_time)
        VALUES(
            'load_silver_layer',
            v_error_code,
            v_error_message,
            NOW());
        SELECT
            'ERROR OCCURRED DURING SILVER LOAD' AS message,
            v_error_code AS error_code,
            v_error_message AS error_message;
    END;
    SET v_batch_start_time = NOW();    
    START TRANSACTION;
    /*
    =====================================================
    Loading CRM Tables
    =====================================================
    */
    /*
    silver_crm_cust_info
    */
    SET v_start_time = NOW();

    TRUNCATE TABLE silver_crm_cust_info;
    INSERT INTO silver_crm_cust_info(cst_id,
        cst_key,
        cst_firstname,
        cst_lastname,
        cst_marital_status,
        cst_gender,
        cst_create_date
    )
    SELECT
        cst_id,
        cst_key,
        TRIM(cst_firstname),
        TRIM(cst_lastname),
        CASE
            WHEN UPPER(TRIM(cst_marital_status))='S' THEN 'Single'
            WHEN UPPER(TRIM(cst_marital_status))='M' THEN 'Married'
            ELSE 'n/a'
        END,
        CASE
            WHEN UPPER(TRIM(cst_gender))='M' THEN 'Male'
            WHEN UPPER(TRIM(cst_gender))='F' THEN 'Female'
            ELSE 'n/a'
        END,
        cst_create_date
    FROM
    (SELECT *,
        ROW_NUMBER() OVER( PARTITION BY cst_id ORDER BY cst_create_date DESC ) AS flag_last
        FROM bronze_crm_cust_info WHERE cst_id IS NOT NULL ) t
    WHERE flag_last = 1;
    SET v_end_time = NOW();
    SELECT CONCAT('Load Duration: ', TIMESTAMPDIFF(SECOND,v_start_time,v_end_time),' seconds'
    ) AS message;

TRUNCATE TABLE silver_crm_prod_info;
INSERT INTO silver_crm_prod_info(
prod_id,
cat_id,
prod_key,
prod_name,
prod_cost,
prod_line,
prod_start_date,
prod_end_date
)
SELECT prod_id,
REPLACE(substring(prod_key, 1, 5), '-', '_') as cat_id,
SUBSTRING(prod_key, 7, length(prod_key)) as prod_key,
prod_name,
IFNULL(prod_cost, 0) as prod_cost,
CASE UPPER(TRIM(prod_line))
	WHEN'M' THEN 'Mountain'
	WHEN 'R' THEN 'Road'
	WHEN 'S' THEN 'other Sales'
	WHEN 'T' THEN 'Touring'
	ELSE 'n/a'
END as prod_line,
CAST(prod_start_date AS DATE) prod_start_date,
CAST(LEAD(prod_start_date) over(partition by prod_key order by prod_start_date) - INTERVAL 1 DAY as DATE) as prod_end_date
from bronze_crm_prod_info;


TRUNCATE TABLE silver_crm_sales_details;
INSERT INTO silver_crm_sales_details(
sales_order_num,
    sales_prod_key,
    sales_cust_id,
    sales_order_dt,
    sales_ship_dt,
    sales_due_dt,
    sales_sales,
    sales_quantity,
    sales_price
)
SELECT sales_order_num,
sales_prod_key,
sales_cust_id,
CASE WHEN sales_order_dt = 0 OR LENGTH(sales_order_dt) != 8 THEN null
	ELSE str_to_date(sales_order_dt, '%Y%m%d')
END as sales_order_dt,
CASE WHEN sales_ship_dt = 0 OR LENGTH(sales_ship_dt) != 8 THEN null
	ELSE str_to_date(sales_ship_dt, '%Y%m%d')
END as sales_ship_dt,
CASE WHEN sales_due_dt = 0 OR LENGTH(sales_due_dt) != 8 THEN null
	ELSE str_to_date(sales_due_dt, '%Y%m%d')
END as sales_order_dt,
CASE WHEN sales_sales IS NULL OR sales_sales <=0 OR sales_sales != sales_quantity * abs(sales_price)
	THEN sales_quantity * ABS(sales_price)
	ELSE sales_sales
END sales_sales,
sales_quantity,
CASE WHEN sales_price IS NULL OR sales_price <=0
	THEN sales_sales / IFNULL(sales_quantity, 0)
    ELSE sales_price
END sales_price
FROM bronze_crm_sales_details;


TRUNCATE TABLE silver_erp_cust_az12;
INSERT INTO silver_erp_cust_az12(
cid, bdate, gen
)
SELECT
CASE WHEN cid LIKE 'NAS%' THEN substring(cid, 4, length(cid))
	ELSE cid
END as cid,
CASE WHEN bdate > NOW() THEN NULL 
	ELSE bdate
END as bdate,
CASE WHEN UPPER(TRIM(gen)) IN ('F', 'Female') THEN 'Female'
WHEN UPPER(TRIM(gen)) IN ('M', 'Male') THEN 'Male'
ELSE 'n/a'
END as gen
FROM bronze_erp_cust_az12;


TRUNCATE TABLE silver_erp_loc_a101;
INSERT INTO silver_erp_loc_a101(
cid, cntry
)
SELECT
replace(cid, '-', '') cid,
CASE WHEN TRIM(cntry) = 'DE' THEN 'Germany'
	WHEN TRIM(cntry) IN ('United States', 'US', 'USA') THEN 'United States'
	WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'
	ELSE TRIM(cntry)
END as cntry
FROM bronze_erp_loc_a101;


TRUNCATE TABLE silver_erp_px_cat_g1v2;
INSERT INTO silver_erp_px_cat_g1v2(
	id,
    cat,
    subcat,
    maintenance
)
SELECT id,
    cat,
    subcat,
    maintenance
FROM bronze_erp_px_cat_g1v2;

 COMMIT;
    SET v_batch_end_time = NOW();
    SELECT CONCAT('Total Duration: ',
        TIMESTAMPDIFF(SECOND, v_batch_start_time, v_batch_end_time ),' seconds'
    ) AS message;
END$$
DELIMITER ;

CALL load_silver_layer;
