select 
	alc.airline_name,
	m.monday_flights as monday_flights,
	s.sunday_flights as sunday_flights
from
	(select 
		fr.airline_code,
		count(*) as monday_flights
	from 
		flight_reports fr
	where 
		fr.weekday_id = '1' and 
		fr.is_cancelled = 0
	group by 
		fr.airline_code) as m,
	(select 
		fr.airline_code,
		count(*) as sunday_flights
	from 
		flight_reports fr
	where 
		fr.weekday_id = '7' and 
		fr.is_cancelled = 0
	group by 
		fr.airline_code) as s,
	airline_codes alc
where 
	s.airline_code = m.airline_code and 
	alc.airline_code = s.airline_code
order by 
	alc.airline_name 