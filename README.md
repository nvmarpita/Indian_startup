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

◆ Data Limitation: City Attribution
- The fact: Startup city data isn't always consistent — the same startup appears with multiple different city values across rows. Among the top-funded entries, Oyo, DriveEdge, NeoLabs, and LogiMart each show up under 9 distinct cities. This is part of a broader pattern affecting 130 of 180 startups in the dataset (across various fields, not just city).
- The consequence: Because the city ranking is built with groupby('City').sum(), it trusts each row's city label as-is. A startup's funding gets split across whichever cities it was recorded under, rather than being attributed to one consistent location — so a single high-funding startup can inflate several cities' totals instead of just its "true" city.
- What to do with it: Treat the city ranking as directional/approximate, not a precise geographic breakdown. It's useful for spotting broad regional trends (e.g., which metro areas dominate funding activity), but exact rank order and totals for individual cities shouldn't be read as authoritative.

◆ Data Limitation: Industry Attribution
- The fact: Industry labels show the same row-level scrambling problem as City. FreshTech and DriveEdge each appear under 11 different Industry values, Porter and Bounce under 10, and several more startups show up under 9 distinct industries. This is the same underlying pattern found in the City data, just applied to a different attribute.
- The consequence: Because groupby('Industry').sum() trusts each row's industry label as-is, a startup's funding gets split across whichever industries it was recorded under, rather than being attributed to one consistent sector. A startup that should consistently be tagged "FinTech," for example, may have its funding scattered across 8–11 different Industry labels — diluting FinTech's true total and inflating whichever labels absorbed the misattributed rows.
-  What to do with it: Treat the Industry ranking as directional/approximate, not a precise sector breakdown. In particular, any "surprising" result (e.g. FinTech or E-commerce ranking lower than expected) shouldn't be read as a real market signal — it's very plausibly an artifact of this data quality issue rather than genuine industry performance.
