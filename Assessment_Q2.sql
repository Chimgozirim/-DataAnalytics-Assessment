-- Transaction Frequency Analysis Query
-- Calculates average transactions per customer per month and categorizes frequency

WITH monthly_counts AS (
    -- 1. Count transactions per customer per month
    SELECT
        s.owner_id,
        DATE_FORMAT(s.transaction_date, '%Y-%m') AS `Year_Month`,
        COUNT(*) AS tx_count
    FROM savings_savingsaccount s
    GROUP BY
        s.owner_id,
        DATE_FORMAT(s.transaction_date, '%Y-%m')
),

customer_avgs AS (
    -- 2. Compute each customer’s average transactions per month
    SELECT
        m.owner_id,
        ROUND(AVG(m.tx_count), 2) AS avg_tx_per_month
    FROM monthly_counts m
    GROUP BY m.owner_id
),

categorized AS (
    -- 3. Bucket customers by frequency category
    SELECT
        m.owner_id,
        CASE
            WHEN m.avg_tx_per_month >= 10 THEN 'High Frequency'
            WHEN m.avg_tx_per_month BETWEEN 3 AND 9 THEN 'Medium Frequency'
            ELSE 'Low Frequency'
        END AS frequency_category,
        m.avg_tx_per_month
    FROM customer_avgs m
)

-- 4. Aggregate counts and average per category
SELECT
    c.frequency_category,
    COUNT(*) AS customer_count,
    ROUND(AVG(c.avg_tx_per_month), 2) AS avg_transactions_per_month
FROM categorized c
GROUP BY c.frequency_category
ORDER BY
    CASE c.frequency_category
        WHEN 'High Frequency' THEN 1
        WHEN 'Medium Frequency' THEN 2
        WHEN 'Low Frequency' THEN 3
    END;
