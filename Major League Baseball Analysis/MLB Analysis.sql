-- MAJOR LEAGUE BASEBALL ANALYSIS --

-- PART I: SCHOOL ANALYSIS
-- 1. View the schools and school details tables
SELECT *
FROM schools;

SELECT *
FROM school_details;

-- 2. In each decade, how many schools were there that produced players?
SELECT
	CASE
		WHEN yearID BETWEEN 1860 AND 1869 THEN "1860s"
        WHEN yearID BETWEEN 1870 AND 1879 THEN "1870s"
        WHEN yearID BETWEEN 1880 AND 1889 THEN "1880s"
        WHEN yearID BETWEEN 1890 AND 1899 THEN "1890s"
        WHEN yearID BETWEEN 1900 AND 1909 THEN "1900s"
        WHEN yearID BETWEEN 1910 AND 1919 THEN "1910s"
        WHEN yearID BETWEEN 1920 AND 1929 THEN "1920s"
        WHEN yearID BETWEEN 1930 AND 1939 THEN "1930s"
        WHEN yearID BETWEEN 1940 AND 1949 THEN "1940s"
        WHEN yearID BETWEEN 1950 AND 1959 THEN "1950s"
        WHEN yearID BETWEEN 1960 AND 1969 THEN "1960s"
        WHEN yearID BETWEEN 1970 AND 1979 THEN "1970s"
        WHEN yearID BETWEEN 1980 AND 1989 THEN "1980s"
        WHEN yearID BETWEEN 1990 AND 1999 THEN "1990s"
        WHEN yearID BETWEEN 2000 AND 2009 THEN "2000s"
        WHEN yearID BETWEEN 2010 AND 2019 THEN "2010s"
    ELSE "ELSE" END AS Decade,
    COUNT(DISTINCT schoolID) AS `Number of School`
FROM schools
GROUP BY Decade;
-- From the 1860s until the 2010s, 3265 schools have produced Major League Baseball players.

-- 3. What are the names of the top 5 schools that produced the most players?
SELECT sd.name_full, COUNT(DISTINCT s.playerID) AS `Total Player`
FROM school_details sd
JOIN schools s
	ON sd.schoolID = s.schoolID
GROUP BY sd.name_full
ORDER BY 2 DESC
LIMIT 5;
-- The University of Texas at Austin, the University of Southern California, and Arizona State University are the 3 schools that produced the most players, with a total of 107, 105, and 101, respectively.

-- 4. For each decade, what were the names of the top 3 schools that produced the most players?
WITH Decades AS (
SELECT
	CASE
		WHEN s.yearID BETWEEN 1860 AND 1869 THEN "1860s"
		WHEN s.yearID BETWEEN 1870 AND 1879 THEN "1870s"
		WHEN s.yearID BETWEEN 1880 AND 1889 THEN "1880s"
		WHEN s.yearID BETWEEN 1890 AND 1899 THEN "1890s"
		WHEN s.yearID BETWEEN 1900 AND 1909 THEN "1900s"
		WHEN s.yearID BETWEEN 1910 AND 1919 THEN "1910s"
		WHEN s.yearID BETWEEN 1920 AND 1929 THEN "1920s"
		WHEN s.yearID BETWEEN 1930 AND 1939 THEN "1930s"
		WHEN s.yearID BETWEEN 1940 AND 1949 THEN "1940s"
		WHEN s.yearID BETWEEN 1950 AND 1959 THEN "1950s"
		WHEN s.yearID BETWEEN 1960 AND 1969 THEN "1960s"
		WHEN s.yearID BETWEEN 1970 AND 1979 THEN "1970s"
		WHEN s.yearID BETWEEN 1980 AND 1989 THEN "1980s"
		WHEN s.yearID BETWEEN 1990 AND 1999 THEN "1990s"
		WHEN s.yearID BETWEEN 2000 AND 2009 THEN "2000s"
		WHEN s.yearID BETWEEN 2010 AND 2019 THEN "2010s"
	ELSE "ELSE" END AS Decade,
	sd.name_full, COUNT(DISTINCT s.playerID) AS num_player
FROM school_details sd
JOIN schools s
	ON sd.schoolID = s.schoolID
GROUP BY Decade, sd.schoolID),
`Rank` AS (
SELECT Decade, name_full, num_player,
	   DENSE_RANK() OVER(PARTITION BY Decade ORDER BY num_player DESC) AS school_rank
FROM Decades)

SELECT Decade, name_full, num_player, school_rank
FROM `Rank`
WHERE school_rank <= 3;


-- PART II: SALARY ANALYSIS
-- 1. View the salaries table
SELECT *
FROM salaries;

-- 2. Return the top 20% of teams in terms of average annual spending
WITH teams AS (
SELECT teamID, yearID, SUM(salary) AS total_spending
FROM salaries
GROUP BY teamID, yearID),

spending AS (
SELECT teamID, AVG(total_spending) AS average_spending,
	   NTILE(5) OVER(ORDER BY AVG(total_spending) DESC) AS top20
FROM teams
GROUP BY teamID)

SELECT teamID, ROUND(average_spending/1000000, 1) AS average_spend_in_million
FROM spending
WHERE top20 = 1;
-- SFG is the highest team with the most average annual spending for salaries, with a total of 143.5 million.

-- 3. For each team, show the cumulative sum of spending over the years
WITH teams AS (
SELECT teamID, yearID, SUM(salary) AS total_spending
FROM salaries
GROUP BY teamID, yearID),

spending AS (
SELECT teamID, yearID,
	   SUM(total_spending) OVER(PARTITION BY teamID ORDER BY yearID) AS cumulative_sum
FROM teams)

SELECT teamID, yearID, ROUND(cumulative_sum/1000000, 1) AS cumulative_sum_in_million
FROM spending;

-- 4. Return the first year that each team's cumulative spending surpassed 1 billion
WITH teams AS (
SELECT teamID, yearID, SUM(salary) AS total_spending
FROM salaries
GROUP BY teamID, yearID),

spending AS (
SELECT teamID, yearID,
	   SUM(total_spending) OVER(PARTITION BY teamID ORDER BY yearID) AS cumulative_sum
FROM teams),

billions AS (
SELECT teamID, yearID, cumulative_sum,
	   ROW_NUMBER() OVER(PARTITION BY teamID ORDER BY cumulative_sum) AS rn
FROM spending
WHERE cumulative_sum >= 1000000000)

SELECT teamID, yearID, ROUND(cumulative_sum/1000000000, 2) AS cumulative_sum_in_billion
FROM billions
WHERE rn = 1
ORDER BY yearID;
-- Over the years, there have been a lot of teams that have surpassed 1 billion in cumulative spending for salaries.
-- The NYA was the first team to surpass it back then in 2003.

-- PART III: PLAYER CAREER ANALYSIS
-- 1. View the players table and find the number of players in the table
SELECT *
FROM players;

SELECT COUNT(playerID) AS num_player
FROM players;

-- 2. For each player, calculate their age at their first game, their last game, and their career length (all in years). Sort from longest career to shortest career.
SELECT nameGiven, YEAR(debut), YEAR(finalGame),
	   CAST(YEAR(finalGame) AS SIGNED) - CAST(YEAR(debut) AS SIGNED) AS career_length
FROM players
ORDER BY 4 DESC;
-- Nicholas is the player who has the longest career (35 years) in Major League Baseball.

-- 3. What team did each player play on for their starting and ending years?
SELECT p.nameGiven, YEAR(p.debut) AS starting_year, s.teamID AS starting_team,
	   YEAR(p.finalGame) AS ending_year, e.teamID AS ending_team
FROM players p
INNER JOIN salaries s
	ON YEAR(p.debut) = s.yearID
	AND p.playerID = s.playerID
INNER JOIN salaries e
    ON YEAR(p.finalGame) = e.yearID
    AND p.playerID = e.playerID;

-- 4. How many players started and ended on the same team and also played for over a decade?
SELECT *
FROM (
SELECT p.nameGiven, YEAR(p.debut) AS starting_year, s.teamID AS starting_team,
	   YEAR(p.finalGame) AS ending_year, e.teamID AS ending_team
FROM players p
INNER JOIN salaries s
	ON YEAR(p.debut) = s.yearID
	AND p.playerID = s.playerID
INNER JOIN salaries e
    ON YEAR(p.finalGame) = e.yearID
    AND p.playerID = e.playerID) AS new_table
WHERE starting_team = ending_team AND ending_year - starting_year > 10;
-- There are 19 players who started and ended on the same team and also played for over a decade.


-- PART IV: PLAYER COMPARISON ANALYSIS
-- 1. View the players table
SELECT *
FROM players;

-- 2. Which players have the same birthday?
WITH bn AS (SELECT CAST(CONCAT(birthYear, '-', birthMonth, '-', birthDay) AS DATE) AS birthdate,
				   nameGiven
			FROM players)
            
SELECT birthdate, GROUP_CONCAT(nameGiven SEPARATOR ', ') AS players
FROM bn
WHERE birthdate IS NOT NULL
GROUP BY birthdate
ORDER BY birthdate;

-- 3. Create a summary table that shows for each team, what percent of players bat right, left and both
WITH total_bats AS (
SELECT s.teamID, p.bats, s.playerID
FROM salaries s
LEFT JOIN players p
	ON s.playerID = p.playerID)

SELECT teamID,
	   ROUND(SUM(CASE WHEN bats = 'R' THEN 1 ELSE 0 END) / COUNT(playerID) * 100, 1) AS bats_right,
	   ROUND(SUM(CASE WHEN bats = 'L' THEN 1 ELSE 0 END) / COUNT(playerID) * 100, 1) AS bats_left,
	   ROUND(SUM(CASE WHEN bats = 'B' THEN 1 ELSE 0 END) / COUNT(playerID) * 100, 1) AS bats_both
FROM total_bats
GROUP BY teamID;
-- Each team generally has players who bat more right-handed than left-handed.
-- However, there are also some players who bat with both; the SFG team has the highest percentage of players who bat with both.

-- 4. How have average height and weight at debut game changed over the years, and what's the decade-over-decade difference?
WITH Decades AS (
SELECT
	CASE
		WHEN YEAR(debut) BETWEEN 1860 AND 1869 THEN "1860s"
        WHEN YEAR(debut) BETWEEN 1870 AND 1879 THEN "1870s"
        WHEN YEAR(debut) BETWEEN 1880 AND 1889 THEN "1880s"
        WHEN YEAR(debut) BETWEEN 1890 AND 1899 THEN "1890s"
        WHEN YEAR(debut) BETWEEN 1900 AND 1909 THEN "1900s"
        WHEN YEAR(debut) BETWEEN 1910 AND 1919 THEN "1910s"
        WHEN YEAR(debut) BETWEEN 1920 AND 1929 THEN "1920s"
        WHEN YEAR(debut) BETWEEN 1930 AND 1939 THEN "1930s"
        WHEN YEAR(debut) BETWEEN 1940 AND 1949 THEN "1940s"
        WHEN YEAR(debut) BETWEEN 1950 AND 1959 THEN "1950s"
        WHEN YEAR(debut) BETWEEN 1960 AND 1969 THEN "1960s"
        WHEN YEAR(debut) BETWEEN 1970 AND 1979 THEN "1970s"
        WHEN YEAR(debut) BETWEEN 1980 AND 1989 THEN "1980s"
        WHEN YEAR(debut) BETWEEN 1990 AND 1999 THEN "1990s"
        WHEN YEAR(debut) BETWEEN 2000 AND 2009 THEN "2000s"
    ELSE "2010s" END AS Decade,
    AVG(weight) AS average_weight, AVG(height) AS average_height
FROM players
GROUP BY Decade)

SELECT Decade,
	   average_weight, average_weight - LAG(average_weight) OVER(ORDER BY Decade) AS weight_diff,
       average_height, average_height - LAG(average_height) OVER(ORDER BY Decade) AS height_diff
FROM Decades;
-- The average height and weight of MLB players has almost always increased over the years.