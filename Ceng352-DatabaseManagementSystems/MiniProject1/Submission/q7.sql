select 
	alc.airline_name, 
	cast(c.cancelled as float)/cast(t.total as float)*100 as percentage
from
	(select 
		fr.airline_code, count(*) as cancelled
	from 
		flight_reports fr
	where 
		fr.origin_city_name like 'Boston%' and 
		is_cancelled = 1
	group by 
		fr.airline_code) as c,
	(select 
		fr.airline_code, count(*) as total
	from 
		flight_reports fr
	where 
		fr.origin_city_name like 'Boston%'
	group by 
		fr.airline_code) as t,
	airline_codes alc
where 
	c.airline_code = t.airline_code and 
	c.airline_code = alc.airline_code and 
	10*c.cancelled > t.total
group by 
	alc.airline_name,
	c.cancelled,
	t.total
order by 
	cast(c.cancelled as float)/cast(t.total as float)*100 desc