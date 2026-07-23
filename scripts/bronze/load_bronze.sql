/*
=============================================================
Bronze Layer Data Loading
=============================================================

Script Purpose:
    This script loads raw data from CRM and ERP source CSV files
    into the Bronze layer tables.

File Storage Note:
    - Before executing this script, place all source CSV files inside
      the MySQL secure_file_priv directory (Uploads folder).
    - The folder location can be checked using:

        SHOW VARIABLES LIKE 'secure_file_priv';

    - Update the file paths below according to your local MySQL
      installation.

    Example:
        'your_path/source_crm/cust_info.csv'
        'your_path/source_crm/prd_info.csv'
        'your_path/source_erp/loc_a101.csv'
Notes:
    - MySQL does not support using LOAD DATA INFILE inside stored
      procedures, so each loading operation is executed separately.
    - Existing Bronze data is removed before each reload to maintain
      a fresh copy of the source data.
    - Empty source values are converted into NULL using NULLIF()
      to preserve missing information properly.
    - Data validation and transformation will be performed in the
      Silver layer.
=============================================================
*/


/*
=============================================================
Loading CRM Tables
=============================================================
*/


-- Load customer information extracted from the CRM source
TRUNCATE TABLE bronze_crm_cust_info;

LOAD DATA INFILE 'your_path/source_crm/cust_info.csv'
INTO TABLE bronze_crm_cust_info
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(
    @cst_id,
    @cst_key,
    @cst_firstname,
    @cst_lastname,
    @cst_material_status,
    @cst_gender,
    @cst_create_date
)
SET
    cst_id = NULLIF(@cst_id, ''),
    cst_key = NULLIF(@cst_key, ''),
    cst_firstname = NULLIF(@cst_firstname, ''),
    cst_lastname = NULLIF(@cst_lastname, ''),
    cst_material_status = NULLIF(@cst_material_status, ''),
    cst_gender = NULLIF(@cst_gender, ''),
    cst_create_date = NULLIF(@cst_create_date, '');


-- Load product information extracted from the CRM source
TRUNCATE TABLE bronze_crm_prod_info;

LOAD DATA INFILE 'your_path/source_crm/prd_info.csv'
INTO TABLE bronze_crm_prod_info
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(
    @prod_id,
    @prod_key,
    @prod_name,
    @prod_cost,
    @prod_line,
    @prod_start_date,
    @prod_end_date
)
SET
    prod_id = NULLIF(@prod_id, ''),
    prod_key = NULLIF(@prod_key, ''),
    prod_name = NULLIF(@prod_name, ''),
    prod_cost = NULLIF(@prod_cost, ''),
    prod_line = NULLIF(@prod_line, ''),
    prod_start_date = NULLIF(@prod_start_date, ''),
    prod_end_date = NULLIF(@prod_end_date, '');


-- Load sales transaction details extracted from the CRM source
TRUNCATE TABLE bronze_crm_sales_details;

LOAD DATA INFILE 'your_path/source_crm/sales_details.csv'
INTO TABLE bronze_crm_sales_details
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(
    @sales_order_num,
    @sales_prod_key,
    @sales_cust_id,
    @sales_order_dt,
    @sales_ship_dt,
    @sales_due_dt,
    @sales_sales,
    @sales_quantity,
    @sales_price
)
SET
    sales_order_num = NULLIF(@sales_order_num, ''),
    sales_prod_key = NULLIF(@sales_prod_key, ''),
    sales_cust_id = NULLIF(@sales_cust_id, ''),
    sales_order_dt = NULLIF(@sales_order_dt, ''),
    sales_ship_dt = NULLIF(@sales_ship_dt, ''),
    sales_due_dt = NULLIF(@sales_due_dt, ''),
    sales_sales = NULLIF(@sales_sales, ''),
    sales_quantity = NULLIF(@sales_quantity, ''),
    sales_price = NULLIF(@sales_price, '');


/*
=============================================================
Loading ERP Tables
=============================================================
*/


-- Load ERP location mapping data
TRUNCATE TABLE bronze_erp_loc_a101;

LOAD DATA INFILE 'your_path/source_erp/loc_a101.csv'
INTO TABLE bronze_erp_loc_a101
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(
    @cid,
    @cntry
)
SET
    cid = NULLIF(@cid, ''),
    cntry = NULLIF(@cntry, '');


-- Load ERP customer demographic information
TRUNCATE TABLE bronze_erp_cust_az12;

LOAD DATA INFILE 'your_path/source_erp/cust_az12.csv'
INTO TABLE bronze_erp_cust_az12
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(
    @cid,
    @bdate,
    @gen
)
SET
    cid = NULLIF(@cid, ''),
    bdate = NULLIF(@bdate, ''),
    gen = NULLIF(@gen, '');


-- Load ERP product category information
TRUNCATE TABLE bronze_erp_px_cat_g1v2;

LOAD DATA INFILE 'your_path/source_erp/px_cat_g1v2.csv'
INTO TABLE bronze_erp_px_cat_g1v2
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(
    @id,
    @cat,
    @subcat,
    @maintenance
)
SET
    id = NULLIF(@id, ''),
    cat = NULLIF(@cat, ''),
    subcat = NULLIF(@subcat, ''),
    maintenance = NULLIF(@maintenance, '');
