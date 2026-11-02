select*from order_details
select*from orders
select*from pizza_types
select*from pizzas

--Basic:
--1.Retrieve the total number of orders placed.

select count(order_id) as number_of_orders from orders

--2.Calculate the total revenue generated from pizza sales.

select round(sum(o.quantity*p.price),2) as total_revenue from order_details o join
pizzas p on o.pizza_id=p.pizza_id

--3.Identify the highest-priced pizza.

select t.name,round((p.price),2) from pizza_types t join pizzas p
on t.pizza_type_id=p.pizza_type_id where p.price=(select max(price) from pizzas)

--4.Identify the most common pizza size ordered.

select top 1 p.size,count(d.order_id) as oredr_count from order_details d
join pizzas p on p.pizza_id=d.pizza_id group by p.size

--5.List the top 5 most ordered pizza types along with their quantities.

select top 5 p.pizza_type_id,count(d.quantity) as quantity from order_details d
join pizzas p on p.pizza_id=d.pizza_id group by p.pizza_type_id order by quantity desc


--Intermediate:
--6.Join the necessary tables to find the total quantity of each pizza category ordered.

select t.category,count(d.quantity) as category_count from order_details d 
join pizzas p on d.pizza_id=p.pizza_id join pizza_types t on
t.pizza_type_id=p.pizza_type_id group by t.category

--7.Determine the distribution of orders by hour of the day.

select datepart(hour,time) as time_HH,count(order_id) as total_orders
from orders group by datepart(hour,time) order by total_orders desc

--8.Join relevant tables to find the category-wise distribution of pizzas.

select category,count(name) as total_pizzas from pizza_types group by category

--9.Group the orders by date and calculate the average number of pizzas ordered per day.

select avg(a.total_pizzas) as daily_average_orders from
(select o.date,count(d.quantity) as total_pizzas from order_details d join
orders o on o.order_id=d.order_id group by o.date ) a

--10.Determine the top 3 most ordered pizza types based on revenue.

select top 3 t.name,sum(d.quantity*p.price) as total_revenue from pizza_types t join
pizzas p on p.pizza_type_id=t.pizza_type_id join order_details d on 
d.pizza_id=p.pizza_id group by t.name order by total_revenue desc


--Advanced:
--11.Calculate the percentage contribution of each pizza type to total revenue.

select p.pizza_type_id,round(sum(p.price*d.quantity)/(select sum(p.price*d.quantity) 
from pizzas p join order_details d on p.pizza_id=d.pizza_id)*100,2) as 
revenue_percentage_of_pizzatypes from pizzas p join order_details d
on p.pizza_id=d.pizza_id group by p.pizza_type_id

--12.Determine the top 3 most ordered pizza types based on revenue for each pizza category.

select category,name,revenue,r from
(select category,name,revenue, dense_rank() over(partition by category order by revenue desc)
as r from
(select t.category,t.name,sum(p.price*d.quantity) as revenue from pizzas p join pizza_types t
on p.pizza_type_id=t.pizza_type_id join order_details d on d.pizza_id=p.pizza_id
group by t.category,t.name) as A) as B where r<=3

--13.Analyze the cumulative revenue generated over time.

select date,sum(revenue) over(order by date) as cumulative_revenue from
(select o.date,round(sum(d.quantity*p.price),2) as revenue from order_details d
join orders o on d.order_id=o.order_id join pizzas p on d.pizza_id=p.pizza_id 
group by o.date) as sales