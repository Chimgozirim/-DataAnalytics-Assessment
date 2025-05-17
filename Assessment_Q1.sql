SELECT
    u.id AS owner_id, -- Unique identifier for each user (owner of the plans)
    CONCAT(u.first_name, ' ', u.last_name) AS Full_Name, -- Combining the user's first and last names into a single "Full_Name" column

    -- Count the number of regular savings plan accounts for each user
    SUM(
        CASE
            WHEN p.is_regular_savings = 1 -- Check if the plan is a regular savings plan
            THEN 1 -- If it is, count it as 1
            ELSE 0 -- If not, count it as 0
        END
    ) AS savings_count, -- Alias the calculated count as "savings_count"

    -- Count the number of investment fund plan accounts for each user
    SUM(
        CASE
            WHEN p.is_a_fund = 1 -- Check if the plan is an investment fund
            THEN 1 -- If it is, count it as 1
            ELSE 0 -- If not, count it as 0
        END
    ) AS investment_count, -- Alias the calculated count as "investment_count"

    -- Calculate the net total deposits (confirmed amount minus any deductions) in Naira for each user
    ROUND(
        SUM(
            s.confirmed_amount -- The amount confirmed as deposited (in kobo)
            - COALESCE(s.deduction_amount, 0) -- Subtract the deduction amount (in kobo). COALESCE handles cases where deduction_amount might be NULL, treating it as 0.
        ) / 100.0, -- Divide the total kobo amount by 100.0 to convert to Naira
        2 -- Round the result to 2 decimal places for Naira currency format
    ) AS total_deposits -- Alias the calculated total deposits in Naira as "total_deposits"

FROM savings_savingsaccount s -- Alias the "savings_savingsaccount" table as "s" for brevity
JOIN plans_plan p ON s.plan_id = p.id -- Join "savings_savingsaccount" with "plans_plan" (aliased as "p") using the common "plan_id" to get plan details
JOIN users_customuser u ON s.owner_id = u.id -- Join with the "users_customuser" table (aliased as "u") using "owner_id" to get user information

GROUP BY u.id, Full_Name -- Group the results by user ID and their full name, so aggregate functions (SUM, COUNT) operate on each user

HAVING
    -- Filter the results to include only users who have at least one regular savings plan
    SUM(
        CASE
            WHEN p.is_regular_savings = 1
            THEN 1 ELSE 0
        END
    ) >= 1

AND -- AND also ensure that these users have at least one investment fund plan
    SUM(
        CASE
            WHEN p.is_a_fund = 1
            THEN 1 ELSE 0
        END
    ) >= 1

ORDER BY total_deposits DESC; -- Finally, order the results in descending order based on the "total_deposits", showing users with the highest total deposits first