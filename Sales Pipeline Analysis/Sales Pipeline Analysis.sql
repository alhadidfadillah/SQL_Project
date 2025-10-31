-- Sales Pipeline Analysis --

/* The Objectives:
-- Objective 1: Pipeline Metrics --
-> Assess the overall sales pipeline by looking at opportunities by month, time to close, win rate, and product data.
First, we can calculate the number of sales opportunities created each month using "engage_date",
and identify the month with the most opportunities. */
SELECT MONTH(engage_date) AS `Month`, COUNT(*) AS `Deal Counts`
FROM sales_pipeline
GROUP BY `Month`
ORDER BY 2 DESC;
-- The deals often occur in July.

/* Second, we would like to find and compare the average amount of time between lost deals (still closed deal) versus won deals.
(from "engage_date" to "close_date")*/
SELECT deal_stage, ROUND(AVG((DATEDIFF(close_date, engage_date))), 0) AS `Average Time Deals`
FROM sales_pipeline
GROUP BY deal_stage;
-- The won deals took 9 days longer than the lost deals.
-- It tells us that the won deals might need some more advanced negotiations, so it took a longer time.

-- Third, we would like to compare deals stage percentage. What percent were lost?
SELECT ROUND(SUM(CASE WHEN deal_stage = "Lost" THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS `Lost Deal Percentage`
FROM sales_pipeline;
-- Our lost deal percentage was around 37%. That was quite huge.

-- Fourth, we would like to compare the win rate percentage for each product. Which one had the highest win rate?
SELECT product, ROUND(SUM(CASE WHEN deal_stage = "Won" THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS `Win Rate`
FROM sales_pipeline
GROUP BY product
ORDER BY 2 DESC;
-- MG Special is the product with the highest win rate.


-- Objective 2: Sales Agent Performance --
-- Assess the performance of sales agents, their managers, and regional offices.
-- First, we would like to calculate each sales agents win rate, find the top performer.
SELECT sales_agent, ROUND(SUM(CASE WHEN deal_stage = "Won" THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS `Win Rate`
FROM sales_pipeline
GROUP BY sales_agent
ORDER BY 2 DESC;
-- The top performing sales agent is Hayden Neloms with a 70.39% win rate.

-- Second, we would like to calculate total revenue by agent and see who generated the most.
SELECT sales_agent, SUM(close_value) AS `Total Revenue`
FROM sales_pipeline
GROUP BY sales_agent
ORDER BY 2 DESC;
-- The agent who generated the most total revenue is Darcel Schlecht with 1,153,214 total revenue.

-- Third, we would like to find which manager's team performed the best.
SELECT st.manager, ROUND(SUM(CASE WHEN sp.deal_stage = "Won" THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS `Win Rate`
FROM sales_pipeline AS sp
JOIN sales_teams AS st
	ON sp.sales_agent = st.sales_agent
GROUP BY st.manager
ORDER BY 2 DESC;
-- Cara Losch is the best manager with the highest win rate (64.43%).

-- Fourth, we would like to see which regional office with the most units sold of the GTX Plus Pro Product.
SELECT st.regional_office,
	   SUM(CASE WHEN sp.deal_stage = "Won" AND sp.product = "GTX Plus Pro" THEN 1 ELSE 0 END) AS `Unit Sold`
FROM sales_pipeline AS sp
JOIN sales_teams AS st
	ON sp.sales_agent = st.sales_agent
GROUP BY st.regional_office
ORDER BY 2 DESC;
-- The Central region sold the most units of GTX Plus Pro Product.


-- Objective 3: Product Analysis --
-- Analyze the sales performance and quantity sold of the company's product portfolio.
-- First, we would like to see the product with highest revenue and compare it to most units sold product in March.
SELECT product, SUM(close_value) AS Revenue, COUNT(*) AS `Units Sold`
FROM sales_pipeline
WHERE deal_stage= "Won" AND MONTH(close_date) = 3
GROUP BY product
ORDER BY 2 DESC;
-- We can see that the product with the highest revenue is GTXPro but it is not the most units sold.
-- The most units sold is GTX Basic.

-- Second, we want to find the average difference between sales price and close value for each product.
SELECT sp.product, ROUND(AVG(p.sales_price - sp.close_value), 2) AS `Average Differences`
FROM sales_pipeline AS sp
LEFT JOIN products AS p
	ON sp.product = p.product
WHERE sp.deal_stage = "Won"
GROUP BY sp.product
ORDER BY 2 DESC;
-- GTK 500 has the highest average difference between sales price and close value (60.53).
-- It means that GTK 500 has an average of 60% discount on its product.
-- GTXPro has a null value because when we join the column to Product table, it doesn't have the same column name "GTX Pro" (with space).

-- Third, we need to compare total revenue by each product series.
SELECT p.series, SUM(sp.close_value) AS `Total Revenue`
FROM products AS p
LEFT JOIN sales_pipeline AS sp
	ON p.product = sp.product
WHERE sp.deal_stage = "Won"
GROUP BY p.series
ORDER BY 2 DESC;
-- The GTX series has the most total revenue, while GTK series has the least total revenue.

-- Objective 4: Account Analysis --
-- Analyze the company's accounts to get a better understanding of the team's customers
-- First, we need to calculate revenue by office location to identify the lowest performer.
SELECT office_location, ROUND(SUM(revenue), 2) AS `Total Revenue`
FROM accounts
GROUP BY office_location
ORDER BY 2;
-- China has the lowest revenue.

-- Second, Find the gap in years between the oldest and newest customer, and name those companies.
SELECT account, year_established
FROM accounts
ORDER BY 2
LIMIT 1;
-- The oldest customer was established in 1979.
SELECT account, year_established
FROM accounts
ORDER BY 2 DESC
LIMIT 1;
-- The newest customer was established in 2017
-- The gap is 38 years.

-- Third, we would like to find out which accounts that were subsidiaries had the most lost sales opportunities.
SELECT a.account, COUNT(sp.opportunity_id) AS `Total Lost Sales Opportunities`
FROM accounts AS a
LEFT JOIN sales_pipeline AS sp
	ON a.account = sp.account
WHERE sp.deal_stage = "Lost" AND a.subsidiary_of != ""
GROUP BY a.account
ORDER BY 2 DESC;
-- Codehow is the account that were subsidiaries which had the most lost sales opportunities with 45 in total.

-- Fourth, we would like to see companies with their subsidiaries and find out which one had the highest total revenue?
-- The blank space in subsidiary_of column means the account was the company's parent.
WITH company_parent AS (
SELECT account,
	CASE
		WHEN subsidiary_of = "" THEN account
        ELSE subsidiary_of
	END AS company_parents
FROM accounts),

Revenue AS (
SELECT account, close_value
FROM sales_pipeline
WHERE deal_stage = "Won"
)

SELECT cp.company_parents, SUM(r.close_value) AS `Total Revenue`
FROM company_parent AS cp
JOIN Revenue AS r
	ON cp.account = r.account
GROUP BY cp.company_parents
ORDER by 2 DESC;
-- The company and their subsidiary that had the highest total revenue is Acme Corporation.
