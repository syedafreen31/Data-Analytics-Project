select * from df_orders
order by order_date asc;

-- find the top 10 revenue generating products

select product_id from df_orders;

SELECT * 
FROM df_orders 
WHERE product_id LIKE '%MA%';

SELECT TOP 10 product_id, sum(profit) as profit_generated
FROM df_orders
GROUP BY  product_id
ORDER BY profit_generated DESC;

-- find top 5 selling products in each region

Select TOP 5 region,product_id,sum(sale_price) as sale
from df_orders
group by region,product_id
order by sale desc;

with ranked as(
select  region, 
		product_id,
		sum(sale_price) as sale,
		row_number() over(partition by region order by sum(sale_price) desc) as rnk
from df_orders
group by product_id,region
) 
SELECT 
    region,
    product_id,
    sale
FROM ranked
WHERE rnk <= 5;

WITH cte AS (
  SELECT 
    region,
    product_id,
    SUM(sale_price) AS sales
  FROM df_orders
  GROUP BY region, product_id
)
SELECT *
FROM (
  SELECT *,
         ROW_NUMBER() OVER(PARTITION BY region ORDER BY sales DESC) AS rn
  FROM cte
) AS A
WHERE rn <= 5;



--find month over month growth comparison for 2022 and 2023 sales eg : jan 2022 vs jan 2023

with cte as (
select year(order_date) as order_year,month(order_date) as order_month,
sum(sale_price) as sales
from df_orders
group by year(order_date),month(order_date)
--order by year(order_date),month(order_date)
	)
select order_month
, sum(case when order_year=2022 then sales else 0 end) as sales_2022
, sum(case when order_year=2023 then sales else 0 end) as sales_2023
from cte 
group by order_month
order by order_month

--for each category which month had highest sales 
with cte as (
select category,format(order_date,'yyyyMM') as order_year_month
, sum(sale_price) as sales 
from df_orders
group by category,format(order_date,'yyyyMM')
--order by category,format(order_date,'yyyyMM')
)
select * from (
select *,
row_number() over(partition by category order by sales desc) as rn
from cte
) a
where rn=1



--which sub category had highest growth by profit in 2023 compare to 2022
with cte as (
select sub_category,year(order_date) as order_year,
sum(sale_price) as sales
from df_orders
group by sub_category,year(order_date)
--order by year(order_date),month(order_date)
	)
, cte2 as (
select sub_category
, sum(case when order_year=2022 then sales else 0 end) as sales_2022
, sum(case when order_year=2023 then sales else 0 end) as sales_2023
from cte 
group by sub_category
)
select top 1 *
,(sales_2023-sales_2022)as difference
from  cte2
order by (sales_2023-sales_2022) desc
