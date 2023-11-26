-- Question 1
-- The sales team wants to see the 10 customers with the highest number of orders including the customer's company name, country of origin, and total orders that have been made to calculate the customer's Customer Life Value (CLV) based on purchasing history.

-- Solution Query
SELECT
  c.company_name,
  c.country,
  COUNT(o.order_id) AS total_orders
FROM orders o FULL JOIN customers c ON (o.customer_id = c.customer_id)
GROUP BY c.company_name, c.country
ORDER BY total_orders DESC
LIMIT 10

-- Question 2
-- The marketing team wants to see patterns of concurrent purchasing of products that can provide insight into customer preferences. The data must contain what products were purchased simultaneously and how often these products were purchased.

-- Solution Query
SELECT
  p1a.product_name AS product1,
  p1b.product_name AS product2,
  COUNT(*) AS frequency
FROM (
	SELECT p1.product_id AS product_id1, p2.product_id AS product_id2
	FROM order_details p1 JOIN order_details p2 ON (p1.order_id = p2.order_id)
	WHERE p1.product_id < p2.product_id
) AS product_pairs 
JOIN products p1a ON (product_pairs.product_id1 = p1a.product_id)
JOIN products p1b ON (product_pairs.product_id2 = p1b.product_id)
GROUP BY product_id1, product_id2, product1, product2
ORDER BY frequency desc
LIMIT 7

-- Question 3
-- The HR management team wants to see the performance of the company's employees, so they need to see the results of the employees' work so far, starting from how many orders were handled and how many sales results were obtained. In addition, job title and length of service need to be displayed to provide a proper performance evaluation.

-- Solution Query
SELECT
	e.first_name ||''|| e.last_name AS employee_name,
	e.title,
	e.country,
	EXTRACT (YEAR FROM AGE(now(), e.hire_date)) AS length_work,
	COUNT(o.order_id) as total_orders,
	ROUND(SUM(od.unit_price * od.quantity)) AS total_amount
FROM orders o JOIN employees e ON (o.employee_id = e.employee_id)
JOIN order_details od ON (o.order_id = od.order_id)
GROUP BY employee_name, length_work, country, title
ORDER BY total_orders DESC

-- Question 4
-- To assess risks from suppliers, procurement teams and warehouses need to know their delivery history, product quality and financial stability to evaluate cooperation contracts with suppliers.

-- Solution Query
SELECT 
	s.supplier_id, 
	s.company_name, 
	ROUND(AVG(p.reorder_level)) AS avg_reorder,
	ROUND(AVG(p.units_in_stock)) AS avg_stock, 
	ROUND(AVG(EXTRACT (DAY FROM AGE(shipped_date, order_date)))) AS avg_shipping, 
	COUNT(o.order_id) AS total_order
FROM suppliers s FULL JOIN products p ON (s.supplier_id = p.supplier_id)
JOIN order_details od ON (p.product_id = od.product_id)
JOIN orders o ON (od.order_id = o.order_id)
GROUP BY s.supplier_id, s.company_name
HAVING count(o.order_id)> 0
ORDER BY total_order DESC

-- Question 5
-- The sales team wants to know how each category is performing based on its price range. For this reason, it is necessary to have a list of categories with price ranges, total income, and number of orders for goods based on these categories.

-- Solution Query
SELECT 
	c.category_name, 
	CASE 
		WHEN p.unit_price < 20 THEN 'Below $20'
		WHEN p.unit_price >= 20 AND p.unit_price <= 50 THEN '$20 - $50'
		WHEN p.unit_price > 50 THEN 'Over $50'
		END AS price_range,
	ROUND(SUM(o.unit_price * o.quantity)) AS total_amount,
	COUNT(DISTINCT o.order_id) AS total_number_orders,
	SUM(o.quantity) AS total_goods_sold  
FROM categories c JOIN products p ON (c.category_id = p.category_id)
JOIN order_details o ON (o.product_id = p.product_id)
GROUP BY c.category_name, price_range
ORDER BY c.category_name

-- Question 6
-- The marketing team wants to develop a marketing strategy to increase sales, for this reason one of the lists needed is a list of the 10 best-selling products sold along with categories, supplier names and number of items sold.

-- Solution Query
SELECT
	p.product_name,
	c.category_name,
	s.company_name as supplier,
	SUM(o.quantity) AS total_number_orders  
FROM categories c JOIN products p ON (c.category_id = p.category_id)
JOIN order_details o ON (o.product_id = p.product_id)
JOIN suppliers s ON (p.supplier_id = s.supplier_id)
GROUP BY p.product_name, c.category_name, supplier
ORDER BY total_number_orders DESC
LIMIT 10

-- Question 7
-- The Customer Relationship Management (CRM) team received a number of complaints from customers due to delays in delivery of goods by couriers, so appropriate handling was needed so that customer satisfaction did not decrease. For this reason, the CRM Team needs a list of delivery delays containing the name of the shipping company, telephone number, and frequency of delays.

-- Solution Query
SELECT 
    shipper,
	phone,
    COUNT(order_id) as frequency,
    shipping_status
FROM (
    SELECT 
        s.company_name as shipper,
		s.phone,
        o.order_id,
        o.ship_country,
        CASE
            WHEN o.shipped_date <= o.required_date THEN 'On Time'
            WHEN o.shipped_date > o.required_date THEN 'Over Time'
			WHEN o.shipped_date IS NULL and o.required_date IS NOT NULL THEN 'Package Lost'
			ELSE 'Unknown Status'
        END AS shipping_status
    FROM orders o
    INNER JOIN shippers s ON o.ship_via = s.shipper_id
) AS subquery
GROUP BY shipper, shipping_status, phone
HAVING shipping_status = 'Over Time' OR shipping_status = 'Package Lost'
ORDER BY shipping_status, frequency DESC;