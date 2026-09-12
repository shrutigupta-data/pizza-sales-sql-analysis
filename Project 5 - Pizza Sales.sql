# SQL PROJECT 5 - Pizza Sales
USE Projects;
select * from pizzas;
select * from pizza_types;
select * from pizza_orders;
select * from order_details;

-- Basic:
#1. Retrieve the total number of orders placed.
select count(order_id) as 'Total_orders' from pizza_orders;

#2. Calculate the total revenue generated from pizza sales.
Select round(sum(t1.price * t2.quantity),2) as 'Total_revenue' from pizzas t1
inner join order_details t2
on t1.pizza_id = t2.pizza_id;

#3. Identify the highest-priced pizza.
select * from pizzas t1
inner join pizza_types t2
on t1.pizza_type_id = t2.pizza_type_id
order by t1.price desc limit 1;

#4. Identify the most common pizza size ordered.
select t1.size, count(t2.order_details_id) as num_of_pizzas from pizzas t1
join order_details t2
on t1.pizza_id = t2.pizza_id
group by t1.size
order by num_of_pizzas desc limit 1;

#5. List the top 5 most ordered pizza types along with their quantities.
select t2.name, sum(t3.quantity) as pizzas_ordered from pizzas t1
join pizza_types t2
on t1.pizza_type_id = t2.pizza_type_id
join order_details t3
on t1.pizza_id = t3.pizza_id
group by t2.name
order by pizzas_ordered desc limit 5;

-- Intermediate:
#1. Join the necessary tables to find the total quantity of each pizza category ordered.
select t2.category, sum(t3.quantity) as quantity from pizzas t1
join pizza_types t2
on t1.pizza_type_id = t2.pizza_type_id
join order_details t3
on t1.pizza_id = t3.pizza_id
group by t2.category
order by quantity desc;

#2. Determine the distribution of orders by hour of the day.
select hour(time) as hour,count(order_id) as orders_count from pizza_orders
group by hour(time);

#3. Join relevant tables to find the category-wise distribution of pizzas.
SELECT pt.category,
       COUNT(p.pizza_id) AS total_pizzas
FROM pizzas p
JOIN pizza_types pt
ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.category;

#4. Group the orders by date and calculate the average number of pizzas ordered per day.
select round(avg(total_orders),0) as 'avg_opd'
from(select t1.date, sum(t2.quantity) as total_orders from pizza_orders t1
join order_details t2
on t1.order_id = t2.order_id
group by t1.date) as daily_orders;

#5. Determine the top 3 most ordered pizza types based on revenue.
Select t3.name, round(sum(t1.price * t2.quantity),2) as 'Total_revenue' from pizzas t1
inner join order_details t2
on t1.pizza_id = t2.pizza_id
join pizza_types t3
on t1.pizza_type_id = t3.pizza_type_id
group by t3.name
order by total_revenue desc limit 3;

-- Advanced:
#1. Calculate the percentage contribution of each pizza type to total revenue.
SELECT
    pt.name,
    ROUND(SUM(p.price * od.quantity), 2) AS total_revenue,
    ROUND(
        (SUM(p.price * od.quantity) /
        (
            SELECT SUM(p2.price * od2.quantity)
            FROM pizzas p2
            JOIN order_details od2
                ON p2.pizza_id = od2.pizza_id
        )) * 100,
        2
    ) AS percentage_contribution
FROM pizzas p
JOIN order_details od
    ON p.pizza_id = od.pizza_id
JOIN pizza_types pt
    ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name
ORDER BY percentage_contribution DESC;

#2. Analyze the cumulative revenue generated over time.
SELECT date,
       SUM(revenue) OVER (ORDER BY date) AS cumulative_revenue
FROM
(
    SELECT t3.date,
           SUM(t1.price * t2.quantity) AS revenue
    FROM pizzas t1
    JOIN order_details t2
        ON t1.pizza_id = t2.pizza_id
    JOIN pizza_orders t3
        ON t2.order_id = t3.order_id
    GROUP BY t3.date
) AS sales;

#3. Determine the top 3 most ordered pizza types based on revenue for each pizza category.
Select name, total_revenue from
(select category, name, Total_revenue,
rank() over (partition by category order by Total_revenue desc) as ranking from
(Select t3.category,t3.name, round(sum(t1.price * t2.quantity),2) as 'Total_revenue' from pizzas t1
inner join order_details t2
on t1.pizza_id = t2.pizza_id
join pizza_types t3
on t1.pizza_type_id = t3.pizza_type_id
group by t3.category, t3.name
order by total_revenue desc) as a) as b
where ranking <= 3;