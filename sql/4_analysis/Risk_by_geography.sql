SELECT * FROM accepted_loans_clean	
LIMIT 10;

--Ranking of default rates by state including DC
SELECT 
	addr_state, 
	ROUND(AVG(is_default), 5) AS default_rate_by_state,
	RANK() OVER (
		ORDER BY AVG(is_default)
	) state_ranking
FROM accepted_loans_clean
GROUP BY addr_state;