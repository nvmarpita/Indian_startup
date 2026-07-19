# Indian_startup
## Data Cleaning

**Source:** Indian Startup Funding dataset (2020–2025),
https://www.kaggle.com/datasets/vagdevititikshag/indian-startup-funding-dataset-20202025 
**Rows:** 1,100 | **Columns:** |Startup |Industry |SubVertical |City| Investors |InvestmentType |InvestmentAmount_USD |Date|

### Checks performed
- Null values: none found across all columns
- Duplicate rows: checked using [Startup, InvestmentType, Date,
  InvestmentAmount_USD, Investors] as the matching key — none found
- Date range: valid, all dates fall between 2020-01-02 and 2025-06-30
- Investment amounts: no negative or null values
- Categorical consistency: checked City, Industry, InvestmentType for
  spelling/casing/whitespace inconsistencies — none found
- Additionally checked SubVertical (44 distinct values)  and Investors
   (423 distinct values) by comparing CO UNT(DISTINCT column) against COUNT(DISTINCT LOWER(TRIM(column))).
Counts matched in both cases, confirming no casing or whitespace inconsistencies.

### Key finding: likely synthetic data
Cross-referencing Startup name against Industry revealed that 130 of
180 unique startups appear multiple times with conflicting Industry,
City, and Investor values (e.g., the same company name attached to
unrelated sectors and cities across rows). This suggests the dataset
is synthetically generated rather than real historical records.

**Decision:** treating each row as an independent funding event rather
than a verified company profile; avoiding company-level industry
claims in the analysis.

### Additional checks
- Grouped InvestmentAmount_USD by InvestmentType (MIN/MAX/AVG). Amounts
  largely follow expected funding-stage progression, with one anomaly:
  average Seed funding ($499K) exceeds average Pre-Series A funding
  ($397K) — inverted from typical real-world ordering.
- Amounts are reported in USD with no exchange-rate/conversion date
  provided, so cross-year USD comparisons carry some imprecision.

### Table created
`transactions_cleaned` — original data plus a `row_num` column
(added via ROW_NUMBER()) to serve as a unique row identifier, since
the source data had none.
