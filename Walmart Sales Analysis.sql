Create database if not exists walmart;
Use walmart;
Create table sales(
invoice_id varchar(30) not null primary key,
branch_id varchar(5) not null,
city varchar(30) not null,
customer_type varchar(30) not null,
gender varchar(10) not null,
product_line varchar(100) not null, 
unit_price decimal (10,2) not null,
quantity int(20) not null,
vat float(6,4) not null,
total decimal(10,4) not null,
date datetime not null,
time time not null,
payment varchar(15) not null,
cogs decimal(10,2) not null,
gross_margin_pct float(11,9),
gross_income decimal (12,4),
rating float(2,1)
);

Select * from sales;
-- FeatureEngineering
-- Time_of_day
Select time,
(Case
when time between '00:00:00' and '11:59:59' then "Morning"
when time between '12:00:00' and '15:59:59' then "Afternoon"
else "Evening"
end) as time_of_day
from sales;
Alter table sales add column time_of_day varchar(20);
Update sales
set time_of_day = (
Case
when time between "00:00:00" and "11:59:59" then "Morning"
when time between "12:00:00" and "15:59:59" then "Afternoon"
else "Evening"
end);
Select * from sales;
-- Day_name
Select date,
dayname(date) as day_name
from sales;
Alter table sales add day_name varchar(10);
Update sales
set day_name = dayname(date);
-- Month_name
Select date,
monthname(date) as month_name
from sales;
Alter table sales add month_name varchar(10);
Update sales
set month_name = monthname(date);

-- EDA
-- Generic Questions
-- How many distinct cities are present in the dataset?
Select distinct city
from sales;
Select count(distinct city) from sales;
-- In which city is each branch situated?
Select distinct branch_id, city from sales;
-- Product
-- How many distinct product lines are there in the dataset?
Select DISTINCT product_line from sales;
Select count(distinct product_line) from sales;
-- What is the most common payment method?
With cte as (Select payment, rank() over (order by count(payment) desc) as drank
from sales
group by payment
order by 2)
Select payment
from cte 
where drank = 1 ;
select payment
from sales
group by payment
order by count(*) desc
limit 1;
-- What is the most selling product line?
Select product_line, count(product_line)
from sales
group by product_line
order by 2 desc
limit 1;
-- What is the total revenue by month?
Select distinct month_name, sum(total) over(partition by month_name)
from sales
order by 2 desc;
select month_name, sum(total) as total_revenue
from sales
group by month_name
order by 2 desc;
-- Which month recorded the highest cost of goods sold?
Select month_name, sum(cogs) as total_cogs
from sales
group by month_name
order by 2 desc
limit 1;
-- Which product_line generated highest revenue?
Select product_line, round(sum(total),2) as total_revenue
from sales
group by product_line
order by 2 desc
limit 1;
-- Which city has highest revenue?
Select city,Ceil(sum(total)) as total_revenue
from sales
group by 1
order by 2 desc
limit 1;
-- Which product_line has incurred highest vat?
Select product_line, round(sum(vat),2) as total_vat
from sales
group by 1
order by 2 desc
limit 1;
-- Retrieve each product_line and add a column product_category, indicating whether "Good" or "Bad", based on whether its sales over average
Select product_line ,
 (case when total >= (Select avg(total) as new
 from sales) then "Good"
 else "Bad" end) as product_category
 from sales;
 Alter table sales add column product_category varchar(20);
 Update sales s
 Join(
 Select avg(total) as avg_total
 from sales) a
 set s.product_category = 
 Case
 when s.total >= a.avg_total then 'Good'
 else 'Bad' end; 
 -- Which branch sold products more than average product sold?
Select avg(quantity)
from sales;
Select branch_id, sum(quantity) as total_quantity
from sales
group by branch_id
having sum(quantity) > avg(quantity)
order by 2 desc 
limit 1;
-- What is most common product by gender?
With cte as (Select gender, product_line, count(gender), rank() over(partition by gender order by count(gender) desc) as drank
from sales
group by gender, product_line)
Select gender, product_line
from cte
where drank = 1; 
-- What is the average rating of each product line?
 Select product_line, round(avg(rating),2) as avg_rating
 from sales
 group by product_line
 Order by 2 desc;
 
 -- Sales analysis 
 -- Number of sales made in each time of the day per weekday
Select day_name, time_of_day, count(invoice_id) as sales_count
from sales
group by day_name, time_of_day
having day_name not in ('Sunday','Saturday'); 
-- Identify the customer type that generates the highest revenue
Select customer_type, floor(sum(total)) as total_revenue
from sales
group by customer_type
order by 2 desc
limit 1;
-- Which city has the largest tax percent/vat?
Select city, sum(vat) as total_vat
from sales
group by city
order by 2 desc
limit 1;
-- Which customer pays most in vat?
SELECT customer_type, sum(vat) as total_vat
from sales
group by customer_type
order by 2 desc
limit 1;
-- Customer analysis
-- How many unique customer types does the data have?
SELECT count(distinct customer_type) as Unique_customers
from sales;
Select distinct customer_type from sales;
-- How many unique payment methods does the data have
Select count(distinct payment) as payment_methods from sales;
Select distinct payment from sales;
-- What is the most commom customer type?
Select customer_type, count(*) as total_customers
from sales
group by 1
order by 2 desc limit 1;
-- Which customer type buys the most?
-- Quantity wise
Select customer_type, sum(quantity) as total_quantity
from sales
group by 1
order by 2 desc limit 1;
-- revenue wise
select customer_type, sum(total) as total_revenue
from sales
group by 1
order by 2 desc limit 1;
-- What is the gender of most of the customers?
Select gender, count(*) as total_count
from sales
group by 1 
order by 2 desc;
-- Customer wise gender distribution
Select distinct customer_type, gender, count(gender) over (partition by customer_type, gender) as distribution
from sales;
-- What is the gender distribution per branch?
Select distinct branch_id, gender, count(gender) over (partition by branch_id, gender) as distribution
from sales;
-- which time of the day do customers give most ratings
Select time_of_day, avg(rating) as rating_avg
from sales
group by 1
order by 2 desc
limit 1;
-- which time of the day do customers give most ratings per branch?
Select branch_id, time_of_day, avg(rating) as most_rating
from sales
group by branch_id, time_of_day 
order by 3 desc;
Select distinct branch_id, time_of_day, avg(rating) over (PARTITION BY branch_id,time_of_day ) as most_rating
from sales;
-- Which day of the week has best ratings?
Select day_name, avg(rating) as average_rating
from sales
group by 1
order by 2 desc
limit 1;
-- Which day of the week has best average ratings per branch?
Select branch_id, day_name, avg(rating) as rating_average
from sales
group by 1,2
order by 3 desc 
limit 1;
Select branch_id, day_name, avg(rating) over(partition by branch_id, day_name) as avg_rating
from sales
order by 3 desc
limit 1;
