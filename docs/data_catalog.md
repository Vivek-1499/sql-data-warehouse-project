# Data Catalog for Gold Layer

## Overview
The Gold Layer is the business-level data representation, structured to support analytical and reporting use cases. It consists of **dimension views** and **fact views** designed for business reporting and analytics.

---

### 1. **gold_dim_customer**

- **Purpose:** Stores customer details enriched with demographic and geographic data.

#### Columns

| Column Name     | Data Type   | Description |
|-----------------|------------|-------------|
| customer_key    | INT        | Surrogate key uniquely identifying each customer record. |
| customer_id     | INT        | Unique numerical identifier assigned to each customer. |
| customer_number | VARCHAR(50)| Customer business identifier used across source systems. |
| fisrt_name      | VARCHAR(50)| Customer's first name. |
| last_name       | VARCHAR(50)| Customer's last name. |
| country         | VARCHAR(50)| Country where the customer resides. |
| gender          | VARCHAR(50)| Customer gender derived from CRM or ERP data. |
| marital_status  | VARCHAR(50)| Customer's marital status. |
| create_date     | DATE       | Date the customer record was created. |
| birthdate       | DATE       | Customer's date of birth. |

---

### 2. **gold_dimension_products**

- **Purpose:** Stores product information enriched with category and product hierarchy details.

#### Columns

| Column Name | Data Type | Description |
|-------------|----------|-------------|
| product_key | INT | Surrogate key uniquely identifying each product. |
| product_id | INT | Internal product identifier. |
| product_number | VARCHAR(50) | Business product code. |
| product_name | VARCHAR(50) | Product name. |
| category_id | VARCHAR(50) | Product category identifier. |
| category | VARCHAR(50) | High-level product category. |
| subcategory | VARCHAR(50) | Product subcategory. |
| maintenance | VARCHAR(50) | Indicates whether the product requires maintenance. |
| cost | INT | Product cost. |
| product_line | VARCHAR(50) | Product line or series. |
| start_date | DATE | Date the product became available. |

---

### 3. **gold_fact_sales**

- **Purpose:** Stores transactional sales records linked to customer and product dimensions.

#### Columns

| Column Name | Data Type | Description |
|-------------|----------|-------------|
| order_number | VARCHAR(50) | Unique sales order number. |
| product_key | INT | Foreign key referencing **gold_dimension_products**. |
| customer_key | INT | Foreign key referencing **gold_dim_customer**. |
| order_date | DATE | Date the order was placed. |
| shipping_date | DATE | Date the order was shipped. |
| due_date | DATE | Payment due date. |
| sales_amount | INT | Total sales amount for the order line. |
| quantity | INT | Number of units sold. |
| price | INT | Unit selling price. |
