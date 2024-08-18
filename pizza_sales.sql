create database pizza;
use pizza;
CREATE TABLE orders (
    order_id INT NOT NULL PRIMARY KEY,
    order_date DATE NOT NULL,
    order_time TIME NOT NULL
);
CREATE TABLE order_details (
    order_details_id INT NOT NULL PRIMARY KEY,
    order_id TEXT NOT NULL,
    pizza_id TEXT NOT NULL,
    quantity INT NOT NULL
);
SELECT 
    *
FROM
    pizzas;
SELECT 
    *
FROM
    pizza_types;
SELECT 
    *
FROM
    orders;
SELECT 
    *
FROM
    order_details;

-- 1. Retrieve the total number of orders placed.
SELECT 
    COUNT(*)
FROM
    orders;

-- 2. Calculate the total revenue generated from pizza sales.
SELECT 
    ROUND(SUM(quantity * price), 2)
FROM
    order_details
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id;
    
-- 3. Identify the highest-priced pizza.

SELECT 
    name, price
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY price DESC
LIMIT 1;

-- 4. Identify the most common pizza size ordered.

SELECT 
    COUNT(order_id) AS count_of_id, size
FROM
    order_details
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id
GROUP BY size
ORDER BY count_of_id DESC;

-- 5. List the top 5 most ordered pizza types along with their quantities.

SELECT 
    COUNT(quantity) AS count_of_quantity, name
FROM
    order_details
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id
        JOIN
    pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id
GROUP BY name
ORDER BY count_of_quantity DESC
LIMIT 5;

-- 6. Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT 
    category, COUNT(quantity) AS count_of_quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY category;

-- 7. Determine the distribution of orders by hour of the day.

SELECT 
    COUNT(order_id), HOUR(order_time) AS hour_of_order
FROM
    orders
GROUP BY hour_of_order;

-- 8. Join relevant tables to find the category-wise distribution of pizzas.

SELECT 
    category, COUNT(name)
FROM
    pizza_types
GROUP BY category;

-- 9. Group the orders by date and calculate the average number of pizzas ordered per day.

SELECT 
    ROUND(AVG(_quantity), 0)
FROM
    (SELECT 
        SUM(quantity) AS _quantity, (order_date)
    FROM
        order_details
    JOIN orders ON order_details.order_id = orders.order_id
    GROUP BY order_date) AS order_quantity;

-- 10. Determine the top 3 most ordered pizza types based on revenue.

SELECT 
    name, SUM(quantity * price) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY name
ORDER BY revenue DESC
LIMIT 3;

-- 11. Calculate the percentage contribution of each pizza type to total revenue.

SELECT 
    category,
    ROUND((SUM(quantity * price) / (SELECT 
                    ROUND(SUM(quantity * price), 2)
                FROM
                    order_details
                        JOIN
                    pizzas ON order_details.pizza_id = pizzas.pizza_id)) * 100,
            2) AS rnew
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY category
order by rnew desc;

-- 12. Analyze the cumulative revenue generated over time.
  
  select order_date,sum(revenue) over(order by order_date) as cum_revenue 
  from (select order_date,sum(quantity*price) as revenue 
  from order_details join pizzas on 
  order_details.pizza_id=pizzas.pizza_id join orders  
  on orders.order_id=order_details.order_id
  group by order_date) as sales;
  
  -- 13. Determine the top 3 most ordered pizza types based on revenue for each pizza category.
  
  select name,revenue from 
(select category,name,revenue,rank() over(partition by category order by revenue) as rn from 
(SELECT 
    category,name ,SUM(quantity * price) as revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY category,name ) as a) as b
where rn<=3
  
