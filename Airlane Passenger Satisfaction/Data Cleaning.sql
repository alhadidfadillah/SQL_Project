-- Step 2: Cleaning the data
-- These are some steps you can do when you clean your data --
-- 1. Check duplicates and remove it.
-- 2. Standardize data, for example fix inconsistencies, fix outliers, fix data type.
-- 3. Look at null values.
-- 4. Remove irrelevant data (if any).

-- Take a quick look at the table
SELECT *
FROM passenger_satisfaction;

-- First thing we can do before cleaning data is make an alternative table.
-- In case of something happens if we use our raw data.
CREATE TABLE passenger_satisfaction2
LIKE passenger_satisfaction;

-- Don't forget to insert the value from each column for alternative table.
INSERT passenger_satisfaction2
SELECT *
FROM passenger_satisfaction;

-- Check whether the alternative table already exist or not.
SELECT *
FROM passenger_satisfaction2;

-- 1. Check duplicates and remove it.
-- Check duplicates by ROW_NUMBER() -> It will return the unique number for each row. If the row number > 1, there is duplicate row.
WITH `Duplicate Rows` AS (
SELECT *, ROW_NUMBER() OVER(PARTITION BY ID, Gender, Age, `Customer Type`, `Type of Travel`, Class, `Flight Distance`, `Departure Delay`,
							`Arrival Delay`, `Departure and Arrival Time Convenience`, `Ease of Online Booking`, `Check-In Service`,
                            `Online Boarding`, `Gate Location`, `On-board Service`, `Seat Comfort`, `Leg Room Service`, Cleanliness,
                            `Food and Drink`, `In-flight Service`, `In-flight Wifi Service`, `In-flight Entertainment`, `Baggage Handling`,
                            Satisfaction) AS `Row Number`
FROM passenger_satisfaction2)
SELECT *
FROM `Duplicate Rows`
WHERE `Row Number` > 1;
-- There is no duplicate row

-- 2. Standardize data
-- Check the useless space (leading and trailing space) for all string column.
SELECT *
FROM passenger_satisfaction2
WHERE Gender LIKE '% ' OR ' %'
   OR `Customer Type` LIKE '% ' OR ' %'
   OR `Type of Travel` LIKE '% ' OR ' %'
   OR Class LIKE '% ' OR ' %'
   OR Satisfaction LIKE '% ' OR ' %';
-- There is no useless space.

-- 3. Look at null values.
SELECT *
FROM passenger_satisfaction2
WHERE ID IS NULL
   OR Gender IS NULL
   OR Age IS NULL
   OR `Customer Type` IS NULL
   OR `Type of Travel` IS NULL
   OR Class IS NULL
   OR `Flight Distance` IS NULL
   OR `Departure Delay` IS NULL
   OR `Arrival Delay` IS NULL
   OR `Departure and Arrival Time Convenience` IS NULL
   OR `Ease of Online Booking` IS NULL
   OR `Check-In Service` IS NULL
   OR `Online Boarding` IS NULL
   OR `Gate Location` IS NULL
   OR `On-board Service` IS NULL
   OR `Seat Comfort` IS NULL
   OR `Leg Room Service` IS NULL
   OR Cleanliness IS NULL
   OR `Food and Drink` IS NULL
   OR `In-flight Service` IS NULL
   OR `In-flight Wifi Service` IS NULL
   OR `In-flight Entertainment` IS NULL
   OR `Baggage Handling` IS NULL
   OR Satisfaction IS NULL
   ;
-- There is no missing value.