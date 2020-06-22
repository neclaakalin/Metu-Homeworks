select 
	ai.airport_desc
from
	(select 
		fr.origin_airport_id,
		count(*) as outgoing_count
	from 
		flight_reports fr
	where
		fr.is_cancelled = 0
	group by 
		fr.origin_airport_id) as origin,
	(select 
		fr.dest_airport_id,
		count(*) as incoming_count
	from 
		flight_reports fr
	where
		fr.is_cancelled = 0
	group by 
		fr.dest_airport_id) as dest,
	airport_ids ai
where 
	origin.origin_airport_id = dest.dest_airport_id and 
	ai.airport_id = origin.origin_airport_id
group by 
	ai.airport_desc,
	origin.outgoing_count,
	dest.incoming_count
order by 
	origin.outgoing_count + dest.incoming_count desc,
	ai.airport_desc
limit 5