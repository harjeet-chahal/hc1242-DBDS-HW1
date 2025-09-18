-- trying to see which countries r like the best in diff sports lol

select country_code as country,   
count(distinct discipline) as total_sports,   
sum(cnt) as total_medals,   
group_concat(discipline || ':' || cnt, ', ') as medal_distribution  

from (
   -- count medals for each sport per country
   select country_code, discipline, count(*) as cnt
   from medals
   group by country_code, discipline
)

group by country_code
order by total_sports desc, total_medals desc
limit 10;   -- top 10 only duh
