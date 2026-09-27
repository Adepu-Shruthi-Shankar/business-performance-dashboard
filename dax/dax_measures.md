# DAX Measures — Business Performance Dashboard

Create a dedicated measures table first: **Modeling ▸ New Table**

```DAX
_Measures = { BLANK() }
```

Then add every measure below to that table (right-click ▸ New Measure). Keeping
measures in their own table (instead of scattered across data tables) is a
best-practice pattern worth calling out in your README / interview talking points.

## 1. Date Table (required for time intelligence)

```DAX
DimDate =
ADDCOLUMNS (
    CALENDAR ( DATE(2022,1,1), DATE(2024,12,31) ),
    "Year", YEAR ( [Date] ),
    "Month", FORMAT ( [Date], "MMM" ),
    "MonthNum", MONTH ( [Date] ),
    "Quarter", "Q" & FORMAT ( [Date], "Q" ),
    "YearMonth", FORMAT ( [Date], "MMM YYYY" )
)
```
Mark this as a **Date Table** (Table tools ▸ Mark as date table), then build a
relationship from `DimDate[Date]` → `sales_operations[order_date]`.

## Core Revenue & Sales KPIs

```DAX
Total Revenue = SUM ( sales_operations[revenue] )

Total Units Sold = SUM ( sales_operations[units_sold] )

Total Orders = DISTINCTCOUNT ( sales_operations[order_id] )

Average Order Value = DIVIDE ( [Total Revenue], [Total Orders] )

Total Cost = SUM ( sales_operations[cost] )

Total Profit = SUM ( sales_operations[profit] )

Profit Margin % = DIVIDE ( [Total Profit], [Total Revenue] )
```

## Time Intelligence (YoY / MoM)

```DAX
Revenue PY =
CALCULATE ( [Total Revenue], SAMEPERIODLASTYEAR ( DimDate[Date] ) )

Revenue YoY % =
DIVIDE ( [Total Revenue] - [Revenue PY], [Revenue PY] )

Revenue PM =
CALCULATE ( [Total Revenue], DATEADD ( DimDate[Date], -1, MONTH ) )

Revenue MoM % =
DIVIDE ( [Total Revenue] - [Revenue PM], [Revenue PM] )

Revenue YTD =
TOTALYTD ( [Total Revenue], DimDate[Date] )

Revenue Rolling 3M =
CALCULATE (
    [Total Revenue],
    DATESINPERIOD ( DimDate[Date], MAX ( DimDate[Date] ), -3, MONTH )
)
```

## Regional / Product Performance

```DAX
Revenue Rank by Region =
RANKX ( ALL ( sales_operations[region] ), [Total Revenue], , DESC )

% of Total Revenue =
DIVIDE ( [Total Revenue], CALCULATE ( [Total Revenue], ALL ( sales_operations ) ) )

Best Product Line =
CALCULATE (
    SELECTEDVALUE ( sales_operations[product_line] ),
    TOPN ( 1, ALL ( sales_operations[product_line] ), [Total Revenue] )
)

Underperforming Region Flag =
IF ( [Revenue YoY %] < 0, "⚠ Underperforming", "On Track" )
```

## Operations KPIs

```DAX
Avg Delivery Days = AVERAGE ( sales_operations[delivery_days] )

Return Rate % =
DIVIDE (
    CALCULATE ( [Total Orders], sales_operations[order_status] = "Returned" ),
    [Total Orders]
)

Cancellation Rate % =
DIVIDE (
    CALCULATE ( [Total Orders], sales_operations[order_status] = "Cancelled" ),
    [Total Orders]
)

On-Time Delivery % =
DIVIDE (
    CALCULATE ( [Total Orders], sales_operations[delivery_days] <= 5 ),
    CALCULATE ( [Total Orders], NOT ISBLANK ( sales_operations[delivery_days] ) )
)

Discount Impact =
SUMX ( sales_operations, sales_operations[revenue] * sales_operations[discount_pct] / 100 )
```

## Customer / Sales Rep KPIs

```DAX
Active Sales Reps = DISTINCTCOUNT ( sales_operations[sales_rep] )

Revenue per Sales Rep = DIVIDE ( [Total Revenue], [Active Sales Reps] )

Enterprise Revenue % =
DIVIDE (
    CALCULATE ( [Total Revenue], sales_operations[customer_segment] = "Enterprise" ),
    [Total Revenue]
)
```

---

### That's 20 measures covering revenue, profit, growth, regional/product mix,
### operations, and customer segments — comfortably above the "15+ KPIs" claim
### in the résumé bullet. Use only the ones that make sense for your final
### visuals; you don't need every one on the canvas.
