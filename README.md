# Northwind-Data-Analysis

## Data Understanding
The Northwind database represents a fictional company that sells products to customers and manages various aspects of the business, such as orders, suppliers, employees, and products. This database has 14 tables and the table relationships are showcased in the following entity relationship diagram.
<p align="center">
  <img width=60% height=60%" src="https://github.com/renatasa13/Northwind-Data-Analysis/assets/93513745/e3d6af89-e10d-4580-bf2d-0898d748de11">
  
### Data Dictionary
* Categories Table : Various categories of products sold along with descriptions and images
* CustomerCustomerDemo Table : Information about the relationship between customers (Customers) and customer demographics.
* CustomerDemographics Table : Customer demographics such as preferences for specific products or categories.
* Customers Table : Contains information about customers, including company name, contact details, address, and other customer-related data.
* Employees Table : Stores information about employees, including names, addresses, date of birth, and other employee-related details.
* EmployeeTerritories Table : Links employees (Employees) to the territories (Territories) they handle.
* OrderDetails Table : Details for each item in every order, including product details, price, quantity, and discounts.
* Orders Table : Stores information about each order, such as order date, and shipping date.
* Products Table : Contains information about the products for sale, including product name, price, supplier, and category.
* Region Table : Regions or geographical areas.
* Shippers Table : Holds information about shipping companies or entities responsible for order delivery.
* Suppliers Table : Details product suppliers, including company name, contact, and address.
* Territories Table : Contains information about sales territories or areas, related to the Region table.
* US States Table : States in the United States, related to the Region table.

## Business Question

### Question 1 
The sales team wants to see the 10 customers with the highest number of orders including the customer's company name, country of origin, and total orders that have been made to calculate the customer's Customer Life Value (CLV) based on purchasing history.

```sql
-- Solution Query
SELECT
  c.company_name,
  c.country,
  COUNT(o.order_id) AS total_orders
FROM orders o FULL JOIN customers c ON (o.customer_id = c.customer_id)
GROUP BY c.company_name, c.country
ORDER BY total_orders DESC
LIMIT 10
```

### Question 2
The marketing team wants to see patterns of concurrent purchasing of products that can provide insight into customer preferences. The data must contain what products were purchased simultaneously and how often these products were purchased.

```sql
-- Solution Query
SELECT
  p1a.product_name AS product1,
  p1b.product_name AS product2,
  COUNT(*) AS frequency
FROM(
	SELECT p1.product_id AS product_id1, p2.product_id AS product_id2
	FROM order_details p1 JOIN order_details p2 ON (p1.order_id = p2.order_id)
	WHERE p1.product_id < p2.product_id
) AS product_pairs 
JOIN products p1a ON (product_pairs.product_id1 = p1a.product_id)
JOIN products p1b ON (product_pairs.product_id2 = p1b.product_id)
GROUP BY product_id1, product_id2, product1, product2
ORDER BY frequency desc
LIMIT 7
```
