create database dannys_diner;
use [dannys_diner]
go
CREATE TABLE sales (
  "customer_id" VARCHAR(1),
  "order_date" DATE,
  "product_id" INTEGER
);

INSERT INTO sales
  ("customer_id", "order_date", "product_id")
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');

  go
  CREATE TABLE menu (
  "product_id" INTEGER,
  "product_name" VARCHAR(5),
  "price" INTEGER
);

INSERT INTO menu
  ("product_id", "product_name", "price")
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');

  go
  CREATE TABLE members (
  "customer_id" VARCHAR(1),
  "join_date" DATE
);

INSERT INTO members
  ("customer_id", "join_date")
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');


  go
  --Q1 What is the total amount each customer spent at the restaurant?

  select s.customer_id,sum(m.price) as customer_spent from sales s left join menu m on s.product_id = m.product_id group by s.customer_id;
  go

  --Q2 How many days has each customer visited the restaurant?


  select customer_id,count(distinct order_date) as no_of_days from [dbo].[sales] group by customer_id;
  go

  --Q3 What was the first item from the menu purchased by each customer?
select customer_id,product_name from (
select s.[customer_id],s.[order_date],m.product_name,ROW_NUMBER() OVER(Partition by customer_id order by order_date) as rank_
from sales s
Left join menu m on s.product_id = m.product_id ) a WHERE a.rank_ = 1 group by customer_id,product_name;

--Q4 What is the most purchased item on the menu and how many times was it purchased by all customers?
select top 1 m.product_name,count(s.product_id) as count_of_purchases from sales s 
left join menu m on s.product_id = m.product_id 
group by m.product_name order by count(s.product_id) desc;

select 1

--Q5 Which item was the most popular for each customer?
select customer_id,product_name,count_of_purchases from (
select s.[customer_id],m.product_name,count(s.product_id) as count_of_purchases,ROW_NUMBER() OVER(Partition by customer_id order by count(s.product_id) desc) as rank_
from sales s
Left join menu m on s.product_id = m.product_id group by s.[customer_id],m.product_name) a WHERE a.rank_ = 1;
go

--Q6 Which item was purchased first by the customer after they became a member?
select customer_id,order_date,product_name from (
select s.customer_id,s.order_date,m.product_name,DENSE_RANK() over(partition by s.customer_id order by s.order_Date) as rank_ from sales s 
left join menu m on s.product_id = m.product_id left join members me on s.customer_id = me.customer_id
where s.order_date >= me.join_date) a where rank_ = 1;
go


--Q7 Which item was purchased just before the customer became a member?
select customer_id,order_date,product_name from (
select s.customer_id,s.order_date,m.product_name,ROW_NUMBER() over(partition by s.customer_id order by s.order_Date desc) as rank_ from sales s 
left join menu m on s.product_id = m.product_id left join members me on s.customer_id = me.customer_id
where s.order_date < me.join_date) a where rank_ = 1;


--Q8 What is the total items and amount spent for each member before they became a member?
select s.customer_id,count(s.product_id) as total_items,sum(m.price) as amount_spent from sales s left join menu m on s.product_id = m.product_id
left join members me on s.customer_id = me.customer_id where s.order_date<me.join_date group by s.customer_id;


--Q9 If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
select customer_id,sum(points) as total_points from (
select s.customer_id,case when s.product_id = 1 then m.price*20
else m.price*10 END as points from sales s left join menu m on s.product_id = m.product_id) a group by customer_id;


--Q10 In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi
-- how many points do customer A and B have at the end of January?
select customer_id,sum(points) as total_points from (
select s.customer_id,s.order_date,me.join_date,m.price,case when s.order_date between me.join_date and DATEADD(day,7,me.join_date) then m.price*20
when s.product_id = 1 then m.price*20
else m.price*10 END as points from sales s left join menu m on s.product_id = m.product_id left join 
members me on s.customer_id = me.customer_id) a where MONTH(order_date) = 1  group by customer_id;
go


