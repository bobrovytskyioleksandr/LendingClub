--Quick overview
SELECT * FROM accepted_loans_clean
LIMIT 10;

--Default rate by grade
SELECT grade, ROUND(AVG(is_default), 5)*100 AS default_percentage_by_grade
FROM accepted_loans_clean
GROUP BY grade
ORDER BY grade;

--Default rate by sub-grade
SELECT sub_grade, ROUND(AVG(is_default), 5)*100 AS default_percentage_by_subgrade
FROM accepted_loans_clean
GROUP BY sub_grade
ORDER BY sub_grade;


--Average interest rate by grade
SELECT grade, ROUND(AVG(int_rate), 5) AS avg_interest_rate_by_grade
FROM accepted_loans_clean
GROUP BY grade
ORDER BY grade;

--Average interest rate by sub-grade
SELECT sub_grade, ROUND(AVG(int_rate), 5) AS avg_interest_rate_by_subgrade
FROM accepted_loans_clean
GROUP BY sub_grade
ORDER BY sub_grade;