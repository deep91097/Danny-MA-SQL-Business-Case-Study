create database pizza_runner;
go

DROP TABLE IF EXISTS runners;
CREATE TABLE runners (
  "runner_id" INTEGER,
  "registration_date" DATE
);
INSERT INTO runners
  ("runner_id", "registration_date")
VALUES
  (1, '2021-01-01'),
  (2, '2021-01-03'),
  (3, '2021-01-08'),
  (4, '2021-01-15');


DROP TABLE IF EXISTS customer_orders;
CREATE TABLE customer_orders (
  "order_id" INTEGER,
  "customer_id" INTEGER,
  "pizza_id" INTEGER,
  "exclusions" VARCHAR(4),
  "extras" VARCHAR(4),
  "order_time" DATETIME
);

INSERT INTO customer_orders
  ("order_id", "customer_id", "pizza_id", "exclusions", "extras", "order_time")
VALUES
  ('1', '101', '1', '', '', '2020-01-01 18:05:02'),
  ('2', '101', '1', '', '', '2020-01-01 19:00:52'),
  ('3', '102', '1', '', '', '2020-01-02 23:51:23'),
  ('3', '102', '2', '', NULL, '2020-01-02 23:51:23'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '2', '4', '', '2020-01-04 13:23:46'),
  ('5', '104', '1', 'null', '1', '2020-01-08 21:00:29'),
  ('6', '101', '2', 'null', 'null', '2020-01-08 21:03:13'),
  ('7', '105', '2', 'null', '1', '2020-01-08 21:20:29'),
  ('8', '102', '1', 'null', 'null', '2020-01-09 23:54:33'),
  ('9', '103', '1', '4', '1, 5', '2020-01-10 11:22:59'),
  ('10', '104', '1', 'null', 'null', '2020-01-11 18:34:49'),
  ('10', '104', '1', '2, 6', '1, 4', '2020-01-11 18:34:49');


DROP TABLE IF EXISTS runner_orders;
CREATE TABLE runner_orders (
  "order_id" INTEGER,
  "runner_id" INTEGER,
  "pickup_time" VARCHAR(19),
  "distance" VARCHAR(7),
  "duration" VARCHAR(10),
  "cancellation" VARCHAR(23)
);

INSERT INTO runner_orders
  ("order_id", "runner_id", "pickup_time", "distance", "duration", "cancellation")
VALUES
  ('1', '1', '2020-01-01 18:15:34', '20km', '32 minutes', ''),
  ('2', '1', '2020-01-01 19:10:54', '20km', '27 minutes', ''),
  ('3', '1', '2020-01-03 00:12:37', '13.4km', '20 mins', NULL),
  ('4', '2', '2020-01-04 13:53:03', '23.4', '40', NULL),
  ('5', '3', '2020-01-08 21:10:57', '10', '15', NULL),
  ('6', '3', 'null', 'null', 'null', 'Restaurant Cancellation'),
  ('7', '2', '2020-01-08 21:30:45', '25km', '25mins', 'null'),
  ('8', '2', '2020-01-10 00:15:02', '23.4 km', '15 minute', 'null'),
  ('9', '2', 'null', 'null', 'null', 'Customer Cancellation'),
  ('10', '1', '2020-01-11 18:50:20', '10km', '10minutes', 'null');


DROP TABLE IF EXISTS pizza_names;
CREATE TABLE pizza_names (
  "pizza_id" INTEGER,
  "pizza_name" TEXT
);
INSERT INTO pizza_names
  ("pizza_id", "pizza_name")
VALUES
  (1, 'Meatlovers'),
  (2, 'Vegetarian');


DROP TABLE IF EXISTS pizza_recipes;
CREATE TABLE pizza_recipes (
  "pizza_id" INTEGER,
  "toppings" TEXT
);
INSERT INTO pizza_recipes
  ("pizza_id", "toppings")
VALUES
  (1, '1, 2, 3, 4, 5, 6, 8, 10'),
  (2, '4, 6, 7, 9, 11, 12');


DROP TABLE IF EXISTS pizza_toppings;
CREATE TABLE pizza_toppings (
  "topping_id" INTEGER,
  "topping_name" TEXT
);
INSERT INTO pizza_toppings
  ("topping_id", "topping_name")
VALUES
  (1, 'Bacon'),
  (2, 'BBQ Sauce'),
  (3, 'Beef'),
  (4, 'Cheese'),
  (5, 'Chicken'),
  (6, 'Mushrooms'),
  (7, 'Onions'),
  (8, 'Pepperoni'),
  (9, 'Peppers'),
  (10, 'Salami'),
  (11, 'Tomatoes'),
  (12, 'Tomato Sauce');
  go

  --Q1 How many pizzas were ordered?
  select * from customer_orders
  select count(order_id) as pizzas_ordered from customer_orders;
  go

  --Q2 How many unique customer orders were made?
  select count(distinct order_id) as unique_pizzas_order from customer_orders ;


  --Q3 How many successful orders were delivered by each runner?
  select a.runner_id,count(succcesful_orders) as succesful_delivered from (
  select runner_id,order_id,case when cancellation like '%Cancellation' then 'N' else 'Y' end as succcesful_orders 
  from  runner_orders order by succcesful_orders
  OFFSET 2 ROWS
  FETCH NEXT 8 ROWS ONLY) a group by a.runner_id;
  
  
  --Q4 How many of each type of pizza was delivered? 
  select CAST(a.pizza_name as nvarchar(100)) as Pizza_names,count(a.succcesful_orders) as succesful_delivered from (
  select c.order_id,p.pizza_name,case when r.cancellation like '%Cancellation' then 'N' else 'Y' end as succcesful_orders 
  from  customer_orders c left join runner_orders r on c.order_id = r.order_id left join pizza_names p on c.pizza_id = p.pizza_id
order by succcesful_orders OFFSET 2 ROWS FETCH NEXT 12 ROWS ONLY
) a group by CAST(a.pizza_name as nvarchar(100))
  select 1


  --Q5 How many Vegetarian and Meatlovers were ordered by each customer?
  select c.customer_id,CAST(p.pizza_name as nvarchar(100)) as Pizza_names,count(c.order_id) as pizza_ordered from customer_orders c left join pizza_names p
  on c.pizza_id = p.pizza_id group by c.customer_id,CAST(p.pizza_name as nvarchar(100)) order by c.customer_id;

  --Q6 What was the maximum number of pizzas delivered in a single order?
  select CAST(a.pizza_name as nvarchar(100)) as Pizza_names,count(a.succcesful_orders) as succesful_delivered from (
  select c.order_id,p.pizza_name,case when r.cancellation like '%Cancellation' then 'N' else 'Y' end as succcesful_orders 
  from  customer_orders c left join runner_orders r on c.order_id = r.order_id left join pizza_names p on c.pizza_id = p.pizza_id
  order by succcesful_orders OFFSET 2 ROWS FETCH NEXT 12 ROWS ONLY
) a group by CAST(a.pizza_name as nvarchar(100))
select 1


--Q7 For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
--clean data
select * from customer_orders
select * from runner_orders
update customer_orders set exclusions = case when exclusions = 'null' or exclusions = ' ' then null else exclusions end,
extras = case when extras = 'null' or exclusions = ' ' then null else extras end
update runner_orders set pickup_time = case when pickup_time = 'null' or pickup_time = ' ' then null else pickup_time end,
distance = case when distance = 'null' then null else distance end,
duration = case when duration = 'null' then null else duration end,
cancellation = case when cancellation = 'null' or cancellation = ' ' then null else cancellation end

update runner_orders set duration = case when duration like '%minutes' then trim( 'minutes' from duration ) 
  when duration like '%mins' then trim( 'mins' from duration )
  when duration like '%minute' then trim('minute' from duration) else duration end,
  distance = case when distance like '%km' then trim('km' from distance) else distance end

  alter table runner_orders
 alter column pickup_time datetime null
alter table runner_orders alter column distance decimal(5,1) null
 alter table runner_orders alter column duration int null;

--*******************************************
select c.customer_id, sum(case when c.exclusions is not null or c.extras is not null then 1 else 0 end) as atleast_1_change,
sum(case when c.exclusions is null and c.extras is null then 1 else 0 end) as no_change_pizza from customer_orders c left join
runner_orders r on c.order_id = r.order_id where r.cancellation is null group by customer_id order by customer_id;




--Q8 How many pizzas were delivered that had both exclusions and extras?
select c.customer_id, sum(case when c.exclusions is not null and c.extras is not null then 1 else 0 end) as both_change
 from customer_orders c left join
runner_orders r on c.order_id = r.order_id where r.cancellation is null group by customer_id order by customer_id;

--Q9 What was the total volume of pizzas ordered for each hour of the day?
select DATEPART(HOUR,order_time) as hour1,count(order_id) as num_of_pizza,ROUND(100*count(order_id)/sum(count(order_id)) over(),2) as volume_of_pizza
from customer_orders group by DATEPART(HOUR,order_time) order by DATEPART(HOUR,order_time)

--Q10 What was the volume of orders for each day of the week?
SELECT FORMAT(DATEADD(DAY,2,order_time),'dddd') day_of_the_week,COUNT(order_id) as total_pizzas_delivered
FROM customer_orders group by FORMAT(DATEADD(DAY,2,order_time),'dddd')
select 1