

--PAGE 1

CREATE VIEW vw_loan_summary AS
SELECT
    id,
    grade,
    purpose,
    EXTRACT(YEAR FROM issue_date) AS issue_year,
    issue_date,
    funded_amnt,
    int_rate,
    is_default
FROM accepted_loans_clean;

CREATE VIEW vw_monthly_issuance_trend AS
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
    loan_count - LAG(loan_count) OVER (ORDER BY month) AS mom_change,
    ROUND(
        (loan_count - LAG(loan_count) OVER (ORDER BY month)) * 100.0
        / NULLIF(LAG(loan_count) OVER (ORDER BY month), 0), 2
    ) AS mom_pct_change
FROM monthly_volume
ORDER BY month;

CREATE VIEW vw_quarterly_int_rate_trend AS
SELECT
	EXTRACT(YEAR FROM issue_date) AS year,
	EXTRACT(QUARTER FROM issue_date) AS quarter,
	COUNT(*) AS volume,
	ROUND(AVG(int_rate), 2) AS int_rate
FROM accepted_loans_clean
GROUP BY year, quarter 
ORDER BY year, quarter;

CREATE VIEW vw_total_amount_requested AS
SELECT 
	SUM(loan_amnt) AS total_requested
FROM accepted_loans_clean;

CREATE VIEW vw_total_amount_funded AS
SELECT 
	SUM(funded_amnt) AS total_funded
FROM accepted_loans_clean;

CREATE VIEW vw_overall_default_rate AS
SELECT ROUND(AVG(is_default)*100, 3) AS overall_default_percentage
FROM accepted_loans_clean;

CREATE VIEW vw_overall_int_rate AS
SELECT ROUND(AVG(int_rate), 2) AS overall_default_percentage
FROM accepted_loans_clean;



--PAGE 2

CREATE VIEW vw_grade_summary AS
SELECT
    grade,
    COUNT(*) AS loans,
    ROUND(AVG(is_default) * 100, 2) AS default_rate,
    ROUND(AVG(int_rate), 2) AS avg_interest_rate
FROM accepted_loans_clean
WHERE is_default IS NOT NULL
GROUP BY grade
ORDER BY grade;

CREATE VIEW vw_default_rate_by_state AS
SELECT
    addr_state,
    COUNT(*) AS loans,
    ROUND(AVG(is_default) * 100, 2) AS default_rate,
    RANK() OVER (ORDER BY AVG(is_default)) AS state_ranking
FROM accepted_loans_clean
WHERE is_default IS NOT NULL
GROUP BY addr_state;

CREATE OR REPLACE VIEW vw_default_rate_by_fico_group AS
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
    MIN(fico_mid) AS min_fico,
    MAX(fico_mid) AS max_fico,
    COUNT(*) AS loan_count,
    ROUND(AVG(is_default) * 100, 2) AS default_rate,
	ROUND(AVG(fico_mid), 0) AS avg_fico
FROM parts
GROUP BY fico_group
ORDER BY fico_group;

CREATE VIEW vw_default_rate_by_interest_bracket AS
SELECT
    CASE
        WHEN int_rate <= 7 THEN '5-7%'
        WHEN int_rate <= 10 THEN '7-10%'
        WHEN int_rate <= 15 THEN '10-15%'
        WHEN int_rate <= 22 THEN '15-22%'
        ELSE '22-31%'
    END AS int_rate_bracket,
    COUNT(*) AS loans,
    ROUND(AVG(int_rate), 2) AS avg_interest_rate,
    ROUND(AVG(is_default) * 100, 2) AS default_rate
FROM accepted_loans_clean
WHERE is_default IS NOT NULL
GROUP BY int_rate_bracket
ORDER BY MIN(int_rate);

CREATE VIEW vw_purpose_summary AS
SELECT
    purpose,
    COUNT(*) AS loans,
    ROUND(AVG(is_default) * 100, 2) AS default_rate,
    SUM(funded_amnt) AS total_funded,
    ROUND(AVG(loan_amnt), 2) AS avg_loan_amount
FROM accepted_loans_clean
WHERE is_default IS NOT NULL
GROUP BY purpose
ORDER BY default_rate;

CREATE VIEW vw_default_rate_by_home_ownership AS
SELECT
    home_ownership,
    COUNT(*) AS loans,
    ROUND(AVG(is_default) * 100, 2) AS default_rate
FROM accepted_loans_clean
WHERE home_ownership NOT IN ('NONE', 'ANY', 'OTHER')
  AND is_default IS NOT NULL
GROUP BY home_ownership
ORDER BY default_rate;

CREATE VIEW vw_default_rate_by_revol_util AS
SELECT
    CASE
        WHEN revol_util < 20 THEN '0-20%'
        WHEN revol_util < 40 THEN '20-40%'
        WHEN revol_util < 60 THEN '40-60%'
        WHEN revol_util < 80 THEN '60-80%'
        ELSE '80%+'
    END AS utilization_bucket,
    COUNT(*) AS loans,
    ROUND(AVG(is_default) * 100, 2) AS default_rate
FROM accepted_loans_clean
WHERE is_default IS NOT NULL
GROUP BY utilization_bucket
ORDER BY MIN(revol_util);

CREATE VIEW vw_verification_status_by_grade AS
SELECT
    verification_status,
    grade,
    COUNT(*) AS loans,
    ROUND(AVG(is_default) * 100, 2) AS default_rate,
    ROUND(AVG(int_rate), 2) AS avg_interest_rate
FROM accepted_loans_clean
WHERE is_default IS NOT NULL
GROUP BY verification_status, grade
ORDER BY verification_status, grade;

CREATE VIEW vw_default_rate_by_pub_rec AS
SELECT
    CASE
        WHEN pub_rec = 0 THEN '0'
        WHEN pub_rec = 1 THEN '1'
        WHEN pub_rec >= 2 THEN '2+'
    END AS pub_rec_grouped,
    COUNT(*) AS loans,
    ROUND(AVG(is_default) * 100, 2) AS default_rate
FROM accepted_loans_clean
WHERE is_default IS NOT NULL
GROUP BY pub_rec_grouped
ORDER BY pub_rec_grouped;

CREATE VIEW vw_default_rate_by_bankruptcies AS
SELECT
    CASE
        WHEN pub_rec_bankruptcies = 0 THEN '0'
        WHEN pub_rec_bankruptcies = 1 THEN '1'
        WHEN pub_rec_bankruptcies >= 2 THEN '2+'
    END AS bankruptcies_grouped,
    COUNT(*) AS loans,
    ROUND(AVG(is_default) * 100, 2) AS default_rate
FROM accepted_loans_clean
WHERE is_default IS NOT NULL
GROUP BY bankruptcies_grouped
ORDER BY bankruptcies_grouped;

CREATE VIEW vw_default_rate_by_never_delinquent AS
SELECT
    CASE
        WHEN pct_tl_nvr_dlq = 100 THEN '100% (perfect)'
        WHEN pct_tl_nvr_dlq >= 90 THEN '90-99%'
        WHEN pct_tl_nvr_dlq >= 75 THEN '75-89%'
        WHEN pct_tl_nvr_dlq >= 50 THEN '50-74%'
        WHEN pct_tl_nvr_dlq < 50 THEN 'Below 50%'
        ELSE 'Unknown/Missing'
    END AS never_delinquent_bucket,
    COUNT(*) AS loans,
    ROUND(AVG(is_default) * 100, 2) AS default_rate
FROM accepted_loans_clean
WHERE is_default IS NOT NULL
GROUP BY never_delinquent_bucket
ORDER BY MIN(COALESCE(pct_tl_nvr_dlq, -1));

CREATE VIEW vw_risk_factor_small_multiples AS
SELECT
    'Public Records' AS risk_factor,
    pub_rec_grouped AS bucket_label,
    loans,
    default_rate,
    CASE pub_rec_grouped WHEN '0' THEN 1 WHEN '1' THEN 2 ELSE 3 END AS sort_order
FROM vw_default_rate_by_pub_rec
UNION ALL
SELECT
    'Bankruptcies' AS risk_factor,
    bankruptcies_grouped AS bucket_label,
    loans,
    default_rate,
    CASE bankruptcies_grouped WHEN '0' THEN 1 WHEN '1' THEN 2 ELSE 3 END AS sort_order
FROM vw_default_rate_by_bankruptcies
UNION ALL
SELECT
    'Never Delinquent %' AS risk_factor,
    never_delinquent_bucket AS bucket_label,
    loans,
    default_rate,
    CASE never_delinquent_bucket
        WHEN 'Below 50%' THEN 1
        WHEN '50-74%' THEN 2
        WHEN '75-89%' THEN 3
        WHEN '90-99%' THEN 4
        WHEN '100% (perfect)' THEN 5
        ELSE 6
    END AS sort_order
FROM vw_default_rate_by_never_delinquent;



--PAGE 3

CREATE OR REPLACE VIEW vw_roi_by_grade AS
SELECT
    grade,
    COUNT(*) AS loans,
    ROUND(AVG(funded_amnt), 2) AS avg_funded,
    ROUND(AVG(total_rec_prncp), 2) AS avg_principal_received,
    ROUND(AVG(total_rec_int), 2) AS avg_interest_received,
    ROUND(AVG(total_rec_late_fee), 2) AS avg_late_fees,
    ROUND(AVG(recoveries), 2) AS avg_recoveries,
    ROUND(AVG(collection_recovery_fee), 2) AS avg_collection_fee,
    ROUND(AVG(total_pymnt - collection_recovery_fee), 2) AS avg_total_payment_net,
    ROUND(AVG((total_pymnt - collection_recovery_fee) / NULLIF(funded_amnt, 0)) * 100, 2)
        AS avg_net_cash_recovery_pct,
	 ROUND(SUM(total_pymnt - COALESCE(collection_recovery_fee, 0)), 2)
        AS total_payment_net,
	ROUND(SUM(funded_amnt), 2) AS total_funded
FROM accepted_loans_clean
WHERE is_default IN (0, 1)
GROUP BY grade
ORDER BY grade;

--PAGE 4

CREATE VIEW vw_default_rate_matured_vs_all_by_grade AS
WITH all_by_grade AS (
    SELECT
        grade,
        COUNT(*) AS loans_all,
        ROUND(AVG(is_default) * 100, 2) AS default_rate_all
    FROM accepted_loans_clean
    WHERE is_default IS NOT NULL
    GROUP BY grade
)
SELECT
    a.grade,
    COUNT(*) AS matured_loans,
    ROUND(AVG(a.is_default) * 100, 2) AS default_rate_matured,
    g.loans_all,
    g.default_rate_all
FROM accepted_loans_clean a
JOIN all_by_grade g ON a.grade = g.grade
WHERE a.is_default IS NOT NULL
  AND a.issue_date + (a.term_months * INTERVAL '1 month')
      <= (SELECT MAX(issue_date) FROM accepted_loans_clean)
GROUP BY a.grade, g.loans_all, g.default_rate_all
ORDER BY a.grade;