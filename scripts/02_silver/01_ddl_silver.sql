/*
===============================================================================
DDL Script: Create Silver Tables
===============================================================================
Script Purpose:
    This script creates tables in the 'silver' schema, dropping existing tables 
    if they already exist.
	  Run this script to re-define the DDL structure of 'bronze' Tables
===============================================================================
*/

USE DataWarehouse;

DROP TABLE IF EXISTS silver_crm_cust_info;
CREATE TABLE silver_crm_cust_info (
    cst_id int,
    cst_key VARCHAR(50),
    cst_firstname VARCHAR(50),
    cst_lastname VARCHAR(50),
    cst_marital_status VARCHAR(50),
    cst_gender VARCHAR(50),
    cst_create_date date,
    dwh_create_date datetime default now()
);

DROP TABLE IF EXISTS silver_crm_prod_info;
CREATE TABLE silver_crm_prod_info(
	prod_id INT,
    cat_id varchar(50),
    prod_key varchar(50),
    prod_name varchar(50),
    prod_cost int,
    prod_line varchar(50),
    prod_start_date DATE,
    prod_end_date DATE,
    dwh_create_date datetime default now()
);

DROP TABLE IF EXISTS silver_crm_sales_details;
CREATE TABLE silver_crm_sales_details(
	sales_order_num varchar(50),
    sales_prod_key varchar(50),
    sales_cust_id int,
    sales_order_dt DATE,
    sales_ship_dt DATE,
    sales_due_dt DATE,
    sales_sales int,
    sales_quantity int,
    sales_price int,
    dwh_create_date datetime default now()
);

DROP TABLE IF EXISTS silver_erp_loc_a101;
CREATE TABLE silver_erp_loc_a101(
	cid varchar(50),
    cntry varchar(50),
    dwh_create_date datetime default now()
);

DROP TABLE IF EXISTS silver_erp_cust_az12;
CREATE TABLE silver_erp_cust_az12(
	cid varchar(50),
    bdate date,
    gen varchar(50),
    dwh_create_date datetime default now()
);

DROP TABLE IF EXISTS silver_erp_px_cat_g1v2;
CREATE TABLE silver_erp_px_cat_g1v2(
	id varchar(50),
    cat varchar(50),
    subcat varchar(50),
    maintenance varchar(50),
    dwh_create_date datetime default now()
);

