-- Exploratory Data Analysis

SELECT *
FROM layoffs_staging2;

-- We are looking for which company has the most single laid off

SELECT company, location, industry, total_laid_off, `date`
FROM layoffs_staging2
WHERE total_laid_off IS NOT NULL
ORDER BY 4 DESC;

-- Google has the most single layoff in 2023

-- Next we are looking for which company has the most total laid off

SELECT company, SUM(total_laid_off) AS Total_Laid_Off
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

-- Amazon has the mos total layoff
-- Next, we want to see which industry has the most total laid off

SELECT industry, SUM(total_laid_off) AS Total_Laid_Off
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;

-- Consumer industry has the most impact of total laid off
-- Now, we are looking for which country has the most total layoff

SELECT country, SUM(total_laid_off) AS Total_Laid_Off
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;

-- As we know, the US must be the most total layoff country
-- Next, we want to see how many total layoff month after month

WITH rolling_total AS (
SELECT SUBSTRING(`date`, 1, 7) AS `Month`, SUM(total_laid_off) AS Total_Laid_Off
FROM layoffs_staging2
WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
GROUP BY `Month`
ORDER BY `Month` ASC)
SELECT `Month`, Total_Laid_Off, SUM(Total_Laid_Off) OVER(ORDER BY `Month` ASC) AS Rolling_Total
FROM rolling_total
ORDER BY `Month` ASC;

-- Last, we want to rank the most layoff company per year

WITH Company_Years AS (
SELECT company, YEAR(`date`) AS `Year`, SUM(total_laid_off) AS Total_Laid_Off
FROM layoffs_staging2
GROUP BY company, `Year`),
Company_Rank (Company, Years, Total_Laid_Off, Ranking) AS (
SELECT company, `Year`, Total_Laid_Off, DENSE_RANK() OVER(PARTITION BY `Year`ORDER BY Total_Laid_Off DESC) AS Ranking
FROM Company_Years)
SELECT *
FROM Company_Rank
WHERE Ranking <= 5 AND Years IS NOT NULL
ORDER BY Years ASC, Total_Laid_Off DESC;
