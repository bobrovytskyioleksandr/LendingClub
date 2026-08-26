ALTER TABLE accepted_loans_clean
ADD COLUMN total_pymnt NUMERIC,
ADD COLUMN total_pymnt_inv NUMERIC,
ADD COLUMN total_rec_int NUMERIC,
ADD COLUMN total_rec_late_fee NUMERIC,
ADD COLUMN total_rec_prncp NUMERIC,
ADD COLUMN recoveries NUMERIC;

UPDATE accepted_loans_clean c
SET	
    total_pymnt = CAST(NULLIF(TRIM(a.total_pymnt), '') AS NUMERIC),
    total_pymnt_inv = CAST(NULLIF(TRIM(a.total_pymnt_inv), '') AS NUMERIC),
    total_rec_int = CAST(NULLIF(TRIM(a.total_rec_int), '') AS NUMERIC),
    total_rec_late_fee = CAST(NULLIF(TRIM(a.total_rec_late_fee), '') AS NUMERIC),
    total_rec_prncp = CAST(NULLIF(TRIM(a.total_rec_prncp), '') AS NUMERIC),
	recoveries = CAST(NULLIF(TRIM(a.recoveries), '') AS NUMERIC)
FROM accepted_loans_full a
WHERE c.id = a.id::BIGINT AND TRIM(a.id) ~ '^[0-9]+$';

ALTER TABLE accepted_loans_clean
ADD COLUMN collection_recoveery_fee NUMERIC;

UPDATE accepted_loans_clean c
SET	
    collection_recoveery_fee = CAST(NULLIF(TRIM(a.collection_recovery_fee), '') AS NUMERIC)
	
FROM accepted_loans_full a
WHERE c.id = a.id::BIGINT AND TRIM(a.id) ~ '^[0-9]+$';

ALTER TABLE accepted_loans_clean
RENAME COLUMN collection_recoveery_fee TO collection_recovery_fee;
