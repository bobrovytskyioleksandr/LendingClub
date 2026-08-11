# Profiling Notes

Column decisions and the profiling work behind them, from Step 2
(`sql/02_profiling/profile_null_counts.sql`). LCDataDicitonary.xlsx is the main reference, below are the profiling details as supporting context.

## Overview

- Table profiled: `accepted_loans_full`
- Total rows: ~2.25M
- Total columns: 151

## Column Decisions

Mostly-null (90+%) columns are the first drop candidates.

| Column | Null % | Distinct Values | Decision | Notes |
|---|---|---|---|---|
| loan_amnt | 0% | ~1,500 | Keep | Core numeric field, needs CAST to NUMERIC |
| loan_desc | ~95% | — | Drop | Free text, mostly unpopulated. Although it is quite interesting when there is an actual recoed in this collumn most of them just mirror the "purpose" column which is much more strucutred |
| hardship_type and by extension all hardship columns | ~99.6% | — | Drop | Only populated for loans in active hardship plans |
| emp_length | ~5% | 11 | Keep, needs cleaning | Values like "10+ years" / "< 1 year" need parsing to numeric |
| | | | | |

Overall, as there is 151 collumns in total and 51 of them that I have decided to keep, it would be quite time consuming explaining the reasoning behind each one.

I decided to keep columns that seemed useful in my planned analysis and were not mostly null. It does not mean that I will use all of them in the analysis stage.

On the other hand there were columns that seemed mildly interesting at the moment, and they might be added to the cleaned table in the future if I find it necessary.

Most of the collumns were dropped either due to being useless because of scarcity of records, or due to being irrelevant to the analysis as I have planned it. Although if I find any of them to be potentially useful in a certain task, I am always able to add them to the clean table.

## Data quality issues found

Things discovered during profiling/import that affected how columns were
handled — not column-specific decisions, just "gotchas" worth remembering.

- **Footer/junk rows** — raw CSV has a couple of summary lines at the end
  (`id` = "Total amount funded in policy code..."), excluded via
  `WHERE TRIM(id) ~ '^[0-9]+$'` in the cleaning step.
- **Encoding** — raw file has stray bytes invalid in UTF8;
  imported using `ENCODING 'LATIN1'`.
- **`loan_status` extra variants** — "Does not meet the credit policy.
  Status: 'status'" values, folded into `is_default` alongside their base status.
- **`emp_length` formatting** — non-numeric strings ("10+ years",
  "< 1 year") required parsing, not a direct cast.
- **`term`** — stored as text ("36 months"), needs digit extraction.
- Luckily original author of the dataset cleaned up the data a tiny bit removing `%` sign from **`int_rate` / `revol_util`**.

## Column-by-column review

Some columns required more a detailed glance at them to determine if they are useful and how they will be casted into the cleaned table.

### purpose

- Distinct values: 14
- Sample values: "car", "house", "credit card", ...
- Decision: keep, had to evaluate if the values are uniform enough to be used in the analysis

### loan_status

- Distinct values: 9
- Includes: Fully Paid, Charged Off, Current, Late (...), "Does not meet
  the credit policy" variants
- Decision: derive is_default flag for the future analysis work

### emp_length

- Distinct values: 11
- Sample values: "10+ years", "< 1 year", "3 years", ...
- Decision: keep, parse to numeric years
