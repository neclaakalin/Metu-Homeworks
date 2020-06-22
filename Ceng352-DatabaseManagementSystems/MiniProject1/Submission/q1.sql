select
	alc.airline_name, 
	alc.airline_code, 
	avg(fr.departure_delay ) as avg_delay
from 
	airline_codes alc, 
	flight_reports fr 
where 
	fr."year" = 2018 and 
	fr.airline_code = alc.airline_code and 
	fr.is_cancelled = 0
group by 
	alc.airline_code
order by 
	avg(fr.departure_delay),
	alc.airline_name