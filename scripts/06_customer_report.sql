/*
====================================================================================
Customer Report
====================================================================================
Purpose:
	- This report consolidates key customer metrics and behaviors
    
Highlights:
	1. Gathers essential fields such as names, ages, and transaction details.
	2. Segments customers into categories (VIP, Regular, New) and age groups.
	3. Aggregates customer-level metrics:
		total orders
		total sales
		total quantity purchased
		total products
		lifespan (in months)
	4. Calculates valuable KPIs:
		recency (months since last order)
		average order value
		average monthly spend
====================================================================================
*/
CREATE VIEW gold_report_customer as(
with base_query as(
SELECT
f.order_number,
f.product_key,
f.order_date,
f.sales_amount,
f.quantity,
c.customer_key,
c.customer_number,
c.first_name,
CONCAT(c.first_name, ' ',  c.last_name) as customer_name,
c.birthdate,
timestampdiff(year, c.birthdate, now()) age
FROM gold_fact_sales f
LEFT JOIN gold_dim_customer c
ON c.customer_key = f.customer_key
WHERE order_date is not null
),
customer_agg as(
SELECT
customer_key,
customer_number,
customer_name,
age,
COUNT(DISTINCT order_number) as total_order,
SUM(sales_amount) as total_sales,
sum(quantity) as total_quantity,
COUNT(DISTINCT product_key) as total_products,
MAX(order_date) as last_order_date,
timestampdiff(month, min(order_date), max(order_date)) lifespan
from base_query
group by customer_key,
customer_number,
customer_name,
age
)
SELECT 
customer_key,
customer_number,
customer_name,
age,
CASE WHEN age < 20 THEN 'UNDER 20'
	WHEN age between 20 and 29 THEN '20-29'
    WHEN age between 30 and 39 THEN '30-39'
    WHEN age between 40 and 49 THEN '40-49'
    ELSE 'ABOVE 50'
END age_group,
total_order,
total_sales,
CASE WHEN total_sales > 5000 AND lifespan >= 12 THEN 'VIP'
    WHEN lifespan < 12 THEN 'NEW'
    ELSE 'REGULAR'
END customer_segment,
total_quantity,
total_products,
last_order_date,
lifespan,
timestampdiff(month, last_order_date, NOW()) as recency,
-- Avg order value
CASE WHEN total_order = 0 THEN 0
 ELSE round((total_sales / total_order),0)
END avg_order_value,
CASE when lifespan = 0 then 0
	else ROUND((total_sales / lifespan), 0)
end avg_monthly_spend
from customer_agg
);

SELECT * from gold_report_customer;
