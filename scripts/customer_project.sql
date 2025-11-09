/*
===============================================================================
Customer Report
===============================================================================
Purpose:
    - This report consolidates key customer metrics and behaviors

Highlights:
    1. Gathers essential fields such as names, ages, and transaction details.
	2. Segments customers into categories (VIP, Regular, New) and age groups.
    3. Aggregates customer-level metrics:
	   - total orders
	   - total sales
	   - total quantity purchased
	   - total products
	   - lifespan (in months)
    4. Calculates valuable KPIs:
	    - recency (months since last order)
		- average order value
		- average monthly spend
===============================================================================
*/
CREATE VIEW gold.product_reports AS
WITH base_query AS 
(
SELECT 
	s.customer_key, 
	s.order_number, 
	s.order_date, 
	s.sales_amount,
	s.quantity,
	p.product_key,
	p.product_name, 
	p.category, 
	p.subcategory, 
	p.product_cost
FROM gold.fact_sales s
LEFT JOIN gold.dim_products p
ON s.product_key = p.product_key
WHERE s.order_date IS NOT NULL
)

, product_aggreations AS (
SELECT 
	product_key,
	product_name, 
	category, 
	subcategory, 
	product_cost,
	MIN(order_date) AS last_order_date,
	COUNT(DISTINCT order_number) AS total_orders, 
	SUM(sales_amount) AS revenue, 
	SUM(quantity) AS total_quantity, 
	COUNT(DISTINCT customer_key) AS total_customers,
	DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) lifespan
FROM base_query
GROUP BY product_key,
	product_name, 
	category, 
	subcategory, 
	product_cost
)
SELECT	
	product_key,
	product_name, 
	category, 
	subcategory, 
	product_cost,
	total_orders, 
	revenue, 
	CASE 
		WHEN revenue > 50000 THEN 'High Performer'
		WHEN revenue >= 10000 THEN 'Mid-Range'
		ELSE 'Low Performer'
	END product_segment,
	total_quantity, 
	total_customers,
	-- recency
	DATEDIFF(MONTH, last_order_date, GETDATE()) recency,
  
	-- average order revenue
	CASE	
		WHEN total_orders = 0 THEN 0
		ELSE revenue / total_orders
	END avg_order_revenue, 
	
	-- avergage monthly revenue 
	CASE 
		WHEN lifespan = 0 THEN revenue
		ELSE revenue / lifespan
	END avg_month_revenue
FROM product_aggreations
