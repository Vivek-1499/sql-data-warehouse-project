/*
===============================================================================
Quality Checks
===============================================================================
Script Purpose:
    This script performs various quality checks for data consistency,
    accuracy, and standardization across the Silver layer.

It includes checks for:
    - NULL or duplicate primary keys.
    - Unwanted spaces in string fields.
    - Data standardization and consistency.
    - Invalid date ranges and date orders.
    - Data consistency between related fields.

Usage Notes:
    - Run these checks after executing:
          CALL load_silver_layer();
    - Investigate and resolve any records returned by these queries.
===============================================================================
*/

-- ============================================================================
-- Checking 'silver_crm_cust_info'
-- ============================================================================

-- Check for NULLs or Duplicate Customer IDs
-- Expectation: No Results
SELECT
    cst_id,
    COUNT(*) AS record_count
FROM silver_crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1
   OR cst_id IS NULL;

-- Check for Unwanted Spaces
-- Expectation: No Results
SELECT
    cst_key,
    cst_firstname,
    cst_lastname
FROM silver_crm_cust_info
WHERE cst_key <> TRIM(cst_key)
   OR cst_firstname <> TRIM(cst_firstname)
   OR cst_lastname <> TRIM(cst_lastname);

-- Check Gender Standardization
SELECT DISTINCT cst_gender
FROM silver_crm_cust_info;

-- Check Marital Status Standardization
SELECT DISTINCT cst_marital_status
FROM silver_crm_cust_info;

-- ============================================================================
-- Checking 'silver_crm_prod_info'
-- ============================================================================

-- Check for NULLs or Duplicate Product IDs
-- Expectation: No Results
SELECT
    prod_id,
    COUNT(*) AS record_count
FROM silver_crm_prod_info
GROUP BY prod_id
HAVING COUNT(*) > 1
   OR prod_id IS NULL;

-- Check for Unwanted Spaces
SELECT
    prod_name
FROM silver_crm_prod_info
WHERE prod_name <> TRIM(prod_name);

-- Check for Negative or NULL Costs
SELECT
    prod_cost
FROM silver_crm_prod_info
WHERE prod_cost < 0
   OR prod_cost IS NULL;

-- Check Product Line Standardization
SELECT DISTINCT
    prod_line
FROM silver_crm_prod_info;

-- Check Invalid Product Date Ranges
SELECT *
FROM silver_crm_prod_info
WHERE prod_end_date < prod_start_date;

-- ============================================================================
-- Checking 'silver_crm_sales_details'
-- ============================================================================

-- Check for Invalid Dates
SELECT *
FROM silver_crm_sales_details
WHERE order_date IS NULL
   OR sales_ship_dt IS NULL
   OR sales_due_dt IS NULL;

-- Check Date Order
SELECT *
FROM silver_crm_sales_details
WHERE sales_order_dt > sales_ship_dt
   OR sales_order_dt > sales_due_dt;

-- Check Sales = Quantity × Price
SELECT
    sales_sales,
    sales_quantity,
    sales_price
FROM silver_crm_sales_details
WHERE sales_sales <> sales_quantity * sales_price
   OR sales_sales IS NULL
   OR sales_quantity IS NULL
   OR sales_price IS NULL
   OR sales_sales <= 0
   OR sales_quantity <= 0
   OR sales_price <= 0
ORDER BY sales_sales,
         sales_quantity,
         sales_price;

-- ============================================================================
-- Checking 'silver_erp_cust_az12'
-- ============================================================================

-- Check Birth Date Range
SELECT DISTINCT
    bdate
FROM silver_erp_cust_az12
WHERE bdate < '1924-01-01'
   OR bdate > CURDATE();

-- Check Gender Standardization
SELECT DISTINCT
    gen
FROM silver_erp_cust_az12;

-- ============================================================================
-- Checking 'silver_erp_loc_a101'
-- ============================================================================

-- Check Country Standardization
SELECT DISTINCT
    cntry
FROM silver_erp_loc_a101
ORDER BY cntry;

-- ============================================================================
-- Checking 'silver_erp_px_cat_g1v2'
-- ============================================================================

-- Check for Unwanted Spaces
SELECT *
FROM silver_erp_px_cat_g1v2
WHERE cat <> TRIM(cat)
   OR subcat <> TRIM(subcat)
   OR maintenance <> TRIM(maintenance);

-- Check Maintenance Standardization
SELECT DISTINCT
    maintenance
FROM silver_erp_px_cat_g1v2;
