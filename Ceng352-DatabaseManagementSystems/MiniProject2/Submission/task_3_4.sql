select concat('"',cast(yearly_counts."year" as text),'-',cast((yearly_counts."year"+10) as text),'"') as decade, 
	sum(yearly_counts_2."count") as total
from	
	(select p."year" as "year", count(*) as "count"
	from "publication" p
	where p."year" >= 1940
	group by p."year") as yearly_counts,
	(select p."year" as "year", count(*) as "count"
	from "publication" p
	where p."year" >= 1940
	group by p."year") as yearly_counts_2,
	(select distinct p2."year"
	from "publication" p2 
	where p2."year" >= 1940) as years
where yearly_counts."year" = years."year" and
	yearly_counts_2."year" < years."year" + 10 and 
	yearly_counts_2."year" >= yearly_counts."year"
group by yearly_counts."year"
order by concat('"',cast(yearly_counts."year" as text),'-',cast((yearly_counts."year"+10) as text),'"')