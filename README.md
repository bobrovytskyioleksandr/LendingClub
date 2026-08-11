
# Lending Club Credit Risk Analysis

Credit risk & portfolio performance analysis on Lending Club's full
2007–2018 accepted-loans dataset, using PostgreSQL for
cleaning/analysis and [Power BI/Tableau] for the dashboard.

## Data

Source: [Kaggle — All Lending Club loan data](https://www.kaggle.com/datasets/wordsforthewise/lending-club) (not included in this repo — download `accepted_2007_to_2018Q4.csv`(first link) and
place it locally; see `sql/01_staging/` to load it) AND [Kaggle — Lending Club 2007-2020Q3(only Data Dictionary)](https://www.kaggle.com/datasets/ethon0426/lending-club-20072020q1) (included in a modified format with added classification by relevancy for this project)
.

## Project structure

I have separated the whole project into 5 steps, first 4 are centerd aroud work with PostgreSQL and the 5th step is done with (Power BI / Tableau).

### Step 1:Staging

Raw import of the dataset. All columns as TEXT to avoid issues on initial table creation.

### Step 2:Profiling

null-rate and column-usefulness analysis

### Step 3:Cleaning

type casts, derived fields, is_default column
column keep/drop decisions and reasoning

### Step 4:Analysis

the actual analysis queries

### Step 5:Visualization

interactive dashboard linked to the database

## Key findings

(woek in progress)

## Tools

PostgreSQL, (Power BI / Tableau)
