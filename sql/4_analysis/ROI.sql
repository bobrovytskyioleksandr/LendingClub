--return by grade
SELECT
    grade,
    ROUND(AVG(funded_amnt), 2) AS avg_funded,
    ROUND(AVG(total_pymnt), 2) AS avg_total_payment,
    ROUND(AVG(recoveries), 2) AS avg_recoveries,
    ROUND(AVG(total_pymnt / NULLIF(funded_amnt, 0)) * 100, 2)
        AS avg_cash_recovery_pct
FROM accepted_loans_clean
WHERE is_default = 1 OR is_default = 0
GROUP BY grade
ORDER BY grade;

--Confirming total_pymnt composition
SELECT
    ROUND(AVG(total_pymnt), 2) AS avg_total_pymnt,
    ROUND(AVG(
        total_rec_prncp
        + total_rec_int
        + total_rec_late_fee
        + recoveries
    ), 2) AS avg_reconstructed_payment
FROM accepted_loans_clean
WHERE grade = 'G'
  AND is_default IN (1, 0);

--Eploration of return sources and profit/loss
SELECT
    grade,
    COUNT(*) AS loans,
    ROUND(AVG(funded_amnt), 2) AS avg_funded,
	ROUND(AVG(funded_amnt_inv), 2) AS avg_funded_inv,
    ROUND(AVG(total_rec_prncp), 2) AS avg_principal_received,
    ROUND(AVG(total_rec_int), 2) AS avg_interest_received,
    ROUND(AVG(total_rec_late_fee), 2) AS avg_late_fees,
    ROUND(AVG(recoveries), 2) AS avg_recoveries,
	ROUND(AVG(collection_recovery_fee), 2) AS avg_collection_fee,
    ROUND(AVG(total_pymnt), 2) AS avg_total_payment_gross,
    ROUND(AVG(total_pymnt - collection_recovery_fee), 2) AS avg_total_payment_net,
    ROUND(AVG((total_pymnt - collection_recovery_fee) / NULLIF(funded_amnt, 0)) * 100, 2)
        AS avg_net_cash_recovery_pct
FROM accepted_loans_clean
WHERE is_default IN (0, 1)
GROUP BY grade
ORDER BY grade;

--Total funded and total recieved for expired loans
SELECT
    ROUND(SUM(funded_amnt), 2) AS avg_funded,
    ROUND(SUM(total_pymnt - collection_recovery_fee), 2) AS avg_total_payment_net
FROM accepted_loans_clean
WHERE is_default IN (0, 1);