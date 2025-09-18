WITH athlete_ages AS (
    SELECT
        country_code,
        country,
        CAST((julianday('2024-07-26') - julianday(birth_date)) / 365.25 AS INT) AS age
    FROM athletes
    WHERE birth_date IS NOT NULL AND birth_date != ''
),
age_stats AS (
    SELECT
        country_code,
        country,
        COUNT(*) AS athlete_count,
        ROUND(AVG(age),1) AS avg_age,
        ROUND(
            SQRT((SUM(age * age) * 1.0 / COUNT(*)) - (AVG(age) * AVG(age)))
        ,1) AS age_std_dev,
        MIN(age) AS min_age,
        MAX(age) AS max_age
    FROM athlete_ages
    GROUP BY country_code, country
),
medal_counts AS (
    SELECT
        country_code,
        COUNT(*) AS total_medals
    FROM medals
    GROUP BY country_code
),
combined AS (
    SELECT
        a.country_code,
        a.country,
        a.athlete_count,
        a.avg_age,
        a.age_std_dev,
        a.min_age,
        a.max_age,
        IFNULL(m.total_medals,0) AS total_medals,
        ROUND(IFNULL(m.total_medals * 1.0 / a.athlete_count,0),2) AS medals_per_athlete
    FROM age_stats a
    LEFT JOIN medal_counts m ON a.country_code = m.country_code
),
ranked AS (
    SELECT 
        *,
        NTILE(4) OVER (ORDER BY age_std_dev) AS quartile
    FROM combined
)
SELECT
    country_code AS COUNTRY_CODE,
    country AS COUNTRY,
    athlete_count AS ATHLETE_COUNT,
    avg_age AS AVG_AGE,
    age_std_dev AS AGE_STD_DEV,
    min_age AS MIN_AGE,
    max_age AS MAX_AGE,
    total_medals AS TOTAL_MEDALS,
    medals_per_athlete AS MEDALS_PER_ATHLETE,
    CASE quartile
        WHEN 4 THEN 'High'
        WHEN 3 THEN 'Medium'
        ELSE 'Low'
    END AS AGE_DIVERSITY_QUARTILE
FROM ranked
ORDER BY age_std_dev DESC
LIMIT 10;
