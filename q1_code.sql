SELECT 
    country_code AS country,
    COUNT(DISTINCT discipline) AS total_sports,
    SUM(cnt) AS total_medals,
    GROUP_CONCAT(discipline || ':' || cnt, ', ') AS medal_distribution
FROM (
    SELECT 
        country_code,
        discipline,
        COUNT(*) AS cnt
    FROM medals
    GROUP BY country_code, discipline
)
GROUP BY country_code
ORDER BY total_sports DESC, total_medals DESC
LIMIT 10; 