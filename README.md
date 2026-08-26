
# Lending Club Credit Risk Analysis

Credit risk & portfolio performance analysis on Lending Club’s full
2007–2018 accepted-loans dataset, using PostgreSQL for
cleaning/analysis and Power BI for the dashboard.

## Data

Source: [Kaggle — All Lending Club loan data](https://www.kaggle.com/datasets/wordsforthewise/lending-club) (not included in this repo — download `accepted_2007_to_2018Q4.csv`(first link) and
place it locally; see `sql/01_staging/` to load it) AND [Kaggle — Lending Club 2007-2020Q3( Only Data Dictionary )](https://www.kaggle.com/datasets/ethon0426/lending-club-20072020q1) (included in a modified format with added classification by relevancy for this project)
.

## Project structure

The project is separated into 5 stages; the first 4 are centered around work with PostgreSQL, and the 5th stage - visualization - is done with Power BI.

### Step 1:Staging

Creating a staging table using a Python script to import the raw data table. All columns have a universal TEXT data type to avoid most potential import issues.

### Step 2:Profiling

Firstly, using a SQL script, I have analysed which columns are non-NULL.
Secondly, I went through available columns and separated them by usefulness.

A more thorough explanation of the workflow and my choices is available in `docs/profiling_analysis.md`.

### Step 3:Cleaning

After choosing which columns to keep for further analysis, I had to create a new table containing them. While creating this table, I also parsed all columns to their most suitable data types and created the is_default column, which is a centerpiece of my analysis.

### Step 4:Analysis

There are a total of 9 different SQL scripts that are separating different queries by their respective categories. Most scripts are centered around analyzing risk, represented by the average default rate, and how it correlates with available risk factors and other loan characteristics. Nevertheless, there are also the general overview script and return on investment script. Later being a very important piece of my analysis and containing the most unexpected part regarding the overarching investment realities of the Lending Club.

### Step 5:Visualization

The visualization is done through the Power BI dashboards.

I decided not to import my main table containing the cleaned dataset, as it would be time-consuming working with it inside of Power BI, and in general it is unnecessary as I had already created practically all needed queries in PostgreSQL. So I have created the `sql/5_dashboard_views/views.sql` file containing views of the queries I wanted to visualize.

After importing all the data that I would need, the rest of the visualization process involved a lot of experimentation with different types of visuals and their combinations on the page.

For the purpose of outlining the most important information and keeping it concise, I have created a total of 4 dashboards.

#### 1st Page: Overview

On the first page, I decided to put the most general information regarding the dataset to illustrate the scale and give some rough idea of what the data is about. At the bottom of the page, three slicers allow the viewer to filter the data by year, grade, or purpose.

![alt text](docs/Dashboard_overview.png)

#### 2nd Page: Risk part 1

This is the opening risk page, so the charts, especially the first one, are really straightforward. Default rate and interest rate development grouped by grade, probably the simplest way to illustrate the estimated risk, and a simple way to hint at the underlying structure of this dataset.

![alt text](docs/Dashboard_risk1.png)

#### 3rd Page: Risk part 2

On this page, I have done a lot of experimentation with available visuals to add some variety to the dashboard and make it more visually appealing. Making some of those panels work required me to create additional relations between some imported views, as they were not automatically identified by Power BI.

![alt text](docs/Dashboard_risk2.png)

#### 4th Page: Return on Investment

This is the visualization of my most important findings within this project. I write about it in more detail in `docs/findings.md`. In short, the return on investment for those loans is massively underwhelming. The lowest three grades outright lose money before even adjusting for capital cost, and the higher four grades don't earn enough to even cover inflation.

![alt text](docs/Dashboard_ROI.png)

## Key findings

My two key findings are:

- Shockingly high default rates
- Unexpectedly low return on investment for the lenders.

More about them and other findings is written in `docs/findings.md`.

## Tools

- PostgreSQL
- Power BI
- Python