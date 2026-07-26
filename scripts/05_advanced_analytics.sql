/*
====================================================================================
Advanced Analytics Queries
====================================================================================

Purpose:
    - Perform deeper business analysis on the gold layer data warehouse.
    - Identify sales trends, customer behavior, and product performance.

Analysis Includes:
    1. Monthly sales trends and running totals
    2. Year-over-year product performance comparison
    3. Average sales benchmarking
    4. Category contribution analysis
    5. Product cost segmentation
    6. Customer segmentation analysis

SQL Concepts Demonstrated:
    - Common Table Expressions (CTEs)
    - Window Functions
    - Running Totals
    - LAG / Previous Year Comparison
    - Aggregations
    - Customer Segmentation Logic

====================================================================================
*/

SELECT DATE_FORMAT(order_date, '%Y-%m-01')as year, sum(sales_amount) total_sales,
count(distinct customer_key) as customers
from gold_fact_sales
where order_date is not null
group by DATE_FORMAT(order_date, '%Y-%m-01')
order by DATE_FORMAT(order_date, '%Y-%m-01');


-- total sales per month and running total sales

SELECT 
order_date, 
total_sales,
sum(total_sales) over(partition  by year(order_date) order by order_date) as running_total
from(
	select date_format(order_date, '%Y-%m-01') order_date,
    sum(sales_amount) total_sales
	from gold_fact_sales
	where order_date is not null
	group by date_format(order_date, '%Y-%m-01')
)t;

-- Analysze the yearly performance of the products by comparing their 
-- sales  to both the average sales performance of the product and prev years sales

WITH yearly_product_sales as(
	SELECT 
	year(f.order_date) order_year,
	p.product_name,
	sum(f.sales_amount) current_sales
	from gold_fact_sales f
	LEFT JOIN gold_dimension_products p
	ON f.product_key = p.product_key
	Where order_date is not null
	group by year(f.order_date), p.product_name
)
select 
order_year,
product_name,
current_sales,
AVG(current_sales) over(partition by product_name) avg_sales,
current_sales - AVG(current_sales) over(partition by product_name) diff_avg,
CASE WHEN current_sales - AVG(current_sales) over(partition by product_name) > 0 THEN 'ABOVE AVG'
	WHEN current_sales - AVG(current_sales) over(partition by product_name) < 0 THEN 'BELOW AVG'
    ELSE 'AVG'
END avg_change,
LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year) py_sales
from yearly_product_sales
order by product_name, order_year;

-- cleaner approach
WITH yearly_product_sales AS (
    SELECT
	YEAR(f.order_date) AS order_year,
	p.product_name,
	SUM(f.sales_amount) AS current_sales
    FROM gold_fact_sales f
    LEFT JOIN gold_dimension_products p
	ON f.product_key = p.product_key
    WHERE f.order_date IS NOT NULL
    GROUP BY YEAR(f.order_date), p.product_name
),
sales_comparison AS (
    SELECT
	order_year,
	product_name,
	current_sales,
	AVG(current_sales) OVER (PARTITION BY product_name) AS avg_sales,
	LAG(current_sales) OVER (
		PARTITION BY product_name
		ORDER BY order_year
	) AS py_sales
    FROM yearly_product_sales
)
SELECT
order_year,
product_name,
current_sales,
avg_sales,
current_sales - avg_sales AS diff_avg,
CASE WHEN current_sales > avg_sales THEN 'ABOVE AVG'
	WHEN current_sales < avg_sales THEN 'BELOW AVG'
	ELSE 'AVG'
END AS avg_change,
py_sales,
current_sales - py_sales AS diff_py,
CASE WHEN py_sales IS NULL THEN 'N/A'
	WHEN current_sales > py_sales THEN 'INCREASE'
	WHEN current_sales < py_sales THEN 'DECREASE'
	ELSE 'NO CHANGE'
END AS py_change

FROM sales_comparison
ORDER BY product_name, order_year;


-- what categories contributed the most overall
WITH category_sales as(
SELECT category, sum(sales_amount) total_sales
from gold_fact_sales f
left join gold_dimension_products p 
on p.product_key = f.product_key
group by category
) 
SELECT category, total_sales,
SUM(total_sales) over() overall_sales,
concat(round((CAST(total_sales as DECIMAL(18,2))/ sum(total_sales) over())* 100,2), '%') as perc_of_total
from category_sales;

-- segment producrs in cost ranges and count how many products fall into each segment

WITH product_segment as(
select product_key, product_name, cost,
CASE WHEN cost < 100 THEN 'Below 100'
	WHEN cost between 100 and 500 THEN '100-500'
    WHEN cost between 500 and 1000 THEN '500-1000'
    ELSE 'ABOVE 1000'
END cost_range
from gold_dimension_products
) 
SELECT cost_range,
count(product_key) as total_pruducts
FROM product_segment
GROUP BY cost_range;


/*Group customers into three segments based on their spending behavior:
	VIP: Customers with at least 12 months of history and spending more than €5,000.
	Regular: Customers with at least 12 months of history but spending €5,000 or less.
	New: Customers with a lifespan less than 12 months.
And find the total number of customers by each group
*/

WITH customer_spending as (
select 
c.customer_key,
sum(f.sales_amount) total_sales,
MIN(order_date) as first_date,
MAX(order_date) as last_date,
timestampdiff(month, MIN(order_date), MAX(order_date)) lifespan
FROM gold_fact_sales f 
LEFT JOIN gold_dim_customer c
ON f.customer_key = c.customer_key
GROUP BY c.customer_key
),
customer_seg as (
SELECT customer_key,
total_sales,
lifespan,
CASE WHEN total_sales > 5000 AND lifespan >= 12 THEN 'VIP'
    WHEN lifespan < 12 THEN 'NEW'
    ELSE 'REGULAR'
END customer_segment
FROM customer_spending
)
SELECT
    customer_segment,
    COUNT(*) AS customer_count
FROM customer_seg
GROUP BY customer_segment
ORDER BY customer_count DESC;
