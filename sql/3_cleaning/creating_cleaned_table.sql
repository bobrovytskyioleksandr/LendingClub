DROP TABLE IF EXISTS accepted_loans_clean;

CREATE TABLE accepted_loans_clean AS
SELECT
    CAST(NULLIF(TRIM(id), '') AS NUMERIC)::BIGINT                                AS id,

    CAST(NULLIF(TRIM(loan_amnt), '') AS NUMERIC)                        AS loan_amnt,
    CAST(NULLIF(TRIM(funded_amnt), '') AS NUMERIC)                      AS funded_amnt,
    CAST(NULLIF(TRIM(funded_amnt_inv), '') AS NUMERIC)                  AS funded_amnt_inv,
    CAST(SUBSTRING(TRIM(term) FROM '\d+') AS NUMERIC)::INTEGER                   AS term_months,
    CAST(REPLACE(TRIM(int_rate), '%', '') AS NUMERIC)                   AS int_rate,
    CAST(NULLIF(TRIM(installment), '') AS NUMERIC)                      AS installment,
    TRIM(grade)                                                         AS grade,
    TRIM(sub_grade)                                                     AS sub_grade,

	CASE
        WHEN TRIM(emp_length) = '10+ years' THEN 10
        WHEN TRIM(emp_length) = '< 1 year' THEN 0
        WHEN emp_length IS NULL OR TRIM(emp_length) = '' THEN NULL
        ELSE CAST(SUBSTRING(TRIM(emp_length) FROM '\d+') AS NUMERIC)::INTEGER
    END                                                                  AS emp_length_years,

    TRIM(home_ownership)                                                AS home_ownership,
    CAST(NULLIF(TRIM(annual_inc), '') AS NUMERIC)                       AS annual_inc,
    TRIM(verification_status)                                           AS verification_status,
    TO_DATE(TRIM(issue_d), 'Mon-YYYY')                                  AS issue_date,
    TRIM(loan_status)                                                   AS loan_status,

    CASE
        WHEN TRIM(loan_status) IN ('Charged Off', 'Default') THEN 1
        WHEN TRIM(loan_status) = 'Fully Paid' THEN 0
        ELSE NULL 
    END                                                                  AS is_default,

    TRIM(purpose)                                                       AS purpose,
    TRIM(title)                                                         AS title,
    TRIM(zip_code)                                                      AS zip_code,   
    TRIM(addr_state)                                                    AS addr_state,
    CAST(NULLIF(TRIM(dti), '') AS NUMERIC)                              AS dti,

    CAST(NULLIF(TRIM(delinq_2yrs), '') AS NUMERIC)::INTEGER                      AS delinq_2yrs,
    CAST(NULLIF(TRIM(fico_range_low), '') AS NUMERIC)::INTEGER                   AS fico_range_low,
    CAST(NULLIF(TRIM(fico_range_high), '') AS NUMERIC)::INTEGER                  AS fico_range_high,
    CAST(NULLIF(TRIM(inq_last_6mths), '') AS NUMERIC)::INTEGER                   AS inq_last_6mths,
    CAST(NULLIF(TRIM(mths_since_last_delinq), '') AS NUMERIC)::INTEGER           AS mths_since_last_delinq,
    CAST(NULLIF(TRIM(open_acc), '') AS NUMERIC)::INTEGER                         AS open_acc,
    CAST(NULLIF(TRIM(pub_rec), '') AS NUMERIC)::INTEGER                          AS pub_rec,
    CAST(NULLIF(TRIM(revol_bal), '') AS NUMERIC)                        AS revol_bal,
    CAST(NULLIF(REPLACE(TRIM(revol_util), '%', ''), '') AS NUMERIC)     AS revol_util,
    CAST(NULLIF(TRIM(total_acc), '') AS NUMERIC)::INTEGER                        AS total_acc,
    TRIM(application_type)                                              AS application_type,
    CAST(NULLIF(TRIM(acc_now_delinq), '') AS NUMERIC)::INTEGER                   AS acc_now_delinq,
    CAST(NULLIF(TRIM(tot_coll_amt), '') AS NUMERIC)                     AS tot_coll_amt,
    CAST(NULLIF(TRIM(tot_cur_bal), '') AS NUMERIC)                      AS tot_cur_bal,
    CAST(NULLIF(TRIM(chargeoff_within_12_mths), '') AS NUMERIC)::INTEGER         AS chargeoff_within_12_mths,
    CAST(NULLIF(TRIM(delinq_amnt), '') AS NUMERIC)                      AS delinq_amnt,
    CAST(NULLIF(TRIM(pub_rec_bankruptcies), '') AS NUMERIC)::INTEGER             AS pub_rec_bankruptcies,
    TRIM(disbursement_method)                                           AS disbursement_method,
    CAST(NULLIF(TRIM(avg_cur_bal), '') AS NUMERIC)                      AS avg_cur_bal,
    CAST(NULLIF(TRIM(bc_open_to_buy), '') AS NUMERIC)                   AS bc_open_to_buy,
    CAST(NULLIF(TRIM(bc_util), '') AS NUMERIC)                          AS bc_util,
    CAST(NULLIF(TRIM(collections_12_mths_ex_med), '') AS NUMERIC)::INTEGER       AS collections_12_mths_ex_med,
    CAST(NULLIF(TRIM(mort_acc), '') AS NUMERIC)::INTEGER                         AS mort_acc,
    CAST(NULLIF(TRIM(num_accts_ever_120_pd), '') AS NUMERIC)::INTEGER            AS num_accts_ever_120_pd,
    CAST(NULLIF(TRIM(num_sats), '') AS NUMERIC)::INTEGER                         AS num_sats,
    CAST(NULLIF(TRIM(pct_tl_nvr_dlq), '') AS NUMERIC)                   AS pct_tl_nvr_dlq,
    CAST(NULLIF(TRIM(percent_bc_gt_75), '') AS NUMERIC)                 AS percent_bc_gt_75,
    CAST(NULLIF(TRIM(total_bal_ex_mort), '') AS NUMERIC)                AS total_bal_ex_mort,
    CAST(NULLIF(TRIM(total_bc_limit), '') AS NUMERIC)                   AS total_bc_limit,
    CAST(NULLIF(TRIM(total_rev_hi_lim), '') AS NUMERIC)                 AS total_rev_hi_lim

FROM accepted_loans_full
WHERE TRIM(id) ~ '^[0-9]+$';

--Removing summary lines
SELECT id
FROM accepted_loans_full
WHERE TRIM(id) !~ '^[0-9]+$';

-- Quick check
SELECT COUNT(*) FROM accepted_loans_clean;
SELECT * FROM accepted_loans_clean 
ORDER BY issue_date
LIMIT 10;

-- Confirm the derived label distribution looks sane
SELECT is_default, COUNT(*) FROM accepted_loans_clean GROUP BY is_default;

--The is_default column is dependent on loan_status and was broken due to unusual record format 
SELECT DISTINCT loan_status
FROM accepted_loans_clean
WHERE loan_status LIKE 'Does not meet%';
--Updating the is_default column
UPDATE accepted_loans_clean
SET is_default = CASE
    WHEN loan_status = 'Does not meet the credit policy. Status:Charged Off' THEN 1
    WHEN loan_status = 'Does not meet the credit policy. Status:Fully Paid' THEN 0
    ELSE is_default
END
WHERE loan_status LIKE 'Does not meet the credit policy%';

--Creating the most relevant indexes
CREATE INDEX idx_accepted_loans_clean_grade ON accepted_loans_clean (grade);
CREATE INDEX idx_accepted_loans_clean_state ON accepted_loans_clean (addr_state);
CREATE INDEX idx_accepted_loans_clean_issue_date ON accepted_loans_clean (issue_date);
CREATE INDEX idx_accepted_loans_clean_purpose ON accepted_loans_clean (purpose);
CREATE INDEX idx_accepted_loans_clean_sub_grade ON accepted_loans_clean (sub_grade);
CREATE INDEX idx_accepted_loans_clean_is_default ON accepted_loans_clean (is_default) WHERE is_default IS NOT NULL;