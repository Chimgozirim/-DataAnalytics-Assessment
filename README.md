# -DataAnalytics-Assessment

This repository contains SQL query files addressing four key business scenarios. Below are explanations of the approach taken in each query and challenges encountered during development.

---

## Task 1: High-Value Customers with Multiple Products (`high_value_customers.sql`)

**Approach:**

* Joined the `savings_savingsaccount`, `plans_plan`, and `users_customuser` tables to correlate account records with plan types and customer identities.
* Used conditional aggregation (`SUM(CASE ... END)`) to count funded savings plans (`is_regular_savings = 1`) and funded investment plans (`is_a_fund = 1`), defining “funded” as net positive inflow (`confirmed_amount - deduction_amount > 0`).
* Computed `total_deposits` by summing net inflows (in kobo) and converting to Naira, rounding to two decimal places.
* Filtered with `HAVING` to include only customers with at least one of each type and ordered by deposit totals descending.

**Challenges:**

* I had a challenge with syntax and the best methods, so I kept researching since I already had the concept and idea of what I needed to do. This means I must plosh my SQL skills.
* **Negative balances:** Some customers had net negative deposits. Addressed by discussing exclusion or flooring strategies, but ultimately preserved negatives to reflect realistic fee/overdraft scenarios.

---

## Task 2: Transaction Frequency Analysis (`transaction_frequency_analysis.sql`)

**Approach:**

* Built a `monthly_counts` CTE to tally transactions per customer per calendar month using `DATE_FORMAT(transaction_date, '%Y-%m')`.
* Aggregated into `customer_avgs` by averaging monthly counts per customer.
* Categorized each customer into “High”, “Medium”, or “Low” frequency buckets based on their personal average.
* Produced final summary showing the count of customers per bucket and the bucket’s overall average transactions/month, ordering buckets logically.

**Challenges:**

* **Alias typo:** The alias `year_month` was flagged maybe because it was part of MySQL inbuilt functions; so I enclosed it in backticks to match downstream references.
* **Dialect consistency:** Ensured `DATE_FORMAT` syntax aligned with MySQL; no further adjustments were needed.

---

## Task 3: Account Inactivity Alert (`account_inactivity_alert.sql`)

**Approach:**

* Created a `last_inflow` CTE to capture each account’s most recent positive inflow date (`MAX(transaction_date)` where `confirmed_amount > 0`).
* Joined to the `plans_plan` table to identify plan type (Savings vs. Investment).
* Calculated inactivity days via `DATEDIFF(CURRENT_DATE, last_transaction_date)` and filtered for accounts dormant over 365 days.
* Ordered results by longest inactivity.

**Challenges:**

* **Definition of active accounts:** Clarified that only plans flagged as savings or investment, and not plans flagged as savings **AND** investment (like in the first task), should be considered, hence the explicit `OR` filter in the `WHERE` clause.

---

## Task 4: Customer Lifetime Value Estimation (`clv_estimation.sql`)

**Approach:**

* Computed each customer’s tenure in months using `TIMESTAMPDIFF(MONTH, date_joined, CURRENT_DATE)`.
* Counted total transactions and averaged transaction size in kobo.
* Annualized transaction frequency (`total_tx / tenure_months * 12`) and calculated profit per transaction as 0.1% of transaction value (`avg_kobo / 100 * 0.001`).
* Multiplied these two factors to estimate simplified CLV, rounding to two decimal places.

**Challenges:**

* **Casting syntax:** Initial PostgreSQL‐style cast `::DECIMAL` caused errors. Switched to MySQL’s `CAST(... AS DECIMAL(10,2))` for correct decimal division.
* **Zero‐tenure guards:** Added a `HAVING tenure_months > 0` to prevent division by zero for very new users.

---

*End of README.md*
