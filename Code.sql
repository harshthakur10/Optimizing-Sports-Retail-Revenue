CREATE DATABASE sports_retail_revenue;
USE sports_retail_revenue;

select * from products;
select * from finance;
select * from info;
select * from reviews;
select * from traffic;

-- Count the total number of products, along with the number of  
-- non-missing values in description, listing_price, and last_visited
select count(p.product_id) as total_rows, 
count(i.description) as count_description,
count(f.listing_price) as listing_price_count,
count(t.last_visited) as count_last_visited
from products as p left join info as i
on p.product_id=i.product_id
left join finance as f
on i.product_id=f.product_id
left join traffic as t
on f.product_id=t.product_id;

-- Find out how listing_price varies between Adidas and Nike products.
select 
p.brand as brands,
count(f.product_id) as Count,
round(avg(f.listing_price),2) as Average_Listing_Price,
max(f.listing_price) as Maximum_Listing_Price,
min(f.listing_price) as Minimum_Listing_Price,
round(stddev(f.listing_price),2) as StDeV_Listing_Price 
from products as p
join finance as f
on p.product_id=f.product_id
where listing_price > 0
group by brands;

-- Create labels for products grouped by price range and brand.
select p.brand, count(f.listing_price) as count,
round(sum(f.revenue),2) as total_revenue,
case when f.listing_price < 42 then'Budget'
    when f.listing_price >= 42 and f.listing_price < 74 
    then 'Average'
    when f.listing_price >= 74 and f.listing_price < 129 
    then 'Expensive'
    else 'Elite' end as price_category
from finance as f join products as p
on f.product_id = p.product_id
where p.brand is not null group by p.brand, price_category
order by total_revenue desc;

-- Calculate the average discount offered by brand.
select p.brand,round(avg(f.discount),2)*100 as Average_Discount
from products as p
join finance as f
on p.product_id=f.product_id
group by p.brand;

-- Calculate the correlation between reviews and revenue.
select
    round(sum((reviews - (select avg(reviews) from reviews)) * 
        (revenue - (select avg(revenue) from finance))) / 
    sqrt(
        sum(power(reviews - (select avg(reviews) from reviews), 2)) * 
        sum(power(revenue - (select avg(revenue) from finance), 2))),2) 
        as Correlation_Coefficient
from finance as f
join reviews as r
on f.product_id=r.product_id;

-- Count the number of reviews per brand per month.
select p.brand, month(t.last_visited) as month,
count(r.reviews) as review_count 
from products as p
join reviews as r
on p.product_id=r.product_id
join traffic as t
on r.product_id=t.product_id
where last_visited is not null and brand is not null
group by p.brand,month
order by month,review_count desc;

-- Create the footwear CTE, then calculate the number of products and average revenue from these items.
with footwear as(
	select *
	from info
	where description like '%shoe%'
)
select count(*)as ProductCount,
round(avg(revenue),2)as AvgRevenue
from footwear fw
join finance f 
on fw.product_id = f.product_id;

-- What is the total revenue generated per brand over the years?
select p.brand,year(t.last_visited)
as year,sum(f.revenue)as total_revenue 
from products as p join traffic as t 
on p.product_id=t.product_id
join finance as f 
on t.product_id=f.product_id
where t.last_visited is not null 
group by p.brand,year
order by year,total_revenue desc;


-- Which products have the highest average rating, and how does this correlate with their revenue?
select p.product_id, p.brand,round(avg(r.rating),2)
as average_rating from products as p
join reviews as r on p.product_id=r.product_id
group by p.product_id,p.brand 
order by average_rating desc limit 10;

-- What is the impact of discounts on sales volume and revenue?
select discount,count(product_id)as sale_count,
sum(revenue) as total_revenue
from finance 
where discount<>0
group by discount
order by sale_count desc;

-- Which brand is the most visited?
select p.brand,count(t.last_visited)
as visit_counts
from products as p
join traffic as t
on p.product_id=t.product_id
group by p.brand;