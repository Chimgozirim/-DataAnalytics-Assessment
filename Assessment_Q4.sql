-- Customer Lifetime Value (CLV) Estimation Query
-- Calculates tenure, total transactions, and estimated CLV per customer

WITH customer_metrics AS (
    SELECT
        u.id AS customer_id,
        CONCAT(u.first_name, ' ', u.last_name) AS Full_Name,
        -- Tenure in full months since signup
        TIMESTAMPDIFF(MONTH, u.date_joined, CURRENT_DATE) AS tenure_months,
        -- Total number of transactions for each customer
        COUNT(s.id) AS total_transactions,
        -- Average transaction amount in kobo
        AVG(s.confirmed_amount) AS avg_confirmed_kobo
    FROM users_customuser u
    LEFT JOIN savings_savingsaccount s
        ON s.owner_id = u.id
    GROUP BY u.id, u.first_name, tenure_months
    HAVING tenure_months > 0  -- Exclude customers with less than 1 month tenure
)

SELECT
    customer_id,
    Full_Name,
    tenure_months,
    total_transactions,
    -- Compute CLV:
    -- 1. Annualized transaction frequency: (total_transactions / tenure_months) * 12
    -- 2. Profit per transaction: (avg_confirmed_kobo / 100.0) * 0.001
    -- 3. CLV = annualized frequency * profit per transaction
    ROUND(
        ((CAST(total_transactions AS DECIMAL(10,2)) / tenure_months) * 12)
        * ((avg_confirmed_kobo / 100.0) * 0.001),
        2
    ) AS estimated_clv
FROM customer_metrics
ORDER BY estimated_clv DESC;
