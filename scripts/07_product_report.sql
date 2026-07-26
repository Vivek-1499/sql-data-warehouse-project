/*
=====================================================================
Product Report
=====================================================================
Purpose:
    - This report consolidates key product metrics and behaviors.

Highlights:
    1. Gathers essential fields such as product name, category,
       subcategory, and cost.
    2. Segments products by revenue to identify High-Performers,
       Mid-Range, or Low-Performers.
    3. Aggregates product-level metrics:
        - total orders
        - total sales
        - total quantity sold
        - total customers (unique)
        - lifespan (in months)
    4. Calculates valuable KPIs:
        - recency (months since last sale)
        - average order revenue (AOR)
        - average monthly revenue
=====================================================================
*/

CREATE VIEW gold_report_product AS
WITH base_query AS (
SELECT
f.order_number,
f.order_date,
f.customer_key,
f.product_key,
f.sales_amount,
f.quantity,
p.product_number,
p.product_name,
p.category,
p.subcategory,
p.cost
FROM gold_fact_sales f
LEFT JOIN gold_dimension_products p
ON f.product_key = p.product_key
WHERE f.order_date IS NOT NULL
),
product_agg AS (
SELECT
product_key,
product_number,
product_name,
category,
subcategory,
cost,
COUNT(DISTINCT order_number) AS total_orders,
SUM(sales_amount) AS total_sales,
SUM(quantity) AS total_quantity_sold,
COUNT(DISTINCT customer_key) AS total_customers,
MIN(order_date) AS first_sale_date,
MAX(order_date) AS last_sale_date,
TIMESTAMPDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan
FROM base_query
GROUP BY product_key,
product_number,
product_name,
category,
subcategory,
cost
)
SELECT
product_key,
product_number,
product_name,
category,
subcategory,
cost,
total_orders,
total_sales,
CASE WHEN total_sales >= 50000 THEN 'High-Performer'
	WHEN total_sales >= 10000 THEN 'Mid-Range'
	ELSE 'Low-Performer'
END AS product_segment,
total_quantity_sold,
total_customers,
first_sale_date,
last_sale_date,
lifespan,
TIMESTAMPDIFF(MONTH, last_sale_date, NOW()) AS recency,

-- Average Order Revenue (AOR)
CASE WHEN total_orders = 0 THEN 0
	ELSE ROUND(total_sales / total_orders, 2)
END AS avg_order_revenue,

-- Average Monthly Revenue
CASE WHEN lifespan = 0 THEN total_sales
	ELSE ROUND(total_sales / lifespan, 2)
END AS avg_monthly_revenue

FROM product_agg;
