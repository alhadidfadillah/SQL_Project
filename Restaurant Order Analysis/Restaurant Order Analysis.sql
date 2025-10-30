-- Restaurant Order Analysis --

-- THE OBJECTIVE 1: Explore The Items --
-- 1. Find the number of items on the menu.
SELECT COUNT(item_name) AS `Number of Items`
FROM menu_items;
-- The number of items on the menu is 32.

-- 2. What are the least and most expensive items on the menu?
WITH least AS (
SELECT item_name, price AS `Least Expensive Dish`
FROM menu_items
ORDER BY 2
LIMIT 1),
most AS (
SELECT item_name, price AS `Most Expensive Dish`
FROM menu_items
ORDER BY 2 DESC
LIMIT 1)

SELECT * 
FROM least AS l
JOIN most AS m;
-- The least item is Edamame which costs only 5$ and and most expensive item is Shrimp Scampi which costs 19.95$.

-- 3. How many Italian dishes are on the menu? What are the least and most expensive Italian dishes on the menu?
SELECT item_name, category,
	   ROW_NUMBER() OVER() AS Row_Num
FROM menu_items
WHERE category = "Italian";

WITH least AS (
SELECT item_name, price AS `Least Expensive Italian Dish`
FROM menu_items
WHERE category = "Italian"
ORDER BY 2
LIMIT 1),
most AS (
SELECT item_name, price AS `Most Expensive Italian Dish`
FROM menu_items
WHERE category = "Italian"
ORDER BY 2 DESC
LIMIT 1)

SELECT * 
FROM least AS l
JOIN most AS m;
-- There are 9 Italian dishes on the menu. The least expensive Italian dish is Spaghetti which costs 14.40$,
-- while the most expensive Italian dish is Shrimp Scampi which costs 19.95$.

-- 4. How many dishes are in each category? What is the average dish price within each category?
SELECT category, COUNT(item_name) AS `Number of Dishes`, ROUND(AVG(price),2) AS `Average Price`
FROM menu_items
GROUP BY category;
-- These are the detail of total dishes in each category with its average dish price.

-- THE OBJECTIVE 2: Explore The Orders --
-- 1. What is the date range of the table?
SELECT MIN(order_date) AS `The First Order`, MAX(order_date) AS `The Last Order`
FROM order_details;
-- The first order was on January 1st, 2023. The last order was on March 31st, 2023. The date range of the table is around 3 months.

-- 2. How many orders were made within this date range? How many items were ordered within this date range?
SELECT COUNT(DISTINCT order_id) AS `Number of Orders`, COUNT(order_details_id) AS `Number of Items`
FROM order_details;
-- The orders were made within that date range was 5370 and the items were ordered within that range was 12234.

-- 3. Which order had the most number of items?
SELECT order_id, COUNT(item_id) AS `Number of Items`
FROM order_details
GROUP BY order_id
ORDER BY 2 DESC;
-- This is the order that had the most number of items.

-- 4. How many orders had more than 12 items?
SELECT COUNT(order_id) AS `Number of Orders`
FROM
(SELECT order_id, COUNT(item_id) AS `Number of Items`
FROM order_details
GROUP BY order_id
HAVING `Number of Items` > 12
ORDER BY 2 DESC) AS `Order`;
-- There are 12 orders that had more than 12 items.

-- THE OBJECTIVE 3: Analyze Customer Behaviour --
-- 1. Combine the "menu_items" and "order_details" tables into a single table.
SELECT od.order_details_id, od.order_id, od.order_date, od.order_time, mi.item_name, mi.category, mi.price
FROM order_details AS od
JOIN menu_items AS mi
	ON od.item_id = mi.menu_item_id;

-- 2. What were the least and most ordered items? What categories were they in?
WITH combine_table AS (
SELECT od.order_details_id, od.order_id, od.order_date, od.order_time, mi.item_name, mi.category, mi.price
FROM order_details AS od
JOIN menu_items AS mi
	ON od.item_id = mi.menu_item_id
)

SELECT item_name, category, COUNT(item_name) AS `Total Ordered Item`
FROM combine_table
GROUP BY item_name, category
ORDER BY 3;
-- The least ordered item is Chicken Tacos (Mexican Category) with 123 in total ordered,
-- while the most ordered item is Hamburger (American Category) with 622 in total ordered.

-- 3. What were the top 5 orders that spent the most money?
WITH combine_table AS (
SELECT od.order_details_id, od.order_id, od.order_date, od.order_time, mi.item_name, mi.category, mi.price
FROM order_details AS od
JOIN menu_items AS mi
	ON od.item_id = mi.menu_item_id
)

SELECT order_id, SUM(price) AS `Total Cost`
FROM combine_table
GROUP BY order_id
ORDER BY 2 DESC
LIMIT 5;
-- This is the top 5 orders that spent the most money. 

-- 4. View the details of the highest spend order. Which specific items were purchased?
-- We know that the highest spend order was order_id with number 440.
WITH combine_table AS (
SELECT od.order_details_id, od.order_id, od.order_date, od.order_time, mi.item_name, mi.category, mi.price
FROM order_details AS od
JOIN menu_items AS mi
	ON od.item_id = mi.menu_item_id
)

SELECT order_id, item_name, category, price
FROM combine_table
WHERE order_id = "440";
-- These are the specific items were purchased of the highest spend orders.

-- 5. View the details of the top 5 highest spend orders
-- We know that the top 5 highest spend orders were order_id with number 440, 2075, 1957, 330, 2675.
WITH combine_table AS (
SELECT od.order_details_id, od.order_id, od.order_date, od.order_time, mi.item_name, mi.category, mi.price
FROM order_details AS od
JOIN menu_items AS mi
	ON od.item_id = mi.menu_item_id
)

SELECT order_id, item_name, category, price
FROM combine_table
WHERE order_id IN("440", "2075", "1957", "330", "2675");
-- These are the details of the top 5 highest spend orders.