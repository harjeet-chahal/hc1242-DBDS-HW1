WITH medal_heights AS (
    SELECT
        m.discipline,
        CASE 
            WHEN m.gender = 'M' THEN 'Male'
            WHEN m.gender = 'W' THEN 'Female'
        END AS gender,
        a.height AS height
    FROM medals m
    JOIN athletes a ON m.code = a.code
    WHERE a.height IS NOT NULL AND a.height > 0
),
stats AS (
    SELECT
        discipline,
        gender,
        ROUND(AVG(height),1) AS avg_height_cm,
        COUNT(*) AS medal_count,
        ROUND(
            SQRT((SUM(height * height) * 1.0 / COUNT(*)) - (AVG(height) * AVG(height)))
        ,1) AS height_stddev
    FROM medal_heights
    GROUP BY discipline, gender
),
with_range AS (
    SELECT
        discipline,
        gender,
        avg_height_cm,
        medal_count,
        (avg_height_cm - height_stddev) AS ideal_min,
        (avg_height_cm + height_stddev) AS ideal_max
    FROM stats
),
final AS (
    SELECT
        m.discipline,
        m.gender,
        m.avg_height_cm,
        m.medal_count,
        ROUND(m.ideal_min,1) || '-' || ROUND(m.ideal_max,1) AS ideal_height_range,
        ROUND(100.0 * SUM(
            CASE WHEN h.height BETWEEN m.ideal_min AND m.ideal_max THEN 1 ELSE 0 END
        ) / COUNT(*),1) AS pct_in_ideal_range
    FROM with_range m
    JOIN medal_heights h
      ON h.discipline = m.discipline AND h.gender = m.gender
    GROUP BY m.discipline, m.gender, m.avg_height_cm, m.medal_count, m.ideal_min, m.ideal_max
)
SELECT
    discipline AS DISCIPLINE,
    gender AS GENDER,
    avg_height_cm AS AVG_HEIGHT_CM,
    medal_count AS MEDAL_COUNT,
    ideal_height_range AS IDEAL_HEIGHT_RANGE,
    pct_in_ideal_range AS PCT_IN_IDEAL_RANGE
FROM final
ORDER BY discipline, gender;
