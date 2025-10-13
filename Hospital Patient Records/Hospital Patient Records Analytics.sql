-- Hospital Analytics Project --

-- Step 1: Understanding the problem we want to tackle.
-- Here some problem or objective we need to solve.
-- OBJECTIVE 1: ENCOUNTERS OVERVIEW

-- a. How many total encounters occurred each year?

-- b. For each year, what percentage of all encounters belonged to each encounter class
-- (ambulatory, outpatient, wellness, urgent care, emergency, and inpatient)?

-- c. What percentage of encounters were over 24 hours versus under 24 hours?

-- OBJECTIVE 2: COST & COVERAGE INSIGHTS

-- a. How many encounters had zero payer coverage, and what percentage of total encounters does this represent?

-- b. What are the top 10 most frequent procedures performed and the average base cost for each?

-- c. What are the top 10 procedures with the highest average base cost and the number of times they were performed?

-- d. What is the average total claim cost for encounters, broken down by payer?

-- OBJECTIVE 3: PATIENT BEHAVIOR ANALYSIS

-- a. How many unique patients were admitted each quarter over time?

-- b. How many patients were readmitted within 30 days of a previous encounter?

-- c. Which patients had the most readmissions?

-- Step 2: Cleaning the data
-- These are some steps you can do when you clean your data --
-- 1. Check duplicates and remove it.
-- 2. Standardize data, for example fix inconsistencies, fix outliers, fix data type.
-- 3. Look at null values.
-- 4. Remove irrelevant data (if any).

-- First, take a quick look at all the table
SELECT *
FROM encounters;

SELECT *
FROM patients;

SELECT *
FROM payers;

SELECT *
FROM procedures;

-- First thing we can do before cleaning data is make an alternative table.
-- In case of something happens if we use our raw data.
CREATE TABLE encounters2
LIKE encounters;

CREATE TABLE patients2
LIKE patients;

CREATE TABLE payers2
LIKE payers;

CREATE TABLE procedures2
LIKE procedures;

-- Don't forget to insert the value from each column for alternative table.
INSERT encounters2
SELECT *
FROM encounters;

INSERT patients2
SELECT *
FROM patients;

INSERT payers2
SELECT *
FROM payers;

INSERT procedures2
SELECT *
FROM procedures;

-- Check whether the alternative table already exist or not.
SELECT *
FROM encounters2;

SELECT *
FROM patients2;

SELECT *
FROM payers2;

SELECT *
FROM procedures2;

-- 1. Check duplicates and remove it.
-- Check duplicates by ROW_NUMBER() -> It will return the unique number for each row. If the row number > 1, there is duplicate row.
WITH `Encounter Duplicate Rows` AS (
SELECT *,
ROW_NUMBER() OVER(PARTITION BY Id, `START`, `STOP`, PATIENT, `ORGANIZATION`, PAYER, ENCOUNTERCLASS,
				  `CODE`, `DESCRIPTION`, BASE_ENCOUNTER_COST, TOTAL_CLAIM_COST, PAYER_COVERAGE,
                  REASONCODE, REASONDESCRIPTION) AS `Row Number`
FROM encounters2)
SELECT *
FROM `Encounter Duplicate Rows`
WHERE `Row Number` > 1;
-- There is no duplicate rows in Encounter Table.

WITH `Patients Duplicate Rows` AS (
SELECT *,
ROW_NUMBER() OVER(PARTITION BY Id, BIRTHDATE, DEATHDATE, PREFIX, `FIRST`, `LAST`, SUFFIX,
				  MAIDEN, MARITAL, RACE, ETHNICITY, GENDER, BIRTHPLACE, ADDRESS, CITY, STATE,
                  COUNTY, ZIP, LAT, LON) AS `Row Number`
FROM patients2)
SELECT *
FROM `Patients Duplicate Rows`
WHERE `Row Number` > 1;
-- There is no duplicate rows in Patients Table.

WITH `Payers Duplicate Rows` AS (
SELECT *,
ROW_NUMBER() OVER(PARTITION BY Id, `NAME`, ADDRESS, CITY, STATE_HEADQUARTERED, ZIP, PHONE) AS `Row Number`
FROM payers2)
SELECT *
FROM `Payers Duplicate Rows`
WHERE `Row Number` > 1;
-- There is no duplicate rows in Payers Table.

WITH `Procedures Duplicate Rows` AS (
SELECT *,
ROW_NUMBER() OVER(PARTITION BY `START`, `STOP`, PATIENT, ENCOUNTER, `CODE`, `DESCRIPTION`,
                  BASE_COST, REASONCODE, REASONDESCRIPTION) AS `Row Number`
FROM procedures2)
SELECT *
FROM `Procedures Duplicate Rows`
WHERE `Row Number` > 1;
-- There is no duplicate rows in Procedures Table.

-- 2. Standardize data
-- The values in Marital and Gender Column need to be clarified.
ALTER TABLE patients2
MODIFY COLUMN `MARITAL` VARCHAR(20);

ALTER TABLE patients2
MODIFY COLUMN `GENDER` VARCHAR (20);

UPDATE patients2
SET MARITAL =
	CASE
    WHEN MARITAL = 'M' THEN 'Married'
    WHEN MARITAL = 'S' THEN 'Single'
    ELSE MARITAL
END;

UPDATE patients2
SET GENDER = 
	CASE
    WHEN GENDER = 'F' THEN 'Female'
    WHEN GENDER = 'M' THEN 'Male'
    ELSE GENDER
END;

-- Step 3: Analyze the data and solve the problem.
-- OBJECTIVE 1: ENCOUNTERS OVERVIEW

-- a. How many total encounters occurred each year?
WITH `Total Encounter Each Year` AS (
SELECT
	CASE
		WHEN `START` LIKE '2011%' THEN '2011'
        WHEN `START` LIKE '2012%' THEN '2012'
        WHEN `START` LIKE '2013%' THEN '2013'
        WHEN `START` LIKE '2014%' THEN '2014'
        WHEN `START` LIKE '2015%' THEN '2015'
        WHEN `START` LIKE '2016%' THEN '2016'
        WHEN `START` LIKE '2017%' THEN '2017'
        WHEN `START` LIKE '2018%' THEN '2018'
        WHEN `START` LIKE '2019%' THEN '2019'
        WHEN `START` LIKE '2020%' THEN '2020'
        WHEN `START` LIKE '2021%' THEN '2021'
        ELSE '2022' 
	END AS `Year`,
    COUNT(*) AS `Total Encounters`
FROM encounters2
GROUP BY `Year`)

SELECT *
FROM `Total Encounter Each Year`
ORDER BY `Year`;

-- b. For each year, what percentage of all encounters belonged to each encounter class
-- (ambulatory, outpatient, wellness, urgent care, emergency, and inpatient)?
WITH `Total Encounter Each Year` AS (
SELECT
	CASE
		WHEN `START` LIKE '2011%' THEN '2011'
        WHEN `START` LIKE '2012%' THEN '2012'
        WHEN `START` LIKE '2013%' THEN '2013'
        WHEN `START` LIKE '2014%' THEN '2014'
        WHEN `START` LIKE '2015%' THEN '2015'
        WHEN `START` LIKE '2016%' THEN '2016'
        WHEN `START` LIKE '2017%' THEN '2017'
        WHEN `START` LIKE '2018%' THEN '2018'
        WHEN `START` LIKE '2019%' THEN '2019'
        WHEN `START` LIKE '2020%' THEN '2020'
        WHEN `START` LIKE '2021%' THEN '2021'
        ELSE '2022' 
	END AS `Year`,
    ENCOUNTERCLASS,
    COUNT(*) AS `Total Encounters`
FROM encounters2
GROUP BY `Year`, ENCOUNTERCLASS)

SELECT *,
       ROUND(`Total Encounters` * 100 / SUM(`Total Encounters`) OVER(PARTITION BY `Year`), 2) AS `Total Encounters Percentage`
FROM `Total Encounter Each Year`
ORDER BY `Year`;

-- c. What percentage of encounters were over 24 hours versus under 24 hours?
SELECT ROUND(SUM(CASE WHEN TIMESTAMPDIFF(HOUR, `START`, `STOP`) >= 24 THEN 1 ELSE 0 END) * 100 / COUNT(*), 2) AS `Over 24 Percentage`,
       ROUND(SUM(CASE WHEN TIMESTAMPDIFF(HOUR, `START`, `STOP`) < 24 THEN 1 ELSE 0 END) * 100 / COUNT(*), 2) AS `Under 24 Percentage`
FROM encounters2;

-- OBJECTIVE 2: COST & COVERAGE INSIGHTS

-- a. How many encounters had zero payer coverage, and what percentage of total encounters does this represent?
WITH `Encounters with Zero Payer Coverage` AS (
SELECT SUM(CASE WHEN PAYER_COVERAGE = 0 THEN 1 ELSE 0 END) AS `Total Encounters with Zero Payer Coverage`,
       COUNT(*) AS `Total Encounters`,
       ROUND(SUM(CASE WHEN PAYER_COVERAGE = 0 THEN 1 ELSE 0 END) * 100 / COUNT(*), 2) AS Percentage
FROM encounters2)
SELECT *
FROM `Encounters with Zero Payer Coverage`;

-- b. What are the top 10 most frequent procedures performed and the average base cost for each?
SELECT `DESCRIPTION`, COUNT(`DESCRIPTION`) AS `Total Procedures Performed`,
       ROUND(AVG(BASE_COST), 2) AS Average
FROM procedures2
GROUP BY `DESCRIPTION`
ORDER BY 2 DESC
LIMIT 10;

-- c. What are the top 10 procedures with the highest average base cost and the number of times they were performed?
SELECT `DESCRIPTION`, ROUND(AVG(BASE_COST), 2) AS `Average Base Cost`,
	   COUNT(`DESCRIPTION`) AS `Total Procedures Performed`
FROM procedures2
GROUP BY `DESCRIPTION`
ORDER BY 2 DESC
LIMIT 10;

-- d. What is the average total claim cost for encounters, broken down by payer?
SELECT pay.`NAME`, ROUND(AVG(enc.TOTAL_CLAIM_COST), 2) AS `Average Total Claim Cost`
FROM payers2 AS pay
JOIN encounters2 AS enc
	ON pay.Id = enc.PAYER
GROUP BY pay.`NAME`
ORDER BY 2;

-- OBJECTIVE 3: PATIENT BEHAVIOR ANALYSIS

-- a. How many unique patients were admitted each quarter over time?
SELECT CONCAT(CAST(YEAR(START) AS CHAR), '-', CAST(QUARTER(START) AS CHAR)) AS `Year Quarter`,
	   COUNT(DISTINCT(PATIENT)) AS `Unique Patient`
FROM encounters2
GROUP BY `Year Quarter`;

-- b. How many patients were readmitted within 30 days of a previous encounter?
WITH `Readmitted Patients` AS (
SELECT pat.`FIRST` AS Patients,
       enc.`START`,
       enc.`STOP`,
       LEAD(enc.`START`) OVER(PARTITION BY pat.`FIRST` ORDER BY enc.`START`) AS `Next Admission`
FROM encounters2 AS enc
JOIN patients2 AS pat
	ON enc.PATIENT = pat.Id)
    
SELECT COUNT(DISTINCT Patients)
FROM `Readmitted Patients`
WHERE DATEDIFF(`Next Admission`, `STOP`) < 30;

-- c. Which patients had the most readmissions?
WITH `Readmitted Patients` AS (
SELECT pat.`FIRST` AS Patients,
       enc.`START`,
       enc.`STOP`,
       LEAD(enc.`START`) OVER(PARTITION BY pat.`FIRST` ORDER BY enc.`START`) AS `Next Admission`
FROM encounters2 AS enc
JOIN patients2 AS pat
	ON enc.PATIENT = pat.Id)
    
SELECT Patients,
       COUNT(*) AS `Readmission Count`
FROM `Readmitted Patients`
WHERE DATEDIFF(`Next Admission`, `STOP`) < 30
GROUP BY Patients
ORDER BY `Readmission Count` DESC