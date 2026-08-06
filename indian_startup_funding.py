import pandas as pd
df =pd.read_csv('indian_startup_funding_cleaned.csv')
# How has total funding amount changed year-over-year across 2020-2025?
df['Date'] = pd.to_datetime(df['Date'])
print(df.info())
df['funding_year'] = df['Date'].dt.year
df.to_csv('startup_funding_for_tableau.csv', index=False)
yearly_totals = df.groupby('funding_year')['InvestmentAmount_USD'].sum()
yoy_gr = yearly_totals.pct_change() *100
print(yoy_gr)
#Has the number of funding deals changed year-over-year, separate from the amount?
print(df.groupby('funding_year')['InvestmentAmount_USD'].count())
print(df.groupby('Industry')['InvestmentAmount_USD'].sum().sort_values(ascending=False).head(10))
print(df.groupby('Startup')['Industry'].nunique().sort_values(ascending=False).head(10))
#What is the average deal size per year?
print(df.groupby('funding_year')['InvestmentAmount_USD'].mean())
#Which InvestmentType received the most total funding overall?
print(df.groupby('InvestmentType')['InvestmentAmount_USD'].sum().sort_values(ascending= False))
#Has the mix of InvestmentType shifted over the years?
print(df.groupby(['funding_year','InvestmentType'])['InvestmentAmount_USD'].count())
print(df.groupby(['funding_year','InvestmentType'])['InvestmentAmount_USD'].count().unstack())
counts = df.groupby(['funding_year','InvestmentType'])['InvestmentAmount_USD'].count().unstack()
percentages = counts.div(counts.sum(axis=1), axis=0) * 100
print(percentages.round(1))
#Is there a monthly/seasonal pattern to funding activity?
df['funding_month'] = df['Date'].dt.month
print(df.groupby("funding_month").count())
