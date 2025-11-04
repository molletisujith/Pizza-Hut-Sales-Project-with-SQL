CREATE DATABASE pizzahut_db;

USE pizzahut_db;

SELECT * FROM orders;
SELECT * FROM order_details;
SELECT * FROM pizzas;
SELECT * FROM pizza_types;

-- Q1 Retrieve the total number of orders placed.

SELECT COUNT(
	order_id) 
		AS tot_orders 
FROM orders;

-- Q2 Calculate the total revenue generated from pizza sales.

SELECT ROUND(SUM(
	OD.quantity * P.price),0)
		AS Revenue 
	FROM order_details 
		AS OD 
	LEFT JOIN pizzas
		AS P 
	ON OD.pizza_id =
P.pizza_id;

-- Q3 Identify the highest-priced pizza.

SELECT TOP 1 
	PT.name , 
	ROUND(P.price,2) 
		AS Highest_Price
	FROM pizzas 
		AS P 
LEFT JOIN pizza_types 
	AS PT
	ON P.pizza_type_id = PT.pizza_type_id
ORDER BY P.price DESC;

-- Q4 Identify the most common pizza size ordered.

SELECT TOP 1 
	P.size , 
	COUNT(OD.order_details_id) 
		AS No_of_pizzas 
	FROM pizzas AS P
LEFT JOIN order_details 
	AS OD ON P.pizza_id = OD.pizza_id
		GROUP BY P.size 
ORDER BY No_of_pizzas DESC;

-- Q5 List the top 5 most ordered pizza types along with their quantities.

SELECT TOP 5
		PT.name ,
		SUM(OD.quantity) 
			AS TOT_orders 
	FROM pizza_types 
		AS PT 
LEFT JOIN pizzas 
	AS P 
		ON PT.pizza_type_id = P.pizza_type_id
LEFT JOIN order_details 
	AS OD ON P.pizza_id = OD.pizza_id 
		GROUP BY PT.name 
ORDER BY TOT_orders DESC;

-- Q6 Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT PT.category , 
	SUM(OD.quantity) AS TOT_Quantity
		FROM pizza_types AS PT 
	LEFT JOIN pizzas AS P
		ON PT.pizza_type_id = P.pizza_type_id 
	LEFT JOIN order_details AS OD 
		ON P.pizza_id = OD.pizza_id
GROUP BY PT.category 
ORDER BY TOT_Quantity DESC;

-- Q7 Determine the distribution of orders PER day.

SELECT O.date,
	SUM(OD.quantity) AS TOT_ORDERS 
		FROM Orders AS O 
LEFT JOIN order_details AS OD 
	ON O.order_id = OD.order_id 
	GROUP BY O.date

-- Q8 Join relevant tables to find the category-wise distribution of pizzas.

SELECT category ,
	COUNT(pizza_type_id) AS Pizza_types
		FROM pizza_types 
GROUP BY category;

-- Q9 Determine the top 3 most ordered pizza types based on revenue.

SELECT TOP 3 PT.name ,
	SUM(OD.quantity * P.price) AS Revenue 
	FROM order_details 
		AS OD 
	LEFT JOIN pizzas AS P 
ON OD.pizza_id = P.pizza_id
	LEFT JOIN pizza_types 
		AS PT
ON p.pizza_type_id = PT.pizza_type_id
	GROUP BY PT.name 
ORDER BY SUM(OD.quantity * P.price) DESC;

-- Q10 Calculate the percentage contribution of each pizza type to total revenue.

SELECT PT.category ,
	SUM(OD.quantity * P.price) AS Revenue , 
	ROUND(SUM(OD.quantity * P.price) * 100.0/SUM(SUM(OD.quantity * P.price)) OVER (),2) AS Percentges
	FROM order_details 
		AS OD 
	LEFT JOIN pizzas AS P 
ON OD.pizza_id = P.pizza_id
	LEFT JOIN pizza_types 
		AS PT
ON p.pizza_type_id = PT.pizza_type_id
	GROUP BY PT.category 
ORDER BY SUM(OD.quantity * P.price) DESC;


-- Q11Determine the top 3 most ordered pizza types based on revenue for each pizza category.

WITH CTE1 AS (
		SELECT PT.name , PT.category,
	round(SUM(OD.quantity * P.price),2) AS Revenue ,
	RANK() OVER ( PARTITION BY PT.category order by SUM(OD.quantity * P.price) desc) as ranks
	FROM order_details 
		AS OD 
	LEFT JOIN pizzas AS P 
ON OD.pizza_id = P.pizza_id
	LEFT JOIN pizza_types 
		AS PT
ON p.pizza_type_id = PT.pizza_type_id
GROUP BY PT.name , PT.category)
SELECT name ,
	category,
	Revenue FROM CTE1
WHERE ranks <=3;

-- Q12 Group the orders by date and calculate the average number of pizzas ordered per day.

WITH CTE1 AS (
	SELECT O.date,
	SUM(OD.quantity) AS TOT_ORDERS 
		FROM Orders AS O 
LEFT JOIN order_details AS OD 
	ON O.order_id = OD.order_id 
	GROUP BY O.date)
SELECT AVG(
	TOT_ORDERS) AS AVG_ORDER_PERDAY 
FROM CTE1;

-- Q13 Analyze the cumulative revenue generated over time.

WITH CTE2 AS (
	SELECT MONTH(o.date) AS Months,
	SUM(OD.quantity * P.price) AS REVENUE 
FROM orders AS O 
	LEFT JOIN order_details AS OD 
		ON O.order_id = OD.order_id 
	LEFT JOIN pizzas AS P 
		ON OD.pizza_id = P.pizza_id 
GROUP BY MONTH(o.date))
SELECT Months,
	   round(REVENUE,0) AS REVENUE,
	   round(SUM(REVENUE) OVER (ORDER BY MONTHS ASC),0) AS Running_Total 
FROM CTE2;