SELECT MAX(int_rate), MIN(int_rate) FROM accepted_loans_clean	
LIMIT 10;

--Default percentage by loan volume
SELECT
	FLOOR(loan_amnt / 5000) * 5000 AS loan_amount_range,
	ROUND(AVG(loan_amnt), 2),
	ROUND(AVG(is_default)*100, 2) AS default_percentage_by_volume
FROM accepted_loans_clean
GROUP BY FLOOR(loan_amnt / 5000)
ORDER BY loan_amount_range;

--interest rate vs default percentage 
SELECT
	CASE
		WHEN int_rate <= 7 THEN '5-7 %'
		WHEN int_rate <= 10 THEN '7-10 %'
		WHEN int_rate <= 15 THEN '10-15 %'
		WHEN int_rate <= 22 THEN '15-22 %'
		ELSE '22-31%'
	END AS int_rate_bracket,
	ROUND(AVG(int_rate), 2),
	ROUND(AVG(is_default)*100, 2) AS default_percentage_by_volume
FROM accepted_loans_clean
GROUP BY int_rate_bracket
ORDER BY MIN(int_rate);
