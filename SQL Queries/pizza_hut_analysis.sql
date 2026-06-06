create database pizzahut;
select * from pizzas;
select * from pizza_types;
create table orders(
order_id int not null,
order_date date not null,
order_time time not null,
primary key(order_id)
);

create table order_details(
order_details_id int not null,
order_id int not null,
pizza_id text not null,
quantity int not null,
primary key(order_details_id)
);
select * from order_details;
select * from orders;
describe pizzas;
describe orders;
describe pizza_types;
describe order_details;

use pizzahut;
alter table order_details
add constraint fk_order
foreign key(order_id)
references orders(order_id);

alter table order_details
add constraint fk_pizza
foreign key(pizza_id)
references pizzas(pizza_id);

alter table pizzas
add constraint fk_pizza_type
foreign key(pizza_type_id)
references pizza_types(pizza_type_id);

alter table pizzas
modify pizza_id varchar(50);

alter table pizzas
modify pizza_type_id varchar(50);

alter table pizza_types
modify pizza_type_id varchar(50);

alter table order_details
modify pizza_id varchar(50);

alter table pizza_types
add primary key (pizza_type_id);

alter table pizzas
add primary key(pizza_id);

select distinct pizza_id
from order_details
where pizza_id not in(select pizza_id from pizzas);

delete from order_details
where pizza_id not in(select pizza_id from pizzas);

-- question based on join queries
-- Q.1 total orders with pizza name
SELECT o.order_id, pt.name AS pizza_name, od.quantity
FROM orders o
JOIN order_details od ON o.order_id = od.order_id
JOIN pizzas p ON od.pizza_id = p.pizza_id
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id;
    
   --  Q.2 total revenue per pizza
   SELECT pt.name, SUM(p.price * od.quantity) AS revenue
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name;

-- Q.3 order with date,time,and total quantity
SELECT o.order_id,o.order_date,o.order_time,SUM(od.quantity) AS total_qty
FROM orders o
JOIN order_details od ON o.order_id = od.order_id
GROUP BY o.order_id;

-- Q.4 most ordered pizza category
SELECT pt.category, SUM(od.quantity) AS total_orders
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.category
ORDER BY total_orders DESC;

-- Q.5 find all large size pizzas ordered
SELECT pt.name, p.size, od.quantity
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
WHERE p.size = 'L';
    
    -- question based on window function queries
    -- Q.1 rank pizzas by revenue
SELECT pt.name,SUM(p.price * od.quantity) AS revenue,
RANK() OVER (ORDER BY SUM(p.price * od.quantity) DESC) AS rnk
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name;

-- Q.2 running total of revenue
SELECT o.order_date,SUM(p.price * od.quantity) AS daily_revenue,SUM(SUM(p.price * od.quantity)) OVER (ORDER BY o.order_date) AS running_total
FROM orders o
JOIN order_details od ON o.order_id = od.order_id
JOIN pizzas p ON od.pizza_id = p.pizza_id
GROUP BY o.order_date;

-- Q.3 row number per category
SELECT pt.category, pt.name,
ROW_NUMBER() OVER (PARTITION BY pt.category ORDER BY p.price DESC) AS row_num
FROM pizzas p
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id;

-- Q.4 top pizza category
SELECT * FROM ( SELECT pt.category, pt.name, SUM(od.quantity) AS total_qty, 
RANK() OVER (PARTITION BY pt.category ORDER BY SUM(od.quantity) DESC) AS rnk
    FROM order_details od
    JOIN pizzas p ON od.pizza_id = p.pizza_id
    JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
    GROUP BY pt.category, pt.name
) t
WHERE rnk = 1;

-- Q.5 difference from previous order quantity
SELECT od.order_id, od.quantity,
LAG(od.quantity) OVER (ORDER BY od.order_id) AS prev_qty,
od.quantity - LAG(od.quantity) OVER (ORDER BY od.order_id) AS diff
FROM order_details od;

-- question based on subquery 
-- Q.1 find pizza with price above average
SELECT *
FROM pizzas
WHERE price > (SELECT AVG(price) FROM pizzas);

-- Q.2 order with total quantity>average 
SELECT order_id FROM order_details GROUP BY order_id
HAVING SUM(quantity) > ( SELECT AVG(total_qty)FROM (
        SELECT SUM(quantity) AS total_qty
        FROM order_details
        GROUP BY order_id
    ) t
);

-- Q.3 most expensive pizza
SELECT *
FROM pizzas
WHERE price = (SELECT MAX(price) FROM pizzas);

-- Q.4 customer(orders) who ordered specific pizza_type
SELECT DISTINCT order_id
FROM order_details
WHERE pizza_id IN (
    SELECT pizza_id
    FROM pizzas
    WHERE pizza_type_id = 'classic_deluxe'
);

-- Q.5 pizza types never ordered
SELECT * FROM pizza_types pt WHERE pt.pizza_type_id NOT IN (
SELECT DISTINCT p.pizza_type_id FROM pizzas p
JOIN order_details od ON p.pizza_id = od.pizza_id
);

-- question based on aggregate function
-- Q.1 Find average price of pizzas by size
SELECT pizzas.size, AVG(pizzas.price) AS avg_price
FROM pizzas GROUP BY pizzas.size;

-- Q.2 Count how many orders were placed each day
SELECT orders.order_date, COUNT(orders.order_id) AS total_orders
FROM orders GROUP BY orders.order_date;

-- Q.3 Find maximum quantity ordered in a single order item
SELECT MAX(order_details.quantity) AS max_quantity
FROM order_details;

-- Q.4 Find total number of pizzas sold
SELECT SUM(order_details.quantity) AS total_pizzas_sold
FROM order_details;

-- Q.5 Find minimum and maximum pizza price
SELECT MIN(pizzas.price) AS lowest_price,
       MAX(pizzas.price) AS highest_price
FROM pizzas;

