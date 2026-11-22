/*
Q1. Identifying Countries with Above-Average Stampede Fatalities

Business requirement:
Identify countries whose average number of deaths per stampede incident is greater than the overall average number of deaths per incident across the entire dataset.

For each qualifying country, calculate its incident count, total fatalities, and average fatalities per incident.
Expected output columns:
- country
- total_incidents
- total_deaths
- average_deaths
Mandatory SQL concepts:
- Subquery (use a subquery to calculate the overall average fatalities)
- GROUP BY
- HAVING
- Aggregate functions (COUNT, SUM, AVG)
- ORDER BY
Additional requirements:
1. Exclude records where the country is NULL or blank.
2. Consider only countries with at least two recorded incidents.
3. Display only countries whose average fatalities exceed the overall dataset average.
4. Sort by average_deaths in descending order.
*/

WITH insigh_summary_calc AS (
    SELECT
        tab."Country" AS country,
        COUNT(tab."Event ID") AS total_incidents,
        SUM(tab."Number of Deaths") AS total_deaths,
        ROUND(AVG(tab."Number of Deaths"), 2) AS average_deaths
    FROM project_6_human_stampedes AS tab
    WHERE tab."Country" IS NOT NULL
    GROUP BY tab."Country"
    HAVING AVG(tab."Number of Deaths") > (
        SELECT 
            AVG("Number of Deaths") 
        FROM project_6_human_stampedes
        ) AND COUNT(tab."Event ID") >= 2
)

SELECT 
    country,
    total_incidents,
    total_deaths,
    average_deaths
FROM insigh_summary_calc
ORDER BY average_deaths DESC;

/*
Q2. Ranking Stampede Incidents Within Each Country
Business requirement:

For each country, identify the three most severe stampede incidents based on the number of deaths.
Assign a rank to each incident within its country. Include incidents belonging to the top three distinct fatality levels, retaining ties.

Expected output columns:
- country
- event_id
- event_name
- date
- number_of_deaths
- death_rank
Mandatory SQL concepts:
- Window function (DENSE_RANK())
- PARTITION BY
- ORDER BY
- CTE or subquery to filter the calculated rank
Additional requirements:
1. Exclude records with NULL or blank country values.
2. Exclude records with NULL fatality values.
3. Rank incidents separately within each country.
4. Include only ranks 1, 2, and 3.
5. Sort by country and death rank.
*/

WITH death_rank_calc AS (
    SELECT
        tab."Country" AS country,
        tab."Event ID" AS event_id,
        -- tab."Event Name" AS event_name,
        CASE
            WHEN tab."Event Name" = '-' THEN 'Unknown'
            ELSE tab."Event Name"
        END AS event_name,
        tab."Date" AS "date", 
        tab."Number of Deaths" AS number_of_deaths,
        DENSE_RANK() OVER (
            PARTITION BY tab."Country"
            ORDER BY tab."Number of Deaths" DESC
        ) AS death_rank
    FROM project_6_human_stampedes AS tab
    WHERE tab."Country" IS NOT NULL AND tab."Number of Deaths" IS NOT NULL
)

SELECT 
    country,
    event_id,
    event_name,
    "date",
    number_of_deaths,
    death_rank
FROM death_rank_calc
WHERE death_rank <= 3
ORDER BY country, death_rank

/*
Q3. Analyzing Stampede Incidents by Continent

Business requirement:
Analyze the number of recorded stampede incidents and total fatalities across different continents.
Use a supplementary mapping table to associate each country in the main dataset with its respective continent.

Step 1: Create the supplementary table
Table name: country_region_mapping - country, continent 

Insert the following sample records:
INSERT INTO country_region_mapping
VALUES
'India', 'Asia',
'China', 'Asia',
'Japan', 'Asia',
'Bangladesh', 'Asia',
'Germany', 'Europe',
'France', 'Europe',
'United Kingdom', 'Europe',
'Portugal', 'Europe',
'United States', 'North America',
'Mexico', 'North America',
'Brazil', 'South America',
'Argentina', 'South America',
'South Africa', 'Africa',
'Nigeria', 'Africa'


Step 2: Write the SQL query
Calculate the following for each continent:
Expected output columns:
- continent
- total_incidents
- total_deaths
- average_deaths
Mandatory SQL concepts:
- LEFT JOIN
- GROUP BY
- COUNT
- SUM
- AVG
- COALESCE
- ORDER BY

Additional requirements:
1. Retain all incidents from the main dataset, including countries not present in the mapping table.
2. Classify countries without a matching continent as Unmapped.
3. Exclude records where the country is NULL or blank.
4. Sort by total fatalities in descending order.
*/

CREATE TABLE country_region_mapping (
    country VARCHAR(40) NOT NULL,
    continent VARCHAR(40) NOT NULL
)

SELECT *
FROM country_region_mapping

INSERT INTO country_region_mapping (country , continent)
VALUES 
    ('India', 'Asia'),
    ('China', 'Asia'),
    ('Japan', 'Asia'),
    ('Bangladesh', 'Asia'),
    ('Germany', 'Europe'),
    ('France', 'Europe'),
    ('United Kingdom', 'Europe'),
    ('Portugal', 'Europe'),
    ('United States', 'North America'),
    ('Mexico', 'North America'),
    ('Brazil', 'South America'),
    ('Argentina', 'South America'),
    ('South Africa', 'Africa'),
    ('Nigeria', 'Africa')

SELECT COUNT(*) FROM country_region_mapping
SELECT * FROM country_region_mapping

WITH table_joining_and_agg_data_calc AS (
    SELECT 
        COALESCE(sup_tab.continent, 'Unmapped') AS continent,
        COUNT(main_tab."Event ID") AS total_incidents,
        SUM(main_tab."Number of Deaths") AS total_deaths,
        ROUND(AVG(main_tab."Number of Deaths"), 0) AS average_deaths
    FROM project_6_human_stampedes AS main_tab
    LEFT JOIN country_region_mapping AS sup_tab
        ON main_tab."Country" = sup_tab.country
    WHERE main_tab."Country" IS NOT NULL
    GROUP BY COALESCE(sup_tab.continent, 'Unmapped')
)

SELECT 
    continent,
    total_incidents,
    total_deaths,
    average_deaths
FROM table_joining_and_agg_data_calc
ORDER BY total_deaths DESC;

/*
Q4. Decade-wise Stampede Fatality Analysis

Business requirement:
Analyze stampede incidents decade-wise to understand how the number of recorded incidents and fatalities are distributed across different decades.
For each decade, calculate the total incidents, total fatalities, number of incidents with at least 100 deaths, and number of incidents with zero deaths.

Expected output columns:
- decade
- total_incidents
- total_deaths
- incidents_with_100_or_more_deaths
- incidents_with_zero_deaths
Mandatory SQL concepts:
- Date functions (EXTRACT)
- Conditional aggregation (COUNT with CASE WHEN)
- GROUP BY
- SUM
- ORDER BY

Additional requirements:
1. Exclude records with NULL dates.
2. Derive the decade from the event date.
3. Include all decades represented in the dataset.
4. Sort decades in ascending chronological order.
*/

WITH decade_level_agg_calc AS (
    SELECT
        EXTRACT(DECADE FROM event_date) * 10 AS decade,
        COUNT("Event ID") AS total_incidents,
        SUM("Number of Deaths") AS total_deaths,
        COUNT(
            CASE 
                WHEN "Number of Deaths" >= 100 THEN 1
            END
        ) AS incidents_with_100_or_more_deaths,
        COUNT(
            CASE
                WHEN "Number of Deaths" = 0 THEN 1
            END
        ) AS incidents_with_zero_deaths
    FROM project_6_human_stampedes
    WHERE "Date" IS NOT NULL
    GROUP BY EXTRACT(DECADE FROM event_date) * 10
),

decade_level AS (
    SELECT
        CONCAT_WS('-', decade, decade + 9) AS decade_range,
        total_incidents,
        total_deaths,
        incidents_with_100_or_more_deaths,
        incidents_with_zero_deaths
    FROM decade_level_agg_calc
)

SELECT 
    decade_range,
    total_incidents,
    total_deaths,
    incidents_with_100_or_more_deaths,
    incidents_with_zero_deaths 
FROM decade_level
ORDER BY decade_range;
