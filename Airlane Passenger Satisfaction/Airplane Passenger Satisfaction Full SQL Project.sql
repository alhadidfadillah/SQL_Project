-- Airplane Passenger Satisfaction Project --

-- Step 1: Understanding the problem we want to tackle.
-- Here some problem or objective we need to solve
-- 1. What is the average age of satisfied vs dissatisfied passengers?
-- 2. Are returning customers more satisfied than first-time customers?
-- 3. How do delays (departure & arrival) impact satisfaction?
-- 4. Which travel class (Business, Economy, Economy Plus) has the highest satisfaction rate?
-- 5. Does flight distance affect satisfaction (short-haul vs long-haul)?
-- 6. Which service factor (seat comfort, cleanliness, wifi, food, etc.) has the strongest correlation with satisfaction?
-- 7. What is the average rating for in-flight entertainment by satisfied vs dissatisfied customers?
-- 8. Do business travelers report higher satisfaction than personal travelers?
-- 9. Which gender group reports higher satisfaction overall?
-- 10. What are the top 3 pain points (lowest rated services) among dissatisfied passengers?

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

-- Step 3: Analyze the data and solve the problem.
-- We would like to check what values are there for each column.
SELECT DISTINCT Gender
FROM passenger_satisfaction2;
-- There are Male and Female genders.

SELECT DISTINCT `Customer Type`
FROM passenger_satisfaction2;
-- There are First-time and Returning Customer Types.

SELECT DISTINCT `Type of Travel`
FROM passenger_satisfaction2;
-- There are 2 types of travel, Business and Personal Travel.

SELECT DISTINCT Class
FROM passenger_satisfaction2;
-- There are 3 clasess of the airplane, Business, Economy, and Economy Plus.

-- Here some problem or objective we need to solve.
-- 1. What is the average age of satisfied vs dissatisfied passengers?
SELECT Satisfaction, ROUND(AVG(Age), 2) AS `Satisfaction Average Age`
FROM passenger_satisfaction2
GROUP BY Satisfaction;
-- The average age of satisfied passengers is 41.74, while the average age of dissatisfied passengers is 37.65 (it also includes the neutral passengers).

-- 2. Are returning customers more satisfied than first-time customers?
SELECT `Customer Type`, COUNT(Satisfaction)
FROM passenger_satisfaction2
WHERE Satisfaction = 'Satisfied'
GROUP BY `Customer Type`;
-- Yes, the returning customers more satisfied (with total 50574 passengers) than the first-time customer (with total 5688 passengers).

-- 3. How do delays (departure & arrival) impact satisfaction?
WITH `No Delay` AS (
SELECT ROUND((COUNT(Satisfaction = 'Satisfied') * 100) / COUNT(*), 2) AS `No Delay Satisfied Percentage`,
	   ROUND((COUNT(Satisfaction = 'Neutral or Dissatisfied') * 100) / COUNT(*), 2) AS `No Delay Dissatisfied Percentage`
FROM passenger_satisfaction2
WHERE `Departure Delay` = 0 AND `Arrival Delay` = 0)
SELECT *
FROM `No Delay`;

WITH Delay AS (
SELECT ROUND((COUNT(Satisfaction = 'Satisfied') * 100) / COUNT(*), 2) AS `Delay Satisfied Percentage`,
       ROUND((SUM(Satisfaction = 'Neutral or Dissatisfied') * 100) / COUNT(*), 2) AS `Delay Dissatisfied Percentage`
FROM passenger_satisfaction2
WHERE `Departure Delay` > 0 OR `Arrival Delay` > 0)
SELECT *
FROM Delay;
-- Delay does impact satisfaction. The passenger more satisfied if there is no delay with 47.19% percentage, while delay satisfied passenger is 40.29%

SELECT Satisfaction,
       ROUND(AVG(`Departure Delay`), 2) AS `Average Departure Delay`,
       ROUND(AVG(`Arrival Delay`), 2) AS `Average Arrival Delay`
FROM passenger_satisfaction2
GROUP BY Satisfaction;
-- The longer the delay, the more likely passengers are to feel neutral or dissatisfied.

-- 4. Which travel class (Business, Economy, Economy Plus) has the highest satisfaction rate?
SELECT Class, COUNT(Class) AS `Total Passenger`, 
       SUM(CASE WHEN Satisfaction = 'Satisfied' THEN 1 ELSE 0 END) AS `Total Satisfied Passenger`,
       ROUND(SUM(CASE WHEN Satisfaction = 'Satisfied' THEN 1 ELSE 0 END) * 100 / COUNT(*), 2) AS `Satisfied Percentage`
FROM passenger_satisfaction2
GROUP BY Class
ORDER BY 2 DESC;
-- The business class has the highest satisfaction rate.

-- 5. Does flight distance affect satisfaction (short-haul vs long-haul)?
-- First, I'd like to consider short-haul flights as having a distance of less than or equal to 300 miles. Flights of the opposite type would be called long-haul flights.
SELECT
	CASE
		WHEN `Flight Distance` <= 300 THEN 'Short-haul'
		ELSE 'Long-haul' 
	END AS `Flight Distance Group`,
    ROUND(SUM(CASE WHEN Satisfaction = 'Satisfied' THEN 1 ELSE 0 END) * 100 / COUNT(*), 2) AS `Satisfied Passenger Rate`
FROM passenger_satisfaction2
GROUP BY
	CASE
		WHEN `Flight Distance` <= 300 THEN 'Short-haul'
		ELSE 'Long-haul' 
	END;
-- Yes, flight distance does affect satisfaction. Long-haul (44.98%) has more satisfied passenger rate than short-haul (34.64).

-- 6. Which service factor (seat comfort, cleanliness, wifi, food, etc.) has the strongest correlation with satisfaction?
-- This service factor level range from 0 (lowest) to 5 (highest)
SELECT Satisfaction,
       ROUND(AVG(`Departure and Arrival Time Convenience`), 2) AS `Average Departure and Arrival Time Convenience`,
       ROUND(AVG(`Ease of Online Booking`), 2) AS `Average Ease of Online Booking`,
       ROUND(AVG(`Check-In Service`), 2) AS `Average Check-In Service`,
       ROUND(AVG(`Online Boarding`), 2) AS `Average Online Boarding`,
       ROUND(AVG(`Gate Location`), 2) AS `Average Gate Location`,
       ROUND(AVG(`On-board Service`), 2) AS `Average On-board Service`,
       ROUND(AVG(`Seat Comfort`), 2) AS `Average Seat Comfort`,
       ROUND(AVG(`Leg Room Service`), 2) AS `Average Leg Room Service`,
       ROUND(AVG(Cleanliness), 2) AS `Average Cleanliness`,
       ROUND(AVG(`Food and Drink`), 2) AS `Average Food and Drink`,
       ROUND(AVG(`In-flight Service`), 2) AS `Average In-flight Service`,
       ROUND(AVG(`In-flight Wifi Service`), 2) AS `Average In-flight Wifi Service`,
       ROUND(AVG(`In-flight Entertainment`), 2) AS `Average In-flight Entertainment`,
       ROUND(AVG(`Baggage Handling`), 2) AS `Average Baggage Handling`
FROM passenger_satisfaction2
GROUP BY Satisfaction;
-- The service factor with the biggest gap in average rating between satisfied passengers and dissatisfied passengers likely has the strongest correlation with satisfaction.
-- So, Average Online Boarding Service Factor (with a 1.37 gap in average rating) has the strongest correlation with satisfaction.

-- 7. What is the average rating for in-flight entertainment by satisfied vs dissatisfied customers?
SELECT Satisfaction, ROUND(AVG(`In-flight Entertainment`), 2) AS `Average In-flight Entertainment`
FROM passenger_satisfaction2
GROUP BY Satisfaction;
-- The average rating for in-flight entertainment by satisfied passenger is 3.96, while by neutral or dissatisfied passenger is 2.89.

-- 8. Do business travelers report higher satisfaction than personal travelers?
SELECT `Type of Travel`, ROUND(SUM(CASE WHEN Satisfaction = 'Satisfied' THEN 1 ELSE 0 END)*100/COUNT(*), 2) AS `Total Satisfied Passenger`
FROM passenger_satisfaction2
GROUP BY `Type of Travel`;
-- The business traveler (58.37%) reports higher satisfaction than the male (10.13%)

-- 9. Which gender group reports higher satisfaction overall?
SELECT Gender, ROUND(SUM(CASE WHEN Satisfaction = 'Satisfied' THEN 1 ELSE 0 END)*100/COUNT(*), 2) AS `Total Satisfied Passenger`
FROM passenger_satisfaction2
GROUP BY Gender;
-- The male (44.03) reports higher satisfaction than the female (42.89)

-- 10. What are the top 3 pain points (lowest rated services) among dissatisfied passengers?
SELECT Satisfaction,
	   ROUND(AVG(`Departure and Arrival Time Convenience`), 2) AS `Average Departure and Arrival Time Convenience`,
       ROUND(AVG(`Ease of Online Booking`), 2) AS `Average Ease of Online Booking`,
       ROUND(AVG(`Check-In Service`), 2) AS `Average Check-In Service`,
       ROUND(AVG(`Online Boarding`), 2) AS `Average Online Boarding`,
       ROUND(AVG(`Gate Location`), 2) AS `Average Gate Location`,
       ROUND(AVG(`On-board Service`), 2) AS `Average On-board Service`,
       ROUND(AVG(`Seat Comfort`), 2) AS `Average Seat Comfort`,
       ROUND(AVG(`Leg Room Service`), 2) AS `Average Leg Room Service`,
       ROUND(AVG(Cleanliness), 2) AS `Average Cleanliness`,
       ROUND(AVG(`Food and Drink`), 2) AS `Average Food and Drink`,
       ROUND(AVG(`In-flight Service`), 2) AS `Average In-flight Service`,
       ROUND(AVG(`In-flight Wifi Service`), 2) AS `Average In-flight Wifi Service`,
       ROUND(AVG(`In-flight Entertainment`), 2) AS `Average In-flight Entertainment`,
       ROUND(AVG(`Baggage Handling`), 2) AS `Average Baggage Handling`
FROM passenger_satisfaction2
WHERE Satisfaction = 'Neutral or Dissatisfied';
-- The top 3 lowest rated services are In-flight Wifi Service (2.40), Ease of Online Booking (2.55), and Boarding Online (2.66).
-- Improving those services would likely to boost satisfaction.