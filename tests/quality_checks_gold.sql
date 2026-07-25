/*
===============================================================================
Quality Checks
===============================================================================
Script Purpose:
    This script performs quality checks to validate the integrity,
    consistency, and accuracy of the Gold Layer.

It validates:
    - Uniqueness of surrogate keys in dimension views.
    - Referential integrity between fact and dimension views.
    - Data model relationships for analytical reporting.

Usage Notes:
    - Run these checks after creating the Gold views.
    - Investigate any records returned by these queries.
===============================================================================
*/

-- ============================================================================
-- Checking 'gold_dim_customer'
-- ============================================================================

-- Check for Duplicate Customer Keys
-- Expectation: No Results
SELECT
    customer_key,
    COUNT(*) AS duplicate_count
FROM gold_dim_customer
GROUP BY customer_key
HAVING COUNT(*) > 1;

-- ============================================================================
-- Checking 'gold_dimension_products'
-- ============================================================================

-- Check for Duplicate Product Keys
-- Expectation: No Results
SELECT
    product_key,
    COUNT(*) AS duplicate_count
FROM gold_dimension_products
GROUP BY product_key
HAVING COUNT(*) > 1;

-- ============================================================================
-- Checking 'gold_fact_sales'
-- ============================================================================

-- Check Referential Integrity Between Fact and Dimensions
-- Expectation: No Results
SELECT
    f.*
FROM gold_fact_sales AS f
LEFT JOIN gold_dim_customer AS c
    ON f.customer_key = c.customer_key
LEFT JOIN gold_dimension_products AS p
    ON f.product_key = p.product_key
WHERE c.customer_key IS NULL
   OR p.product_key IS NULL;

-- ============================================================================
-- Check for NULL Foreign Keys
-- ============================================================================

-- Expectation: No Results
SELECT *
FROM gold_fact_sales
WHERE customer_key IS NULL
   OR product_key IS NULL;

-- ============================================================================
-- Check for NULL Measures
-- ============================================================================

-- Expectation: No Results
SELECT *
FROM gold_fact_sales
WHERE sales_amount IS NULL
   OR quantity IS NULL
   OR price IS NULL;

-- ============================================================================
-- Check for Invalid Measure Values
-- ============================================================================

-- Expectation: No Results
SELECT *
FROM gold_fact_sales
WHERE sales_amount <= 0
   OR quantity <= 0
   OR price <= 0;
