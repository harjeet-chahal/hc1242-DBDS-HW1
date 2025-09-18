WITH gender_medals AS (
    SELECT 
        country_code AS country,
        CASE 
            WHEN gender = 'M' THEN 'Male'
            WHEN gender = 'W' THEN 'Female'
        END AS gender,
        discipline,
        COUNT(*) AS medal_count
    FROM medals
    WHERE gender IN ('M','W')
    GROUP BY country_code, gender, discipline
),
totals AS (
    SELECT 
        country,
        gender,
        SUM(medal_count) AS total_medals
    FROM gender_medals
    GROUP BY country, gender
),
ranked AS (
    SELECT
        country,
        gender,
        total_medals,
        RANK() OVER (PARTITION BY gender ORDER BY total_medals DESC) AS rank
    FROM totals
),
top10 AS (
    SELECT DISTINCT m.country
    FROM ranked m
    WHERE (gender = 'Male' AND rank <= 10)
       OR (gender = 'Female' AND rank <= 10)
    GROUP BY country
    HAVING COUNT(DISTINCT gender) = 2
),
top_sport AS (
    SELECT 
        country,
        gender,
        discipline,
        medal_count,
        RANK() OVER (PARTITION BY country, gender ORDER BY medal_count DESC) AS rnk
    FROM gender_medals
)
SELECT
    m.rank AS MALE_RANK,
    f.rank AS FEMALE_RANK,
    m.total_medals AS MALE_MEDALS,
    f.total_medals AS FEMALE_MEDALS,
    CASE 
        WHEN m.total_medals > f.total_medals THEN 'Male'
        WHEN f.total_medals > m.total_medals THEN 'Female'
        ELSE 'Equal'
    END AS DOMINANT_GENDER,
    (SELECT discipline FROM top_sport WHERE country = m.country AND gender = 'Male' AND rnk = 1) AS TOP_MALE_SPORT,
    (SELECT discipline FROM top_sport WHERE country = f.country AND gender = 'Female' AND rnk = 1) AS TOP_FEMALE_SPORT
FROM ranked m
JOIN ranked f ON m.country = f.country
JOIN top10 t ON m.country = t.country
WHERE m.gender = 'Male' AND f.gender = 'Female'
ORDER BY m.rank, f.rank;
