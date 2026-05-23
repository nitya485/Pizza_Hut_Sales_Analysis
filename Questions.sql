USE pizzahut;
-- Retrieve the total number of orders placed.
SELECT COUNT(order_id) as total_order FROM orders;

-- Calculate the total revenue generated from pizza sales.
SELECT 
ROUND(SUM(order_details.quantity * pizzas.price),2) as total_revenue
FROM order_details join pizzas
on pizzas.pizza_id = order_details.pizza_id

-- Identify the highest priced pizza.
SELECT pizza_types.name ,pizzas.price
FROM pizza_types join pizzas
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC LIMIT 1;

-- Identify the most common pizza size ordered.
SELECT pizzas.size , COUNT(order_details.order_details_id) as order_count
FROM pizzas JOIN order_details
ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizzas.size ORDER BY order_count DESC;

-- List the top 5 most ordered pizza types along with their quantities.
SELECT pizza_types.name,
SUM(order_details.quantity) as quantities
FROM pizza_types JOIN pizzas
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details
ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name ORDER BY quantities DESC LIMIT 5;

-- Join the necessary tables to find the total quantity of
-- each pizza category ordered.
SELECT pizza_types.category,
SUM(order_details.quantity) as quantity
FROM pizza_types JOIN pizzas
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details
ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category ORDER BY quantity DESC;

-- Determine the distribution of orders by hour of the day.
SELECT HOUR(order_time) as hour, COUNT(order_id) as order_count FROM orders
GROUP BY HOUR(order_time); 

-- Join relevant tables to find the category-wise distribution of pizzas.
SELECT category, COUNT(name) FROM pizza_types
GROUP BY category;

-- Group the orders by date and calculate the average num of pizzas ordered per day. 
SELECT AVG(quantity) FROM
(SELECT orders.order_date, SUM(order_details.quantity) as quantity
FROM orders JOIN order_details
ON orders.order_id = order_details.order_id
GROUP BY orders.order_date) as ordered_per_day;

-- Determine the top 3 most ordered pizza types based on revenue.
SELECT pizza_types.name,
SUM(order_details.quantity * pizzas.price) as revenue
FROM pizza_types JOIN pizzas
ON pizzas.pizza_type_id = pizza_types.pizza_type_id
JOIN order_details
ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name ORDER BY revenue DESC LIMIT 3;

-- Calculate the percentage contribution of each pizza type to total revenue.
SELECT pizza_types.category,
(SUM(order_details.quantity * pizzas.price) /
(SELECT ROUND(SUM(order_details.quantity* pizzas.price),2)as total_sales
FROM order_details JOIN pizzas
ON pizzas.pizza_id = order_details.pizza_id))*100 as revenue
FROM pizza_types Join pizzas
On pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details
ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category ORDER BY revenue DESC ;

-- Analyze the cumulative revenue generated over time.
SELECT order_date,
SUM(revenue) OVER (ORDER BY order_date) as cum_revenue
FROM
(SELECT orders.order_date,
SUM(order_details.quantity * pizzas.price) as revenue
FROM order_details JOIN pizzas
ON order_details.pizza_id = pizzas.pizza_id
JOIN orders
ON orders.order_id = order_details.order_id
GROUP BY orders.order_date) as sales

-- Detemine the top 3 most ordered pizza types based on revenue for each pizza category.
SELECT name, revenue, rnk FROM 
(SELECT category, name, revenue,
RANK() OVER(PARTITION BY category ORDER BY revenue DESC) AS rnk
FROM
(SELECT pizza_types.category, pizza_types.name,
SUM((order_details.quantity) * pizzas.price) as revenue
FROM pizza_types JOIN pizzas
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details
ON order_details.pizza_id= pizzas.pizza_id
GROUP BY pizza_types.category, pizza_types.name) AS a)as b
WHERE rnk<=3;
