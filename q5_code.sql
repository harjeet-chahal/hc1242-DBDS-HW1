WITH medal_counts AS (
SELECT a.country,
a.code  AS athlete_code,
a.name  AS athlete_name,
COUNT(m.code) AS medal_count
FROM athletes a
JOIN medals m ON m.code = a.code
GROUP BY a.country, a.code, a.name
),
country_totals AS (
SELECT country,
SUM(medal_count)  AS total_medals,
COUNT(DISTINCT athlete_code) AS unique_medalists
FROM medal_counts
GROUP BY country
),
ranked AS (
SELECT mc.country,
mc.athlete_code,
mc.athlete_name,
mc.medal_count,
ROW_NUMBER() OVER (PARTITION BY mc.country ORDER BY mc.medal_count DESC, mc.athlete_name) AS rn
FROM medal_counts mc
),
top10_share AS (
SELECT r.country,
100.0 * SUM(r.medal_count) / ct.total_medals AS top10_share
FROM ranked r
JOIN country_totals ct ON ct.country = r.country
WHERE r.rn <= 10
GROUP BY r.country, ct.total_medals
),
most_decorated AS (
SELECT country,
athlete_name AS most_decorated_athlete,
medal_count
FROM (
SELECT mc.*,
ROW_NUMBER() OVER (PARTITION BY mc.country ORDER BY mc.medal_count DESC, mc.athlete_name) AS rn
FROM medal_counts mc
)
WHERE rn = 1
)
SELECT ct.country AS country,
ct.total_medals,
ct.unique_medalists,
printf('%.1f%%', ts.top10_share) AS top_10_athletes_share,
md.most_decorated_athlete,
md.medal_count
FROM country_totals ct
JOIN top10_share ts ON ts.country = ct.country
JOIN most_decorated md ON md.country = ct.country
ORDER BY ts.top10_share DESC;