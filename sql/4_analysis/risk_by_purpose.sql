SELECT * FROM accepted_loans_clean	
LIMIT 10;

--Default percentage by loan purpose
SELECT purpose, ROUND(AVG(is_default), 5)*100 AS default_percentage_by_purpose, COUNT(*) AS loan_cnt
FROM accepted_loans_clean
GROUP BY purpose
ORDER BY AVG(is_default);

--Total funded volume by purpose
SELECT purpose, SUM(funded_amnt) AS volune_by_purpose
FROM accepted_loans_clean
GROUP BY purpose
ORDER BY SUM(funded_amnt);

--Average requested amount by purpose
SELECT purpose, ROUND(AVG(loan_amnt), 2) AS avg_amount_by_purpose
FROM accepted_loans_clean
GROUP BY purpose
ORDER BY AVG(funded_amnt);
