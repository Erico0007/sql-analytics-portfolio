# sql-analytics-portfolio
"T-SQL queries, window functions, CTEs, and financial/healthcare analytics exercises
# T-SQL Analytics & Financial/Operational Modeling Portfolio

A structured collection of **T-SQL (SQL Server)** queries and analytical patterns demonstrating data manipulation, relational joins, multi-step Common Table Expressions (CTEs), recursive hierarchies, and window functions.

Designed to reflect practical analytical workflows applicable to **data analytics**, **business intelligence**, and **credit/financial risk analysis**—such as customer/entity spend tiering, activity timelines, rolling trend metrics, and organizational or facility hierarchies.

---

## Key Analytical Capabilities

- **Aggregations & Segmentation:** Grouping transaction and event records, calculating totals/averages, and classifying entities into spend or risk tiers using `CASE` logic.
- **Activity Consolidation (`UNION ALL`):** Combining multi-source operational logs (such as visits/transactions and follow-on items) into a single chronological event stream with standardized schemas and data types.
- **Multi-CTE Pipelines:** Breaking complex analytical logic into readable, modular stages (`WITH` chained CTEs) before joining summary metrics back to detailed records.
- **Hierarchical Traversal (Recursive CTEs):** Mapping parent-child relationships (`ParentID` / `ParentFacilityID`), computing hierarchy depth levels, and building breadcrumb paths.
- **Window Functions & Temporal Analysis:** Ranking records within partitions (`DENSE_RANK()`), bucketing distributions (`NTILE()`), measuring intervals between sequential events (`LAG()` + `DATEDIFF()`), and computing rolling window averages (`AVG() OVER (... ROWS BETWEEN ...)`).

---

## Repository Structure

```text
├── schema/
│   └── 01_create_and_seed_tables.sql      # DDL definitions, keys, constraints, and sample dataset setup
├── queries/
│   ├── 01_aggregations_and_filtering.sql  # Group summaries, HAVING filters, and subqueries
│   ├── 02_consolidated_activity_logs.sql  # UNION ALL event timelines and type alignment
│   ├── 03_multi_cte_spend_profiling.sql   # Chained CTEs and tier classification
│   ├── 04_recursive_hierarchy.sql         # Self-referencing CTEs, depth levels, and path strings
│   └── 05_window_functions_and_trends.sql # DENSE_RANK, NTILE, LAG intervals, and moving averages
└── README.md
