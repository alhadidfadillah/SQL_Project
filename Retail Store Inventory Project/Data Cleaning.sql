-- Retail Store Inventory Project --

-- Step 2: Cleaning the data
-- These are some steps you can do when you clean your data --
-- 1. Check duplicates and remove it.
-- 2. Standardize data, for example fix inconsistencies, fix outliers, fix data type.
-- 3. Look at null values.
-- 4. Remove irrelevant data (if any).

-- Take a quick look at the table
SELECT *
FROM store_inventory;

-- First thing we can do before cleaning data is make an alternative table.
-- In case of something happens if we use our raw data.

CREATE TABLE retail.store_inventory2
LIKE retail.store_inventory;

-- Don't forget to insert the value from each column for alternative table
INSERT store_inventory2
SELECT *
FROM store_inventory;

-- Check whether the alternative table already exist or not
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
-- There are no duplicate rows

SELECT DISTINCT `Date`,
STR_TO_DATE(`Date`, '%Y-%m-%d') AS `date`
FROM store_inventory2;

-- 2. Standardize data
-- First, we see that the Date columm data type is text, we need to change it to Date data type.

UPDATE store_inventory2
SET `Date` = STR_TO_DATE(`Date`, '%Y-%m-%d');

ALTER TABLE store_inventory2
MODIFY COLUMN `Date` DATE;
-- We finish change Date data type

-- Next, check the useless space (leading and trailing space) for all string column
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
-- There is no useless space

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
-- There is no missing values