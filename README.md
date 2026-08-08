# Indian_startup
## Introduction

This project analyzes startup funding activity in India between 2020 and 2025, 
using a dataset of 1,100 funding transactions sourced from Kaggle. The goal is 
to explore how funding amounts and deal activity have evolved year-over-year, 
and to surface patterns across industries, cities, and investment stage

## Tools Used
- **BigQuery (SQL)** — data validation queries (duplicate checks, distinct-value 
  counts, casing/whitespace checks) and creation of the `transactions_cleaned` 
  table with a `row_num` identifier
- **Python (pandas)** — exploratory analysis, groupby aggregations for 
  year/industry/city-level trends
- **Tableau** — data visualization

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
   (423 distinct values) by comparing COUNT(DISTINCT column) against COUNT(DISTINCT LOWER(TRIM(column))).
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

### Business Questions-
◆ How has total funding amount changed year-over-year across 2020-2025?
Finding: Year-over-Year Funding Growth (2021–2024, with 2025 partial-year note)
Total startup funding showed high volatility year-over-year:
- 2020:  $4.76B — baseline year (excluded from YoY % calculation; no prior year to compare against).
- 2021:  $6.02B (+26.66%) — the strongest growth year in the dataset, marking a sharp rebound in funding activity.
- 2022: $4.51B (-25.15%) — funding pulled back sharply, reversing the prior year's gain.
- 2023: $4.00B (-11.26%) — decline continued, though at a slower pace than 2022.
- 2024: $5.98B (+49.42%) — a strong recovery, the largest single-year swing in the dataset.
- 2025: $2.81B — excluded from YoY trend. This figure reflects only a partial year of data and is not comparable to the full-year totals above; it is shown for reference only, not as a trend data point.
  
◆ Has the number of funding deals changed year-over-year, separate from the amount?

 2021 saw fewer but bigger deals. 2022–2023 saw more deals but smaller ones, pulling totals down. 2024's 49% jump came mainly from bigger deals, not more of them.
| Year	|Count|	Total funding|	Pattern|
-------|------|---------------|--------|
|2021	|↓	|↑ |Fewer, bigger deals|
|2022	|↑	|↓ |More, smaller deals|
|2023	|↑	|↓ |More, smaller deals|
|2024	|↑ (slight)|	↑ (large)	|Bigger deals mainly, not more of them|
|2025 |(partial)|	(partial)	|Not comparable|
## Known Limitations

- **Row-level label inconsistency**: A subset of startups (~130 of 180) have inconsistent City and/or Industry 
  values across their funding rows — same company, different label per row. This is most severe for Industry, 
  where some startups span 8-11 different values. Since groupby() trusts each row's label as-is, this splits 
  a startup's funding across multiple categories instead of consolidating it under one, distorting city- and 
  industry-level rankings (totals should be read as directional, not exact).
- **Deal count and average deal size**: The same fragmentation inflates deal counts and understates average 
  deal size per year — a single funding round split across multiple rows looks like several smaller deals 
  rather than one larger one, so year-over-year average deal size should also be read as directional, not exact.

## Data Visualization

Interactive dashboards for this analysis were built in Tableau and can be 
explored here:
https://public.tableau.com/app/profile/arpita.gupta4384/viz/indianstartupdashboard/Dashboard1

The dashboard covers:
- **Year-over-year funding trend (2020–2025)** — total funding amount and 
  deal count by year, highlighting the 2022–2023 pullback and 2024 rebound
- **Industry breakdown** — funding distribution across industries (read as 
  directional, not exact — see Known Limitations)
- **Average Deal Size by Year funding** — top cities by total funding and deal count
- **Investment type / stage analysis** — funding amounts by stage 
  (Seed, Pre-Series A, etc.)

*Note: since GitHub can't render Tableau dashboards inline, a static 
screenshot is included below for quick reference — click through to the 
link above for the interactive version*
![Dashboard screenshot](https://github.com/nvmarpita/Indian_startup/blob/main/Indian%20Startup%20Funding%20Dashboard.png)

