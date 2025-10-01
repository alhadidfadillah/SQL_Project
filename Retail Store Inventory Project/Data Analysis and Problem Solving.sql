-- Retail Store Inventory Project --

-- Step 3: Analyze the data and solve the problem
-- Here some problem or objective we need to solve
-- 1. Which products have low inventory levels compared to their demand forecast?
WITH `Low Inventory Level` AS (
SELECT `Product ID`, Category,
(`Demand Forecast` - `Inventory Level`) AS `Inventory Level-Demand Forecast Comparison`
FROM store_inventory2)
SELECT *
FROM `Low Inventory Level`
ORDER BY `Inventory Level-Demand Forecast Comparison` DESC LIMIT 1;
-- The answer is Product ID with value P0012, Clothing Category.

-- 2. Which products are frequently over-ordered compared to actual sales?
WITH `Over-Ordered` AS (
SELECT `Store ID`, `Product ID`, Category,
       SUM(`Units Sold`) AS `Total Sold`,
       SUM(`Units Ordered`) AS `Total Ordered`,
       (SUM(`Units Ordered`) - SUM(`Units Sold`)) AS `Overstock`
FROM store_inventory2
GROUP BY `Store ID`, `Product ID`, Category)
SELECT *
FROM `Over-Ordered`
ORDER BY `Overstock` DESC;
-- The answer is S002 Store ID, P0015 Product ID, Clothing Category.

-- 3. Which products/categories sell the most and which the least?
SELECT *
FROM (
	SELECT `Product ID`, Category,
    SUM(`Units Sold`) AS `Total Sold`
	FROM store_inventory2
    GROUP BY `Product ID`, Category
    ORDER BY `Total Sold` DESC
	LIMIT 1) AS `Most Sold`;
-- The answer P0015 Product ID, Furniture Category for Most Sold.

SELECT *
FROM (
	SELECT `Product ID`, Category,
    SUM(`Units Sold`) AS `Total Sold`
	FROM store_inventory2
    GROUP BY `Product ID`, Category
	ORDER BY `Total Sold` ASC
	LIMIT 1) AS `Least Sold`;
-- The answer is P0018 Product ID, Toys Category.

-- 4. Do discounts increase sales?
SELECT Discount, AVG(`Units Sold`) AS `Average Sales`
FROM store_inventory2
GROUP BY Discount
ORDER BY `Average Sales` DESC;
-- It could be said that discounts increase sales.

-- 5. Are we pricing higher or lower than competitors?
WITH `Pricing Differences` AS (
SELECT ROUND(AVG(Price), 2) AS `Average Pricing`, ROUND(AVG(`Competitor Pricing`), 2) AS `Average Competitor Pricing`
FROM store_inventory2)
SELECT *, ROUND(`Average Pricing` - `Average Competitor Pricing`, 2)
FROM `Pricing Differences`;
-- We are pricing cheaper than competitors, 0.01 lower than competitor pricing in average.

-- 6. Which region has the highest sales?
SELECT Region, SUM(`Units Sold`) AS `Total Sales`
FROM store_inventory2
GROUP BY Region
ORDER BY `Total Sales` DESC;
-- The region that has the highest sales is East Region.

-- 7. Which seasons drive the most sales for different categories?
WITH `Season Most Sales` AS (
SELECT Category, Seasonality, SUM(`Units Sold`) AS `Total Sales`
FROM store_inventory2
GROUP BY  Category, Seasonality)
SELECT *
FROM(SELECT Category, `Total Sales`, Seasonality,
			ROW_NUMBER() OVER(PARTITION BY Category ORDER BY `Total Sales` DESC) AS `Category Sales Rank`
FROM `Season Most Sales`) AS `Sales Rank`
WHERE `Category Sales Rank` = 1
ORDER BY `Total Sales` DESC;
-- Here is the summary of the seasons drive the most sales for different categories:
-- Furniture = Spring
-- Groceries = Autumn
-- Clothing = Winter
-- Toys = Summer
-- Electronics = Autumn

-- 8. Does weather influence sales?
SELECT `Weather Condition`, AVG(`Units Sold`) AS `Average Sales`
FROM store_inventory2
GROUP BY `Weather Condition`
ORDER BY `Total Sales` DESC;
-- Definitely, a sunny day has the most average sales among the others.

-- 9. How close are the demand forecasts to actual sales?
WITH Differences AS (
SELECT ROUND(AVG(`Units Sold`), 2) AS `Average Sales`, ROUND(AVG(`Demand Forecast`), 2) AS `Average Demand Forecast`
FROM store_inventory2)
SELECT *, ROUND(ABS(`Average Sales` - `Average Demand Forecast`), 2)
FROM Differences;
-- The difference is quite close, it has 5.03 differences.

-- 10. Did stock-outs cause missed sales?
SELECT 
    `Product ID`,
    Category,
    SUM(`Units Sold`) AS total_sold,
    SUM(`Inventory Level`) AS total_inventory,
    SUM(`Demand Forecast`) AS total_forecast
FROM store_inventory2
GROUP BY `Product ID`, Category
HAVING SUM(`Units Sold`) = SUM(`Inventory Level`)
   AND SUM(`Units Sold`) < SUM(`Demand Forecast`)
ORDER BY (SUM(`Demand Forecast`) - SUM(`Units Sold`)) DESC;
-- Stock-out sales did not cause missed sales. It didn't show products where sales hit inventory limits but demand was higher.