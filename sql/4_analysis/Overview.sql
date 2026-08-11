--Quick overview
SELECT * FROM accepted_loans_clean
LIMIT 10;

--Total requested by borrowers
SELECT SUM(loan_amnt) AS total_requested
FROM accepted_loans_clean;

--Total funded by Lending Club + Investors
SELECT SUM(funded_amnt) AS total_funded
FROM accepted_loans_clean;

--Funded to reuested amount percentage
SELECT ROUND(AVG(funded_amnt)/AVG(loan_amnt), 5)*100 AS req_to_funded_percentage
FROM accepted_loans_clean;

--Funded by investors to total funded amount
SELECT ROUND(SUM(funded_amnt_inv)/SUM(funded_amnt), 5)*100 AS inv_to_total_percentage
FROM accepted_loans_clean;

--Overall default rate of all loans that have expired(Fully paid/Delinquent/Charged off) 
SELECT ROUND(AVG(is_default), 5)*100 AS overall_default_percentage
FROM accepted_loans_clean;

--Total loan volume and amount requested by year
SELECT
	EXTRACT(YEAR FROM issue_date) AS year,
	COUNT(*) AS volume,
	SUM(loan_amnt) AS amount
FROM accepted_loans_clean
GROUP BY year 
ORDER BY year;

--Total loan volume and amount requested by year
SELECT
	EXTRACT(YEAR FROM issue_date) AS year,
	EXTRACT(QUARTER FROM issue_date) AS quarter,
	COUNT(*) AS volume,
	ROUND(AVG(int_rate), 2)
FROM accepted_loans_clean
GROUP BY year, quarter 
ORDER BY year, quarter;



