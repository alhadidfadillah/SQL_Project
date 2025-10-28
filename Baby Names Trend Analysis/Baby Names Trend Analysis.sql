-- Baby Names Trend Analysis --

-- Objective 1: Track Changes in Popularity --
-- 1. Find the overall most popular girl name and most popular boy name. Show how they have changed in popularity rankings over the years.
SELECT Name, SUM(Births) AS `Total Name`
FROM names
WHERE Gender = "F"
GROUP BY Name
ORDER BY 2 DESC
LIMIT 1;
-- The most popular girl name is Jessica with 863.121 in total.

SELECT Name, SUM(Births) AS `Total Name`
FROM names
WHERE Gender = "M"
GROUP BY Name
ORDER BY 2 DESC
LIMIT 1;
-- The most popular girl name is Michael with 1.376.418 in total.

SELECT *
FROM
(WITH `Number of Babies` AS (
SELECT Year, Name, SUM(Births) AS `Total Name`
FROM names
WHERE Gender = "F"
GROUP BY Year, Name)

SELECT Year, Name,
	   ROW_NUMBER() OVER(PARTITION BY Year ORDER BY `Total Name` DESC) AS `Rank`
FROM `Number of Babies`) AS `Popularity Rank`
WHERE Name = "Jessica";
-- This is how baby's name Jessica has changed in popularity rankings over the years.

SELECT *
FROM
(WITH `Number of Babies` AS (
SELECT Year, Name, SUM(Births) AS `Total Name`
FROM names
WHERE Gender = "M"
GROUP BY Year, Name)

SELECT Year, Name,
	   ROW_NUMBER() OVER(PARTITION BY Year ORDER BY `Total Name` DESC) AS `Rank`
FROM `Number of Babies`) AS `Popularity Rank`
WHERE Name = "Michael";
-- This is how baby's name Michael has changed in popularity rankings over the years.


-- 2. Find the names with the biggest jumps in popularity from the first year of the data set to the last year of the data set.
WITH 1980_name AS (

	WITH `Number Baby's Name` AS (
	SELECT Year, Name, SUM(Births) AS `Total Name`
	FROM names
    WHERE Year = "1980"
	GROUP BY Year, Name)

	SELECT Year, Name,
		   ROW_NUMBER() OVER(PARTITION BY Year ORDER BY `Total Name` DESC) AS `Rank`
	FROM `Number Baby's Name`),

2009_name AS (

	WITH `Number Baby's Name` AS (
	SELECT Year, Name, SUM(Births) AS `Total Name`
	FROM names
    WHERE Year = "2009"
	GROUP BY Year, Name)

	SELECT Year, Name,
		   ROW_NUMBER() OVER(PARTITION BY Year ORDER BY `Total Name` DESC) AS `Rank`
	FROM `Number Baby's Name`)
    
SELECT t1.Year, t1.Name, t1.Rank, t2.Year, t2.Name, t2.Rank,
	   CAST(t2.Rank AS SIGNED) - CAST(t1.Rank AS SIGNED) AS Differences
FROM 1980_name AS t1
INNER JOIN 2009_name AS t2
	ON t1.Name = t2.Name
ORDER BY Differences;
-- Colton has risen a lot of popularity with the biggest jumps in popularity from the first year to the last year of the data set.



-- Objective 2: Compare Popularity Accros Decades --
-- 1. For each year, find the 3 most popular girl names and 3 most popular boy names.
SELECT *
FROM
	(WITH `Number Baby's Name` AS (
	SELECT Year, Name, SUM(Births) AS `Total Name`
	FROM names
	WHERE Gender = "F"
	GROUP BY Year, Name)

	SELECT Year, Name, `Total Name`,
		   ROW_NUMBER() OVER(PARTITION BY Year ORDER BY `Total Name` DESC) AS `Rank`
	FROM `Number Baby's Name`) AS `Popularity Rank`
WHERE `Rank` <= 3; 
-- These lists are the 3 most popular girl names each year.

SELECT *
FROM
	(WITH `Number Baby's Name` AS (
	SELECT Year, Name, SUM(Births) AS `Total Name`
	FROM names
	WHERE Gender = "M"
	GROUP BY Year, Name)

	SELECT Year, Name, `Total Name`, 
		   ROW_NUMBER() OVER(PARTITION BY Year ORDER BY `Total Name` DESC) AS `Rank`
	FROM `Number Baby's Name`) AS `Popularity Rank`
WHERE `Rank` <= 3;
-- These lists are the 3 most popular boy names each year.


-- 2. For each decade, find the 3 most popular girl names and 3 most popular boy names.
SELECT *
FROM
	(WITH `Number Baby's Name` AS (
		SELECT (CASE WHEN Year BETWEEN 1980 AND 1989 THEN "1980s"
					 WHEN Year BETWEEN 1990 AND 1999 THEN "1990s"
					 WHEN Year BETWEEN 2000 AND 2009 THEN "2000s"
					 ELSE "None" END) AS Decade, Name, SUM(Births) AS `Total Name`
	FROM names
	WHERE Gender = "F"
	GROUP BY Decade, Name)

	SELECT Decade, Name, `Total Name`,
		   ROW_NUMBER() OVER(PARTITION BY Decade ORDER BY `Total Name` DESC) AS `Rank`
	FROM `Number Baby's Name`) AS `Popularity Rank`
WHERE `Rank` <= 3;
-- These lists are the 3 most popular girl names each decade.

SELECT *
FROM
	(WITH `Number Baby's Name` AS (
		SELECT (CASE WHEN Year BETWEEN 1980 AND 1989 THEN "1980s"
					 WHEN Year BETWEEN 1990 AND 1999 THEN "1990s"
					 WHEN Year BETWEEN 2000 AND 2009 THEN "2000s"
					 ELSE "None" END) AS Decade, Name, SUM(Births) AS `Total Name`
	FROM names
	WHERE Gender = "M"
	GROUP BY Decade, Name)

	SELECT Decade, Name, `Total Name`,
		   ROW_NUMBER() OVER(PARTITION BY Decade ORDER BY `Total Name` DESC) AS `Rank`
	FROM `Number Baby's Name`) AS `Popularity Rank`
WHERE `Rank` <= 3;
-- These lists are the 3 most popular boy names each decade.



-- Objective 3: Compare Popularity Accros Regions --
-- 1. Find the number of babies born in each of the six regions.
SELECT r.Region, SUM(n.Births) AS `Number of Babies`
FROM regions AS r
LEFT JOIN names AS n
	ON r.State = n.State
GROUP BY r.Region;
-- There are same region but with different text (New England). We need to fix that.

SELECT DISTINCT n.State, r.Region
FROM names AS n
LEFT JOIN regions AS r
	ON n.State = r.State;
-- There is also null value in region of MI state. We also need to fix that.

-- So, we would like make another region table after fixed with CTE.
WITH `Clean Regions` AS (
SELECT State,
	   CASE WHEN Region = "New England" THEN "New_England" ELSE Region END AS Clean_Region
FROM regions
UNION
SELECT "MI" AS State, "Midwest" AS Region)

SELECT cr.Clean_Region, SUM(n.Births) AS `Number of Babies`
FROM `Clean Regions` AS cr
LEFT JOIN names AS n
	ON cr.State = n.State
GROUP BY cr.Clean_Region;
-- This is the number of babies born in each of the six regions.


-- 2. Find the 3 most popular girl names and 3 most popular boy names within each region.
SELECT *
FROM (
WITH `Number of Babies by Region` AS (
	WITH `Clean Regions` AS (
	SELECT State,
		   CASE WHEN Region = "New England" THEN "New_England" ELSE Region END AS Clean_Region
	FROM regions
	UNION
	SELECT "MI" AS State, "Midwest" AS Region)

	SELECT cr.Clean_Region, n.Name, SUM(n.Births) AS `Number of Babies`
	FROM `Clean Regions` AS cr
	LEFT JOIN names AS n	
		ON cr.State = n.State
	WHERE n.Gender = "F"
	GROUP BY cr.Clean_Region, n.Name)

SELECT Clean_Region, Name, `Number of Babies`,
	   ROW_NUMBER() OVER(PARTITION BY Clean_Region ORDER BY `Number of Babies` DESC) AS `Rank`
FROM `Number of Babies by Region`) AS Popularity
WHERE `Rank` <= 3;
-- This is the 3 most popular girl names within each region.

SELECT *
FROM (
WITH `Number of Babies by Region` AS (
	WITH `Clean Regions` AS (
	SELECT State,
		   CASE WHEN Region = "New England" THEN "New_England" ELSE Region END AS Clean_Region
	FROM regions
	UNION
	SELECT "MI" AS State, "Midwest" AS Region)

	SELECT cr.Clean_Region, n.Name, SUM(n.Births) AS `Number of Babies`
	FROM `Clean Regions` AS cr
	LEFT JOIN names AS n	
		ON cr.State = n.State
	WHERE n.Gender = "M"
	GROUP BY cr.Clean_Region, n.Name)

SELECT Clean_Region, Name, `Number of Babies`,
	   ROW_NUMBER() OVER(PARTITION BY Clean_Region ORDER BY `Number of Babies` DESC) AS `Rank`
FROM `Number of Babies by Region`) AS Popularity
WHERE `Rank` <= 3;
-- This is the 3 most popular boy names within each region.



-- Objective 4: Explore Unique Names --
-- 1. Find the 10 most popular androgynus names (names given to both females and males).
SELECT Name, COUNT(DISTINCT Gender) AS Number_of_Gender, SUM(Births) AS `Number of Androgynus Names`
FROM names
GROUP BY Name
HAVING Number_of_Gender > 1
ORDER BY 3 DESC
LIMIT 10;

-- 2. Find the length of the shortest and longest names, and identify the most popular short names and long names.
SELECT Name, LENGTH(Name) AS `Name Length`
FROM names
ORDER BY 2;
-- The shortest name consists of 2 words.

SELECT Name, LENGTH(Name) AS `Name Length`
FROM names
ORDER BY 2 DESC;
-- The Longest name consists of 15 words.

WITH The_Shortest AS (
SELECT Name, SUM(Births) AS Num_Babies
FROM names
WHERE LENGTH(Name) = 2
GROUP BY Name
ORDER BY 2 DESC
LIMIT 1),

The_Longest AS (
SELECT Name, SUM(Births) AS Num_Babies
FROM names
WHERE LENGTH(Name) = 15
GROUP BY Name
ORDER BY 2 DESC
LIMIT 1)

SELECT Name, Num_Babies
FROM The_Shortest
UNION
SELECT Name, Num_Babies
FROM The_Longest;
-- The most popular Short names is Ty with 29.205 in total and the most popular long names is Fransiscojavier with 52 in total.

-- 3. Find the state with the highest percent of babies named "Chris".
SELECT State, Num_Chris / Num_All * 100 AS Percentage
FROM
(WITH Chris_Name AS (
SELECT State, SUM(Births) AS Num_Chris
FROM names
WHERE Name = "Chris"
GROUP BY State),

All_Name AS (
SELECT State, SUM(Births) AS Num_All
FROM names
GROUP BY State)

SELECT cn.State, cn.Num_Chris, an.Num_All
FROM Chris_Name AS cn
INNER JOIN All_Name AS an
	ON cn.State = an.State) AS Chris_State
ORDER BY Percentage;
-- The state with the highest percent of babies named "Chris" is LA with 0.0335%.