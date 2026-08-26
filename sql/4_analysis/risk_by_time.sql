SELECT * FROM accepted_loans_clean	
LIMIT 10;

--default rate by years
SELECT
    EXTRACT(YEAR FROM issue_date) AS issue_year,
    COUNT(*) AS total_loans,
	ROUND(AVG(is_default) * 100, 2) AS default_rate
FROM accepted_loans_clean
WHERE is_default IS NOT NULL
GROUP BY issue_year
ORDER BY issue_year;

--comparison of default rates for all loans that have ended vs loans term for which has expired  
WITH all_by_grade AS(
		SELECT
    	grade,
    	COUNT(*) AS matured_loans_all,
    	ROUND(AVG(is_default) * 100, 2) AS default_rate_all
	FROM accepted_loans_clean
	WHERE is_default IS NOT NULL
	GROUP BY grade
)
SELECT
    a.grade,
    COUNT(*) AS matured_loans,
    ROUND(AVG(a.is_default) * 100, 2) AS default_rate,
	g.matured_loans_all,
	g.default_rate_all,
	ROUND(AVG(a.is_default)/g.default_rate_all*100, 3) AS finished_to_all_ratio
FROM accepted_loans_clean a
JOIN all_by_grade g
	ON a.grade = g.grade
WHERE a.is_default IS NOT NULL
  AND a.issue_date + (a.term_months * INTERVAL '1 month') <= (SELECT MAX(a.issue_date) FROM accepted_loans_clean a)
GROUP BY 
	a.grade,
	g.matured_loans_all,
	g.default_rate_all
ORDER BY a.grade;

--monthly volume trends
WITH monthly_volume AS (
    SELECT
        DATE_TRUNC('month', issue_date) AS month,
        COUNT(*) AS loan_count
    FROM accepted_loans_clean
    GROUP BY 1
)
SELECT
    month::DATE,
    loan_count,
    LAG(loan_count) OVER (ORDER BY month) AS prev_month_count,
    loan_count - LAG(loan_count) OVER (ORDER BY month) AS MoM_change,
	ROUND(
		(loan_count - LAG(loan_count) OVER (ORDER BY month))*100 / NULLIF(LAG(loan_count) OVER (ORDER BY month), 0), 2
	) AS MoM_percent_change
FROM monthly_volume
ORDER BY month;
