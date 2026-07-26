
--  Null value check across all columns and count of total rows.
SELECT
  COUNT(*) AS total_rows,
  COUNTIF(`Startup` IS NULL) AS null_startup,
  COUNTIF(`Industry` IS NULL) AS null_industry,
  COUNTIF(`SubVertical` IS NULL) AS null_subvertical,
  COUNTIF(`City` IS NULL) AS null_city,
  COUNTIF(`Investors` IS NULL) AS null_investors,
  COUNTIF(`InvestmentType` IS NULL) AS null_investmenttype,
  COUNTIF(`InvestmentAmount_USD` IS NULL) AS null_amount,
  COUNTIF(`Date` IS NULL) AS null_date
FROM `retail-sales-analytics-501811.indian_startup_funding.transactions`;
-- Result: no nulls found in any column
-- ===========================================
-- Check duplicate Values 
SELECT
  `startup`,
  `investmenttype`,
  `date`,
  `InvestmentAmount_USD`,
  `investors`,
  COUNT(*) AS cnt
FROM `retail-sales-analytics-501811.indian_startup_funding.transactions`
GROUP BY
  `startup`,
  `investmenttype`,
  `date`,
  `InvestmentAmount_USD`,
  `investors`
HAVING COUNT(*) > 1;
-- Result: no duplicate rows found
-- ============================================
 -- Verify each startup consistently maps to one Industry
-- (found: 130/180 startups have conflicting values — see README)
 SELECT
`startup`,
COUNT(DISTINCT `industry`) AS diff_industry,
COUNT(*) AS total_count
FROM `retail-sales-analytics-501811.indian_startup_funding.transactions`
GROUP BY `startup`
HAVING COUNT(*)> 1;
-- Result: 130 rows returned = 130 startups with conflicting Industry values
-- ===========================================
-- Check date range validity
SELECT
  MIN(`Date`) AS earliest_date,
  MAX(`Date`) AS latest_date
FROM `retail-sales-analytics-501811.indian_startup_funding.transactions`;
-- Result: 2020-01-02 to 2025-06-30 — consistent with dataset's stated 2020-2025 window. 
-- Check InvestmentType vs InvestmentAmount_USD for logical consistency
SELECT
  `InvestmentType`,
  MIN(`InvestmentAmount_USD`) AS min_amount,
  MAX(`InvestmentAmount_USD`) AS max_amount,
  AVG(`InvestmentAmount_USD`) AS avg_amount
FROM `retail-sales-analytics-501811.indian_startup_funding.transactions`
GROUP BY `InvestmentType`;
-- Result: amounts largely follow expected funding-stage progression
-- (Angel < Seed < Series A < ... < Growth), with one anomaly:
-- average Seed funding ($499K) exceeds average Pre-Series A funding
-- ($397K), inverted from typical real-world ordering.
-- ============================================
--  Investment amount sanity check
SELECT `InvestmentType`
FROM `retail-sales-analytics-501811.indian_startup_funding.transactions`
WHERE `InvestmentAmount_USD` < 0;
-- Result: none found
-- ============================================
--  Added row_num as unique identifier
CREATE OR REPLACE  TABLE `retail-sales-analytics-501811.indian_startup_funding.transactions_cleaned` AS
SELECT
ROW_NUMBER() OVER() AS ROW_NUM,
*
 FROM `retail-sales-analytics-501811.indian_startup_funding.transactions`
 ORDER BY ROW_NUM ASC;
-- Result: 1,100 rows, row_num added as unique identifier (source data had none)