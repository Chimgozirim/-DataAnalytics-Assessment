-- Account Inactivity Alert Query
-- Flags active accounts (Savings or Investment) with no inflow in the past 365 days

WITH last_inflow AS (
    SELECT
        s.plan_id,
        s.owner_id,
        -- Most recent positive inflow date per account
        MAX(s.transaction_date) AS last_transaction_date
    FROM savings_savingsaccount s
    WHERE s.confirmed_amount > 0
    GROUP BY
        s.plan_id,
        s.owner_id
)

SELECT
    l.plan_id,
    l.owner_id,
    -- Determine plan type
    CASE
        WHEN p.is_regular_savings = 1 THEN 'Savings'
        WHEN p.is_a_fund          = 1 THEN 'Investment'
        ELSE 'Other'
    END                          AS type,
    l.last_transaction_date,
    -- Days since last inflow
    DATEDIFF(CURRENT_DATE, l.last_transaction_date) AS inactivity_days
FROM last_inflow l
JOIN plans_plan p
    ON l.plan_id = p.id
WHERE
    -- More than one year (365 days) of inactivity
    DATEDIFF(CURRENT_DATE, l.last_transaction_date) > 365
    AND (p.is_regular_savings = 1 OR p.is_a_fund = 1)
ORDER BY inactivity_days DESC;
-- Account Inactivity Alert Query
-- Flags active accounts (Savings or Investment) with no inflow in the past 365 days

WITH last_inflow AS (
    SELECT
        s.plan_id,
        s.owner_id,
        -- Most recent positive inflow date per account
        MAX(s.transaction_date) AS last_transaction_date
    FROM savings_savingsaccount s
    WHERE s.confirmed_amount > 0
    GROUP BY
        s.plan_id,
        s.owner_id
)

SELECT
    l.plan_id,
    l.owner_id,
    -- Determine plan type
    CASE
        WHEN p.is_regular_savings = 1 THEN 'Savings'
        WHEN p.is_a_fund          = 1 THEN 'Investment'
        ELSE 'Other'
    END                          AS type,
    l.last_transaction_date,
    -- Days since last inflow
    DATEDIFF(CURRENT_DATE, l.last_transaction_date) AS inactivity_days
FROM last_inflow l
JOIN plans_plan p
    ON l.plan_id = p.id
WHERE
    -- More than one year (365 days) of inactivity
    DATEDIFF(CURRENT_DATE, l.last_transaction_date) > 365
    AND (p.is_regular_savings = 1 OR p.is_a_fund = 1)
ORDER BY inactivity_days DESC;