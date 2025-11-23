-- Project Overview: Pizza Sales Analysis Using SQL


use pizzahut;

# Q 1 Retrieve the total number of orders placed.

select * from orders;

select count(order_id) as total_orders from orders;

#Q 2 calculate the total revenue generatred from  sales.alter

select
     ROUND(SUM(order_details.quantity * pizzas.price),
    2) as total_sales
from order_details join pizzas
on pizzas.pizza_id = order_details.pizza_id;

# Q 3 Identify the highest - priced pizza.

select pizza_types.name, pizzas.price 
from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
order by pizzas.price desc limit 1;

select max(price) as highest_price from pizzas;

  # Q 4 Identify the most common pizza size ordered.

select pizzas.size, count(order_details.order_details_id) as order_count
from pizzas
join order_details on pizzas.pizza_id = order_details.pizza_id
group by pizzas.size
order by order_count desc;

# Q 5 List the top 5 most ordered pizza types along with their quantities.alter

select pizza_types.name, sum(order_details.quantity) as quantity 
from pizza_types
join pizzas on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.name
order by quantity desc;


# Q 6 join the necessary tables to find the total quantity of each pizza category ordered.

SELECT 
    pizza_types.category,
    SUM(order_details.quantity) AS quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY quantity DESC;

# Determine the distribution of orders by hour of the day.

select hour (order_time), count(order_id) as order_count 
from orders
group by hour(order_time);

# Q 8 join relevant tables to find the category-wise distribution of pizzas.


select category, count(name) from pizza_types
group by category;

# Q 9 Determine the top 3 most ordered pizza types based on revenue.

select pizza_types.name,
sum(order_details.quantity * pizzas.price ) as revenue
from pizza_types join pizzas
on pizzas.pizza_type_id = pizza_types.pizza_type_id
join order_details
on order_details.pizza_id =pizzas.pizza_id
group by pizza_types.name order by revenue desc limit 3;

# Q 10 claculate the percentage contribution of each pizza type to total revenue.

select pizza_types.category,
round(sum(order_details.quantity*pizzas.price)/(select 
round(sum(order_details.quantity * pizzas.price),2) as total_sales
from 
order_details
join
pizzas on pizzas.pizza_id =order_details.pizza_id)*100,2) as revenue
from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.category order by revenue desc;

#  Q 11 Analyze the cumulative revenue generated over time.

use pizzahut;
select order_date,sum(revenue) over(order by  order_date) as cum_revenue
from
(select orders.order_date,
sum(order_details.quantity* pizzas.price) as revenue
from order_details join pizzas
on order_details.pizza_id = pizzas.pizza_id
join orders
on orders.order_id = order_details.order_id
group by orders.order_date) as sales;

#  12 determine the top 3 most ordered pizza types based on revenue for each pizza category.alter
select name, revenue from
(select category, name, revenue,
rank() over(partition by category order by revenue desc)as rn
from
(select pizza_types.category, pizza_types.name,
sum((order_details.quantity) * pizzas.price) as revenue
from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.category, pizza_types.name)as a) as b
where rn<= 3;
