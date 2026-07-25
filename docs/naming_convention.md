# **Naming Conventions**

This document outlines the naming conventions used for tables, views, columns, and other database objects in the data warehouse.

## **Table of Contents**

1. [General Principles](#general-principles)
2. [Table and View Naming Conventions](#table-and-view-naming-conventions)
   - [Bronze Layer](#bronze-layer)
   - [Silver Layer](#silver-layer)
   - [Gold Layer](#gold-layer)
3. [Column Naming Conventions](#column-naming-conventions)
   - [Surrogate Keys](#surrogate-keys)
   - [Technical Columns](#technical-columns)

---

# **General Principles**

- **Naming Convention:** Use `snake_case` with lowercase letters and underscores (`_`).
- **Language:** Use English for all database objects.
- **Avoid Reserved Words:** Do not use SQL reserved keywords as object names.
- **Prefixes:** Since MySQL schemas are not used for each layer, every object name begins with the layer prefix (`bronze_`, `silver_`, or `gold_`).

---

# **Table and View Naming Conventions**

## **Bronze Layer**

Bronze tables store raw data imported directly from the source systems.

**Pattern**

```
bronze_<source_system>_<entity>
```

- `<source_system>`: Source system name (e.g., `crm`, `erp`)
- `<entity>`: Original table name from the source system

**Examples**

- `bronze_crm_cust_info`
- `bronze_crm_prod_info`
- `bronze_crm_sales_details`
- `bronze_erp_cust_az12`

---

## **Silver Layer**

Silver tables contain cleansed and standardized data while preserving the original business entities.

**Pattern**

```
silver_<source_system>_<entity>
```

- `<source_system>`: Source system name
- `<entity>`: Original table name

**Examples**

- `silver_crm_cust_info`
- `silver_crm_prod_info`
- `silver_crm_sales_details`
- `silver_erp_loc_a101`

---

## **Gold Layer**

The Gold layer contains business-ready analytical views.

**Pattern**

```
gold_<category>_<entity>
```

- `<category>`: Business object type such as `dim`, `dimension`, or `fact`
- `<entity>`: Business entity name

**Examples**

- `gold_dim_customer`
- `gold_dimension_products`
- `gold_fact_sales`

### **Category Prefixes**

| Prefix | Description | Example |
|---------|-------------|---------|
| `gold_dim_` | Customer or business dimension view | `gold_dim_customer` |
| `gold_dimension_` | Product or business dimension view | `gold_dimension_products` |
| `gold_fact_` | Fact view containing business transactions | `gold_fact_sales` |

---

# **Column Naming Conventions**

## **Surrogate Keys**

Dimension views use surrogate keys generated with `ROW_NUMBER()`.

**Pattern**

```
<entity>_key
```

**Examples**

- `customer_key`
- `product_key`

---

## **Business Keys**

Business identifiers from the source systems use the `_id` or descriptive naming convention.

**Examples**

- `customer_id`
- `product_id`
- `customer_number`
- `product_number`
- `order_number`

---

## **Date Columns**

Use descriptive names ending with `_date`.

**Examples**

- `order_date`
- `shipping_date`
- `due_date`
- `create_date`
- `birthdate`
- `start_date`

---

## **Measure Columns**

Fact views use descriptive names for business measures.

**Examples**

- `sales_amount`
- `quantity`
- `price`

---

## **Technical Columns**

If technical metadata columns are added in the future, they should use the `dwh_` prefix.

**Pattern**

```
dwh_<column_name>
```

**Examples**

- `dwh_load_date`
- `dwh_insert_timestamp`
- `dwh_source_system`
