-- a. The total number of orders placed during the month of March 2022.

-- using count distinct in case of duplication, potentially resource intensive 
select 
  count(distinct id) 
from orders
where created_at between '2022-03-01' and '2022-03-31' 
-- assuming created_at is the best indicator of order date/time
;
  
-- b. Product name, description, and category for all products ordered during the month of March 2022.

-- date from orders, join to products through order_products
select distinct
  name,
  description,
  category
from orders o
  join order_products op on o.order_id = op.order_id 
  join products p on op.product_id = p.product_id
where created_at between '2022-03-01' and '2022-03-31'  
;

-- c. The top 10 best-selling products, ranked by highest count of quantity sold.

-- getting amount sold of each product, order desc and limit to 10
select 
  name,
  sum(quantity) as total_sold
from products p
  join order_products op on p.product_id = op.product_id
group by name
order by total_sold desc
limit 10
;

-- d. A list of all products ordered by any user who has purchased more than $500 in merchandise.

-- scenario 1: the business wants to know what products are popular with users who have purchased > $500
-- summary list of products and # of users purchased

-- assuming the paid field is most appropriate for this context 
-- cost or a combination of cost/taxes/shipping could be used

with paid_amt as (
-- getting the total paid amount from the orders table
select 
  user_id,
  sum(paid) as purch_amt
from orders
group by user_id
)
-- pulling product name and # users ordered from subset of > $500 users
select 
  name,
  count(distinct user_id) as users_purchased
from products
where user_id in (select user_id from paid_amt where purch_amt > 500)
group by name
;
 
-- scenario 2: the business wants to analyze the items purchased by users who spent > $500
-- detail list of users and all the products they ordered
with paid_amt as (
-- getting the total paid amount from the orders table
select 
  user_id,
  sum(paid) as purch_amt
from orders
group by user_id
)
-- pulling user and product info from subset of > $500 users
select 
  display_name,
  name,
  description,
  category
from users u
  join products p on u.id = p.user_id
where user_id in (select user_id from paid_mt where purch_amt > 500)
;

-- e. A list of all email addresses for users who ordered the 'T-shirt' product in the 'Red' variant.

-- users join to variants through product
select distinct
  email,
  name,
  color
from users u 
  join products p on u.id = p.user_id
  join product_variants v on p.id = v.product_id 
-- unsure of formatting so conditioning to lowercase on strings
where lower(name) = 't-shirt'
  -- both color and color_code are strings, including a condition for either field
    and (lower(color) = 'red' or lower(color_code) = 'red')
;