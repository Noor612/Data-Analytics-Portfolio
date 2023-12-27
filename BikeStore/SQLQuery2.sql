

select * from production.products;
select * from production.categories;
select * from production.brands;
select * from sales.customers;
select * from sales.orders;
select * from sales.order_items;
select * from sales.staffs;
select * from sales.stores;




select ord.order_id, 
CONCAT(cus.first_name,' ',cus.last_name) as name,
cus.city,
cus.state,
ord.order_date,
SUM(ite.quantity) as total_units,
SUM(ite.quantity * ite.list_price) as revenue,
pro.product_name,
cat.category_name,
br.brand_name,
sto.store_name,
CONCAT(stf.first_name,' ',stf.last_name) as Staff_name

from sales.orders ord
JOIN sales.customers cus
ON ord.customer_id = cus.customer_id
JOIN sales.order_items ite
ON ite.order_id = ord.order_id
JOIN production.products pro
ON pro.product_id = ite.product_id
JOIN production.categories cat
ON cat.category_id = pro.category_id
JOIN production.brands br
ON br.brand_id = pro.brand_id
JOIN sales.stores sto
ON sto.store_id = ord.store_id
JOIN sales.staffs stf
ON stf.staff_id = ord.staff_id

GROUP BY
ord.order_id, 
CONCAT(cus.first_name,' ',cus.last_name),
cus.city,
cus.state,
ord.order_date,
pro.product_name,
cat.category_name,
br.brand_name,
sto.store_name,
CONCAT(stf.first_name,' ',stf.last_name)