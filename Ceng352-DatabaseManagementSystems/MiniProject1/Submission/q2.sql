select 
	apc.airport_code, 
	apc.airport_desc, 
	count(*) as cancel_count
from 
	airport_codes apc, flight_reports fr 
where 
	fr.is_cancelled = 1 and
	fr.cancellation_reason = 'D' and 
	fr.origin_airport_code = apc.airport_code
group by 
	apc.airport_code
order by
	count(*) desc, 
	apc.airport_code 