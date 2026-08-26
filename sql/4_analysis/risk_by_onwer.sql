SELECT * FROM accepted_loans_clean	
LIMIT 10;

--Default percentage by home ownership 
--Three options are excluded while they total number of entries was ~1500 out of 2.2M
SELECT 
	home_ownership,
	ROUND(AVG(is_default), 5)*100 AS default_percentage_by_home_ownership,
	COUNT(*)
FROM accepted_loans_clean
WHERE home_ownership != 'NONE' AND home_ownership != 'ANY' AND  home_ownership != 'OTHER' AND is_default IS NOT NULL
GROUP BY home_ownership
ORDER BY ROUND(AVG(is_default), 3);

--Default percentage by income veriffication status
SELECT 
	verification_status,
	ROUND(AVG(is_default), 5)*100 AS default_percentage_by_home_ownership,
	COUNT(*)
FROM accepted_loans_clean
WHERE is_default IS NOT NULL
GROUP BY verification_status
ORDER BY ROUND(AVG(is_default), 3);

--Further investigating default percentage and interest rate by income veriffication status and grade
SELECT
    verification_status,
    grade,
    COUNT(*) AS loans,
    ROUND(AVG(is_default) * 100, 2) AS default_rate,
	ROUND(AVG(int_rate), 2) AS int_rate
FROM accepted_loans_clean
WHERE is_default IS NOT NULL
GROUP BY verification_status, grade
ORDER BY verification_status, grade;

--Default percentage by employment years
SELECT 
	emp_length_years,
	ROUND(AVG(is_default), 5)*100 AS default_percentage_by_employment_years,
	COUNT(*)
FROM accepted_loans_clean
WHERE is_default IS NOT NULL
GROUP BY emp_length_years
ORDER BY ROUND(AVG(is_default), 3);

--Default percentage by grade and availability of employment history
SELECT
    CASE
        WHEN emp_length_years IS NULL THEN 'Missing'
        ELSE 'Known'
    END AS employment_info,
    grade,
    COUNT(*) AS loans,
    ROUND(AVG(is_default) * 100, 2) AS default_percentage
FROM accepted_loans_clean
WHERE is_default IS NOT NULL
GROUP BY employment_info, grade
ORDER BY employment_info, grade;

--DTI and annual inncome by the grade and expiraton status
SELECT
	CASE
		WHEN is_default = 1 THEN 'Defaulted / Charged off'
		WHEN is_default = 0 THEN 'Fully Paid'
	END AS end_status,
	grade,
	ROUND(AVG(dti)) AS avg_dti,
	ROUND(AVG(annual_inc)) AS avg_income
FROM accepted_loans_clean
WHERE is_default IS NOT NULL
GROUP BY end_status, grade
ORDER BY end_status, grade;


--default rate by fico group
WITH fico_groups AS (
    SELECT
        *,
        (fico_range_low + fico_range_high) / 2 AS fico_mid
    FROM accepted_loans_clean
    WHERE is_default IS NOT NULL
),
parts AS (
    SELECT
        *,
        NTILE(5) OVER (ORDER BY fico_mid) AS fico_group
    FROM fico_groups
)
SELECT
    fico_group,
	ROUND(AVG(fico_mid), 0) AS avg_fico,
    MIN(fico_mid) AS min_fico,
    MAX(fico_mid) AS max_fico,
    COUNT(*) AS loan_count,
    ROUND(AVG(is_default) * 100, 2) AS default_rate
FROM parts
GROUP BY fico_group
ORDER BY fico_group;

--Default rate by months since prior delinquencies
WITH delinq_recency AS (
    SELECT 
        *,
        NTILE(5) OVER (
            ORDER BY mths_since_last_delinq
        ) AS recency_group
    FROM accepted_loans_clean
    WHERE is_default IS NOT NULL AND mths_since_last_delinq IS NOT NULL
),
grouped AS (
    SELECT
        recency_group,
        MIN(mths_since_last_delinq) AS most_recent,
        MAX(mths_since_last_delinq) AS least_recent,
        COUNT(*) AS loan_count,
        ROUND(AVG(is_default) * 100, 2) AS default_rate
    FROM delinq_recency
    GROUP BY recency_group

    UNION ALL

    SELECT
        0 AS recency_group,
        NULL AS most_recent,
        NULL AS least_recent,
        COUNT(*) AS loan_count,
        ROUND(AVG(is_default) * 100, 2) AS default_rate
    FROM accepted_loans_clean
    WHERE is_default IS NOT NULL AND mths_since_last_delinq IS NULL
)
SELECT *
FROM grouped
ORDER BY recency_group;

--default rate by public records
SELECT
    CASE
		WHEN pub_rec = 0 THEN '0' 
		WHEN pub_rec = 1 THEN '1'
		WHEN pub_rec >= 2 THEN '2+'
		ELSE NULL
	END AS pub_rec_grouped,
    COUNT(*) AS loan_count,
    ROUND(AVG(is_default) * 100, 2) AS default_rate
FROM accepted_loans_clean
WHERE is_default IS NOT NULL
GROUP BY pub_rec_grouped
ORDER BY pub_rec_grouped;

--default rate by bankruptcies records
SELECT
	CASE
		WHEN pub_rec_bankruptcies = 0 THEN '0' 
		WHEN pub_rec_bankruptcies = 1 THEN '1'
		WHEN pub_rec_bankruptcies >= 2 THEN '2+'
		ELSE NULL
	END AS pub_rec_bankrup_grouped,
    COUNT(*) AS loan_count,
    ROUND(AVG(is_default) * 100, 2) AS default_rate
FROM accepted_loans_clean
WHERE is_default IS NOT NULL
GROUP BY pub_rec_bankrup_grouped
ORDER BY pub_rec_bankrup_grouped;

--default rate by percentage of non delinquent lines
SELECT
    CASE
        WHEN pct_tl_nvr_dlq = 100 THEN '100% (perfect)'
        WHEN pct_tl_nvr_dlq >= 90 THEN '90-99%'
        WHEN pct_tl_nvr_dlq >= 75 THEN '75-89%'
        WHEN pct_tl_nvr_dlq >= 50 THEN '50-74%'
		WHEN pct_tl_nvr_dlq < 50 THEN 'Below 50%'
		ELSE NULL	
    END AS never_delinquent_bucket,
    COUNT(*) AS loans,
    ROUND(AVG(is_default) * 100, 2) AS default_rate
FROM accepted_loans_clean
WHERE is_default IS NOT NULL
GROUP BY never_delinquent_bucket
ORDER BY MIN(pct_tl_nvr_dlq);

--Null fields for pct_tl_nvr_dlq by year
SELECT
    EXTRACT(YEAR FROM issue_date) AS issue_year,
    COUNT(*) AS total_loans,
    SUM(CASE WHEN pct_tl_nvr_dlq IS NULL THEN 1 ELSE 0 END) AS null_count,
    ROUND(100.0 * SUM(CASE WHEN pct_tl_nvr_dlq IS NULL THEN 1 ELSE 0 END) / COUNT(*), 2) AS null_pct
FROM accepted_loans_clean
WHERE is_default IS NOT NULL
GROUP BY issue_year
ORDER BY issue_year;

