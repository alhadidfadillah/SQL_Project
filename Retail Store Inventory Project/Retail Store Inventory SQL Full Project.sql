-- Retail Store Inventory Project --

-- Step 1: Understanding the problem we want to tackle.
-- Here some problem or objective we need to solve
-- 1. Which products have low inventory levels compared to their demand forecast?
-- 2. Which products are frequently over-ordered compared to actual sales?
-- 3. Which products/categories sell the most and which the least?
-- 4. Do discounts increase sales?
-- 5. Are we pricing higher or lower than competitors?
-- 6. Which region has the highest sales?
-- 7. Which seasons drive the most sales for different categories?
-- 8. Does weather influence sales?
-- 9. How close are the demand forecasts to actual sales?
-- 10. Did stock-outs cause missed sales?

-- Step 2: Cleaning the data
-- These are some steps you can do when you clean your data --
-- 1. Check duplicates and remove it.
-- 2. Standardize data, for example fix inconsistencies, fix outliers, fix data type.
-- 3. Look at null values.
-- 4. Remove irrelevant data (if any).

-- Take a quick look at the table.
SELECT *
FROM store_inventory;

-- First thing we can do before cleaning data is make an alternative table.
-- In case of something happens if we use our raw data.

CREATE TABLE retail.store_inventory2
LIKE retail.store_inventory;

-- Don't forget to insert the value from each column for alternative table.
INSERT store_inventory2
SELECT *
FROM store_inventory;

-- Check whether the alternative table already exist or not.
SELECT *
FROM store_inventory2;

-- 1. Check duplicates and remove it.
-- Check duplicates by ROW_NUMBER() -> It will return the unique number for each row. If the row number > 1, there is duplicate row.

WITH duplicates_row AS (
SELECT *,
ROW_NUMBER() OVER(PARTITION BY `Date`, `Store ID`, `Product ID`, Category, Region, `Inventory Level`, `Units Sold`,
`Units Ordered`, `Demand Forecast`, Price, Discount, `Weather Condition`, `Holiday/Promotion`, `Competitor Pricing`, Seasonality) AS row_num
FROM store_inventory2)
SELECT *
FROM duplicates_row
WHERE row_num > 1;
-- There are no duplicate rows.

SELECT DISTINCT `Date`,
STR_TO_DATE(`Date`, '%Y-%m-%d') AS `date`
FROM store_inventory2;

-- 2. Standardize data
-- First, we see that the Date columm data type is text, we need to change it to Date data type.

UPDATE store_inventory2
SET `Date` = STR_TO_DATE(`Date`, '%Y-%m-%d');

ALTER TABLE store_inventory2
MODIFY COLUMN `Date` DATE;
-- We finish change Date data type.

-- Next, check the useless space (leading and trailing space) for all string column.
SELECT `Store ID`, `Product ID`, Category, 
Region, `Weather Condition`, Seasonality
FROM store_inventory2
WHERE `Store ID` LIKE ' %'
   OR `Store ID` LIKE '% '
   OR `Product ID` LIKE ' %'
   OR `Product ID` LIKE '% '
   OR Category LIKE ' %'
   OR Category LIKE '% '
   OR Region LIKE ' %'
   OR Region LIKE '% '
   OR `Weather Condition` LIKE ' %'
   OR `Weather Condition` LIKE '% '
   OR Seasonality LIKE ' %'
   OR Seasonality LIKE '% '
;
-- There is no useless space.

SELECT *
FROM store_inventory2;

-- 3. Look at null values.
SELECT *
FROM store_inventory2
WHERE `Store ID` IS NULL OR `Store ID` = ''
   OR `Product ID` IS NULL OR `Product ID` = ''
   OR Category IS NULL OR Category = ''
   OR Region IS NULL OR Region = ''
   OR `Inventory Level` IS NULL OR `Inventory Level` = ''
   OR `Units Sold` IS NULL
   OR `Units Ordered` IS NULL OR `Units Ordered` = ''
   OR `Demand Forecast` IS NULL OR `Demand Forecast` = ''
   OR Price IS NULL OR Price = ''
   OR Discount IS NULL
   OR `Weather Condition` IS NULL OR `Weather Condition` = ''
   OR `Holiday/Promotion` IS NULL
   OR `Competitor Pricing` IS NULL OR `Competitor Pricing` = ''
   OR Seasonality IS NULL OR Seasonality = '';
-- There is no missing values.

-- Step 3: Analyze the data and solve the problem.
-- Here some problem or objective we need to solve.

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
