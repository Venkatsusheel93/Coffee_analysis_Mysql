use coffee_shop;
select * from coffee_data;
describe coffee_data;
/*--Convert the transaction_date dtype from text into date--*/

Update coffee_data 
set transaction_date  = str_to_date(transaction_date, '%d-%m-%Y');

Alter table coffee_data 
MODIFY column transaction_date date;
DEScribe coffee_data;

/*--Convert the transaction_time dtype from text into date--*/

Update coffee_data
SET transaction_time = str_to_date(transaction_time, '%H:%i:%s');
Alter table coffee_data
Modify column transaction_time time;


Describe coffee_data;


Alter table coffee_data
rename column ï»¿transaction_id to transaction_id;

DEscribe coffee_data;

select * from coffee_data;

/* total sales */
SELECT round(sum(unit_price * transaction_qty)) as total_sales
from coffee_data
where month(transaction_date) = 5; -- month(may)


-- Month_on_month sales(mom)
SELECT month(transaction_date) as month,
round(sum(unit_price * transaction_qty)) as total_sales,
(sum(unit_price * transaction_qty) - lag(sum(unit_price * transaction_qty),1)
over(order by month(transaction_date))) / lag(sum(unit_price * transaction_qty),1)
over(order by month(transaction_date)) * 100 as mom_increase_percentage 
from coffee_data
where month(transaction_date) IN (5,6)  -- Current_month = 6(june), Previous_month = 5(may);
group by 1
Order by 1;  


-- Orders
SELECT count(transaction_id) as number_of_orders
from coffee_data
where month(transaction_date) = 6; -- month(June);

-- Month_on_month Orders(mom)
SELECT month(transaction_date) as month,
count(transaction_id) as number_of_orders,
(count(transaction_id) - lag(count(transaction_id),1)
over(order by month(transaction_date))) / lag(count(transaction_id),1)
over(order by month(transaction_date)) * 100 as mom_increase_orders_percentage
from coffee_data
where month(transaction_date) IN (3,4)   -- Current_month = 4(April) & Previous_month = 3(March)
Group by 1
order by 1;

select * from coffee_data;

-- Quantity sold

SELECT sum(transaction_qty) as Total_quantity_Sold
FROM coffee_data
where month(transaction_date) = 6;

-- Month_on_month difference quantity sold (percentage)
SELECT month(transaction_date) as month,
round(sum(transaction_qty)) as total_qunatity_sold,
(sum(transaction_qty) - lag(sum(transaction_qty),1)
over(order by month(transaction_date))) / lag(sum(transaction_qty),1)
over(order by month(transaction_date)) * 100 as mom_quantity_sold_percenatge 
From coffee_data
Where month(transaction_date) IN (2,3)  -- Current_month = 3(March) & Previous_month = 2(feb)
Group by 1
Order by 1;

-- calendar table - daily_sales,ordes and quantity_sold  for - (26 March 2023)
SELECT 
concat(round(count(transaction_id) / 1000,1), "K") as total_number_of_orders,
concat(round(sum(transaction_qty) / 1000,1),"K") as total_quantity_sold,
concat(round(sum(unit_price * transaction_qty) / 1000,1),"K") as total_sales
FROM coffee_data
WHERE transaction_date = '2023-05-18';

-- sales trend over period
with cte1 as (
SELECT transaction_date,sum(unit_price * transaction_qty) as total_sales
from coffee_data
where month(transaction_date) = 5
GROUP BY 1
)
SELect avg(total_sales) as Average_sales from cte1;

-- Daily sales for month selected 
SELECT day(transaction_date) as day,
round(sum(unit_price * transaction_qty),1) as total_sales
from coffee_data
Where month(transaction_date) = 3 -- (March_month)
GROUP BY 1
ORDER BY 1;

-- comparing daily sales with avg_sales -if greater than "Above Average" and lesser than "Below Average"
WITH cte AS (
    SELECT 
        DAY(transaction_date) AS day_of_month,
        ROUND(SUM(unit_price * transaction_qty), 1) AS total_sales,
        AVG(SUM(unit_price * transaction_qty)) OVER () AS Average_sales
    FROM 
        coffee_data
    WHERE 
        MONTH(transaction_date) = 4 -- Filter for April
    GROUP BY 
        DAY(transaction_date)
)
SELECT 
    day_of_month,
    CASE 
        WHEN total_sales > Average_sales THEN 'Above Average'
        WHEN total_sales < Average_sales THEN 'Below Average'
        ELSE 'Average'
    END AS sales_status,
    total_sales 
FROM 
    cte 
ORDER BY 
    day_of_month;
    
-- sales by weekday / weekend
SELECT 
	case when dayofweek(transaction_date) IN (1,7) THEN "Weekends"
    ELSE "Weekdays"
    END as day_type,
	round(sum(unit_price * transaction_qty),1) as total_sales
    FROM coffee_data
    WHERE month(transaction_date) = 5 -- (may_month)
    GROUP BY 1
    ORDER by 1;

-- sales by store location
SELECT store_location, 
sum(unit_price * transaction_qty) as total_sales 
from coffee_data
WHERE month(transaction_date) = 5  -- (may_month)
GROUP BY 1
ORDER BY 2 desc;

-- sales by Product category
SELECT product_category,
round(sum(unit_price * transaction_qty),1) as total_sales
FROM coffee_data
WHERE month(transaction_date) = 5   -- may(month)
GROUP BY 1
ORDER BY 2 desc;


-- sales by product (top10)
select product_type,
round(sum(unit_price * transaction_qty),1) as total_sales
FROM coffee_data
WHERE month(transaction_date) = 3   -- (March_month)
GROUP BY 1
ORDER BY 2 desc 
LIMIT 10;

-- sales by day/ hour
Select round(sum(unit_price * transaction_qty)) as total_sales,
sum(transaction_qty) as total_qty_sold,
count(transaction_id) as total_orders 
from coffee_data
WHERE dayofweek(transaction_date) = 3 and hour(transaction_time) = 8 and month(transaction_date) = 5;

-- to  get sales from monday to sunday for month of may
SELECT 
case 
	when dayofweek(transaction_date) = 2 then "Monday"
	when dayofweek(transaction_date) = 3 then "Tuesday"
	when dayofweek(transaction_date) = 4 then "Wednesday"
	when dayofweek(transaction_date) = 5 then "Thursday"
	when dayofweek(transaction_date) = 6 then "Friday"
	when dayofweek(transaction_date) = 7 then "Saturday"
    ELSE "Sunday"
END as day_of_week,
round(sum(unit_price * transaction_qty)) as total_sales
from coffee_data
where month(transaction_date) = 5
GROUP BY 1;

-- to get sales for all hours for month of may
SELECT hour(transaction_time) as hour_of_day,
round(sum(unit_price * transaction_qty)) as total_sales
from coffee_data
where month(transaction_date) = 5   -- May(month)
GROUP BY 1
Order by 1;
