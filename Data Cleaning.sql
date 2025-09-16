SELECT *
FROM layoffs;

-- First thing we can do before cleaning data is make an alternative table. --
-- In case of something happens if we use our raw data. --

CREATE TABLE world_layoffs.layoffs_staging
LIKE world_layoffs.layoffs;

-- Don't forget to insert the value from each column for alternative table --

INSERT layoffs_staging
SELECT *
FROM layoffs;

-- These are some steps you can do when you clean your data --
-- 1. Check duplicates and remove it.
-- 2. Standardize data, for example fix inconsistencies, fix outliers, fix data type.
-- 3. Look at null values.
-- 4. Remove irrelevant data.

-- 1. Check duplicates and remove it.

-- Check duplicates by ROW_NUMBER() -> It will return the unique number for each row. If the row number > 1, there is duplicate row

WITH duplicates_cte AS (
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off,percentage_laid_off,`date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging)
SELECT *
FROM duplicates_cte
WHERE row_num > 1;

-- check if it is really duplicates row or no

SELECT *
FROM layoffs_staging
WHERE company = 'Casper';

-- Create another alternative table with one column added called row_num so we could delete the duplicate row

CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Insert row of the new alternative table like the previous alternative table + one added column row_num

INSERT layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off,percentage_laid_off,`date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging;

-- Delete the duplicate row, which is the row number greater than 1

DELETE
FROM layoffs_staging2
WHERE row_num > 1;

-- Check if there are any duplicate rows

SELECT *
FROM layoffs_staging2
WHERE row_num > 1;

SELECT *
FROM layoffs_staging2;

-- We finish to remove the duplicate row!

-- 2. Standardize data, for example fix inconsistencies, fix outliers, fix data type.

-- Check and remove the useless space

SELECT DISTINCT company, TRIM(company)
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company = TRIM(company);

-- Check if some values that have different variations could be grouped into a value.

SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY 1;

-- There Crypto, Crypto Currency, and CryptoCurrency. We could group that into Crypto

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- Next check if there are any useless character in some value of each column

SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY 1;

-- There are United States and United States. (with useless dot), so we can update it to just United States
UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

-- Change data type
-- We know that date column is still in text data type so we need to change that

SELECT `date`
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

-- 3. Look at null values.

SELECT DISTINCT industry
FROM layoffs_staging2
WHERE industry IS NULL OR industry = '';

-- There are null and blank values in industry column, we need to check whether they are null values or not if we look at the other column.

SELECT company, location, industry
FROM layoffs_staging2
WHERE industry IS NULL OR industry = '';

-- So, there are Airbnb, Bally's Interactive, Carvana, and Juul company that have null values in industry column

SELECT company, location, industry
FROM layoffs_staging2
WHERE company IN ('Airbnb', "Bally's Interactive", 'Carvana', 'Juul');

-- We could see that Airbnb is travel industry, Bally's Interactive is null, Carvana is transportation industry, and Juul is consumer industry.
-- But, I think we need to change blank values to null values for easier task.

UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

-- We will update the null value based on the not null value on same company

UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL AND t2.industry IS NOT NULL;

-- 4. Remove irrelevant data.

SELECT *
FROM layoffs_staging2;

-- Remove total_laid_off and percentage_laid_off that have null values in both columns

DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;

-- Remove unimportant column like row_num that we don't need anymore

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

-- VOILA --






