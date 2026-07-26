/*
=============================================================
Create Bronze Layer Tables
=============================================================

Script Purpose:
    This script creates the Bronze layer tables
    used for storing raw data extracted from
    CRM and ERP source systems.

Notes:
    - MySQL is used for implementation.
    - The Bronze layer keeps source data close to its original format.
    - Data cleansing and transformations will be handled in later layers
      (Silver and Gold).
    - Existing objects are removed to allow a fresh reload during development.

Warning:
    Running this script will permanently delete the existing stored data if it already exists.
=============================================================
*/


/*
=============================================================
CRM Source Tables
=============================================================

Stores customer, product, and sales-related data extracted from
the CRM system.

The columns are designed to capture the raw source structure before
any business rules or data quality checks are applied.
=============================================================
*/

USE DataWarehouse;

DROP TABLE IF EXISTS bronze_crm_cust_info;
CREATE TABLE bronze_crm_cust_info (
    cst_id int,
    cst_key VARCHAR(50),
    cst_firstname VARCHAR(50),
    cst_lastname VARCHAR(50),
    cst_material_status VARCHAR(50),
    cst_gender VARCHAR(50),
    cst_create_date date
);

DROP TABLE IF EXISTS bronze_crm_prod_info;
CREATE TABLE bronze_crm_prod_info(
	prod_id INT,
    prod_key varchar(50),
    prod_name varchar(50),
    prod_cost int,
    prod_line varchar(50),
    prod_start_date datetime,
    prod_end_date datetime
);

DROP TABLE IF EXISTS bronze_crm_sales_details;
CREATE TABLE bronze_crm_sales_details(
	sales_order_num varchar(50),
    sales_prod_key varchar(50),
    sales_cust_id int,
    sales_order_dt int,
    sales_ship_dt int,
    sales_due_dt int,
    sales_sales int,
    sales_quantity int,
    sales_price int
);USE DataWarehouse;

DROP TABLE IF EXISTS bronze_crm_cust_info;
CREATE TABLE bronze_crm_cust_info (
    cst_id int,
    cst_key VARCHAR(50),
    cst_firstname VARCHAR(50),
    cst_lastname VARCHAR(50),
    cst_material_status VARCHAR(50),
    cst_gender VARCHAR(50),
    cst_create_date date
);

DROP TABLE IF EXISTS bronze_crm_prod_info;
CREATE TABLE bronze_crm_prod_info(
	prod_id INT,
    prod_key varchar(50),
    prod_name varchar(50),
    prod_cost int,
    prod_line varchar(50),
    prod_start_date datetime,
    prod_end_date datetime
);

DROP TABLE IF EXISTS bronze_crm_sales_details;
CREATE TABLE bronze_crm_sales_details(
	sales_order_num varchar(50),
    sales_prod_key varchar(50),
    sales_cust_id int,
    sales_order_dt int,
    sales_ship_dt int,
    sales_due_dt int,
    sales_sales int,
    sales_quantity int,
    sales_price int
);

/*
=============================================================
ERP Source Tables
=============================================================

Stores supporting reference data extracted from the ERP system.

These tables contain additional information such as customer details,
location mappings, and product category definitions that will later
be integrated with CRM data.
=============================================================
*/


DROP TABLE IF EXISTS bronze_erp_loc_a101;

CREATE TABLE bronze_erp_loc_a101(
    cid varchar(50),
    cntry varchar(50)
);


DROP TABLE IF EXISTS bronze_erp_cust_az12;

CREATE TABLE bronze_erp_cust_az12(
    cid varchar(50),
    bdate date,
    gen varchar(50)
);


DROP TABLE IF EXISTS bronze_erp_px_cat_g1v2;

CREATE TABLE bronze_erp_px_cat_g1v2(
    id varchar(50),
    cat varchar(50),
    subcat varchar(50),
    maintenance varchar(50)
);
