select 
	n.weekday_id,
	n.weekday_name,
	avg(n.delay) as avg_delay
from 
	(select 
		w.weekday_id,
		w.weekday_name,
		sum(fr.departure_delay + fr.arrival_delay) as delay
	from 
		flight_reports fr, weekdays w
	where 
		fr.origin_city_name like 'San Francisco%' and 
		fr.dest_city_name like 'Boston%' and 
		w.weekday_id = fr.weekday_id
	group by 
		w.weekday_id) as n
where 
	n.delay <= all (
	select 
		sum(fr.departure_delay + fr.arrival_delay)
	from 
		flight_reports fr, weekdays w
	where 
		fr.origin_city_name like 'San Francisco%' and 
		fr.dest_city_name like 'Boston%' and 
		w.weekday_id = fr.weekday_id
	group by 
		w.weekday_id)
group by
	n.weekday_id,
	n.weekday_name