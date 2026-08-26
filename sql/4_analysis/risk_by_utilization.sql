SELECT * FROM accepted_loans_clean	
LIMIT 10;

--default rate by credit utiliztion
SELECT
    CASE
        WHEN revol_util < 20 THEN '0-20%'
        WHEN revol_util < 40 THEN '20-40%'
        WHEN revol_util < 60 THEN '40-60%'
        WHEN revol_util < 80 THEN '60-80%'
        ELSE '80%+'
    END AS utilization_bucket,
    COUNT(*) AS loans,
    ROUND(AVG(is_default), 4) * 100 AS default_rate
FROM accepted_loans_clean
WHERE is_default IS NOT NULL
GROUP BY utilization_bucket
ORDER BY utilization_bucket;

--default rate by credit card utiliztion
SELECT
    CASE
        WHEN bc_util < 20 THEN '0-20%'
        WHEN bc_util < 40 THEN '20-40%'
        WHEN bc_util < 60 THEN '40-60%'
        WHEN bc_util < 80 THEN '60-80%'
        ELSE '80%+'
    END AS utilization_bucket,
    COUNT(*) AS loans,
    ROUND(AVG(is_default), 4) * 100 AS default_rate
FROM accepted_loans_clean
WHERE is_default IS NOT NULL
GROUP BY utilization_bucket
ORDER BY utilization_bucket;
