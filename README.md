# Human Stampede Incidents Analysis using SQL

## Project Overview
This project analyzes historical human stampede incidents using PostgreSQL. The analysis focuses on incident distribution, recorded fatalities, country-level comparisons, and decade-wise patterns.

## Dataset Information
- **Dataset:** Human Stampedes
- **Records:** 183
- **Columns:** 7
- **Database:** PostgreSQL

### Dataset Columns
- Event ID
- Event Name
- Date
- Number of Deaths
- Country
- Place
- Description

## Data Preparation
- Checked the uniqueness of Event ID.
- Handled missing event names represented by `-`.
- Standardized mixed date formats using a separate DATE-typed column (`event_date`).
- Retained the original dataset columns.

## SQL Analysis

### Q1. Identifying Countries with Above-Average Stampede Fatalities
Identified countries whose average fatalities per incident exceeded the overall dataset average.

**SQL Concepts:** Scalar Subquery, CTE, GROUP BY, HAVING, Aggregate Functions.

### Q2. Ranking Stampede Incidents Within Each Country
Ranked incidents within each country based on recorded fatalities and identified the top three distinct fatality levels.

**SQL Concepts:** Window Functions (DENSE_RANK), PARTITION BY, CTE.

### Q3. Analyzing Stampede Incidents by Continent
Analyzed incident counts and fatalities across continents using a supplementary country-to-continent mapping table.

**SQL Concepts:** LEFT JOIN, COALESCE, GROUP BY, Aggregate Functions.

### Q4. Decade-wise Stampede Fatality Analysis
Analyzed incident counts and fatalities by decade, including incidents with at least 100 deaths and incidents with zero deaths.

**SQL Concepts:** Date Functions, EXTRACT, Conditional Aggregation, CASE WHEN, GROUP BY.

## Tools and Technologies
- PostgreSQL
- SQL

## Project Objective
To strengthen practical SQL skills by translating business requirements into analytical queries and deriving meaningful insights from historical incident data.

## Project Files
- `project_6_human_stampedes.sql` – SQL queries.
- `P6_Human_Stampedes_SQL_Documentation.txt` – Project documentation.