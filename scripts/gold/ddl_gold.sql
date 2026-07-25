/*
===============================================================================
DDL Script: Create Gold Views
===============================================================================
Script Purpose:
    This script creates views for the Gold layer in the data warehouse. 
    The Gold layer represents the final dimension and fact tables (Star Schema)

    Each view performs transformations and combines data from the Silver layer 
    to produce a clean, enriched, and business-ready dataset.

Usage:
    - These views can be queried directly for analytics and reporting.
===============================================================================
*/


-- =============================================================================
-- Create Dimension: gold.dim_customers
-- =============================================================================

DROP VIEW gold_dim_customer;
CREATE VIEW gold_dim_customer as
SELECT
	ROW_NUMBER() OVER(ORDER BY cst_id) as customer_key, 
	ci.cst_id customer_id,
    ci.cst_key customer_number,
    ci.cst_firstname first_name,
    ci.cst_lastname last_name,    
    la.cntry country,
    CASE WHEN ci.cst_gender != 'n/a' THEN ci.cst_gender
		ELSE coalesce(ca.gen, 'n/a')
	END as gender,
    ci.cst_marital_status marital_status,
    ci.cst_create_date create_date,
    ca.bdate birthdate
FROM silver_crm_cust_info ci
LEFT JOIN silver_erp_cust_az12 ca
ON	ci.cst_key = ca.cid
LEFT JOIN silver_erp_loc_a101 la
ON 	ci.cst_key = la.cid;

-- =============================================================================
-- Create Dimension: gold.dim_products
-- =============================================================================
DROP VIEW gold_dimension_products;
CREATE VIEW gold_dimension_products as
SELECT
	ROW_NUMBER() OVER (ORDER BY pn.prod_start_date, pn.prod_key) product_key,
	pn.prod_id product_id,
	pn.prod_key product_number,
    pn.prod_name product_name,
    pn.cat_id category_id,
	pc.cat category,
    pc.subcat subcategory,
    pc.maintenance ,
    pn.prod_cost cost,
    pn.prod_line product_line, 
    pn.prod_start_date start_date
from silver_crm_prod_info pn
LEFT JOIN silver_erp_px_cat_g1v2 pc
ON pn.cat_id = pc.id
WHERE prod_end_date IS NULL;

-- =============================================================================
-- Create Fact Table: gold.fact_sales
-- =============================================================================
DROP VIEW gold_fact_sales;
CREATE VIEW gold_fact_sales AS
SELECT
    sd.sales_order_num AS order_number,
    pr.product_key,
    cu.customer_key,
    sd.sales_order_dt AS order_date,
    sd.sales_ship_dt AS shipping_date,
    sd.sales_due_dt AS due_date,
    sd.sales_sales AS sales_amount,
    sd.sales_quantity AS quantity,
    sd.sales_price AS price
FROM silver_crm_sales_details sd
LEFT JOIN gold_dimension_products pr
    ON sd.sales_prod_key = pr.product_number
LEFT JOIN gold_dim_customer cu
    ON sd.sales_cust_id = cu.customer_id;
