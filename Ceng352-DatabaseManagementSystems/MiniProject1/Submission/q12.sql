select 
	t."year",
	t.airline_code,
	b.boston_count as boston_flight_count,
	cast(b.boston_count as float)/cast(t.total_count as float)*100 as boston_flight_percentage
from
	(select 
		fr.airline_code,
		fr."year",
		count(*) as boston_count
	from
		flight_reports fr
	where 
		fr.dest_city_name = 'Boston, MA' and 
		is_cancelled = 0
	group by 
		fr.airline_code,
		fr."year") as b,
	(select 
		fr.airline_code,
		fr."year",
		count(*) as total_count
	from
		flight_reports fr
	where  
		is_cancelled = 0
	group by 
		fr.airline_code,
		fr."year") as t
where 
	t."year" = b."year" and 
	t.airline_code = b.airline_code
group by 
	t."year",
	t.airline_code,
	b.boston_count,
	t.total_count
having
	cast(b.boston_count as float)/cast(t.total_count as float)*100 > 1
order by 
	t."year",
	t.airline_code