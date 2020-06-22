select 
	fr3.plane_tail_number, 
	avg(cast(fr3.flight_time as float)/cast(fr3.flight_distance as float)) as avg_speed
from
	(select 
		fr.plane_tail_number
	from 
		flight_reports fr
	where 
		fr."year" = 2016 and 
		fr."month" = '1' and 
		fr.is_cancelled = 0
	except 
	select 
		fr2.plane_tail_number
	from 
		flight_reports fr2
	where 
		fr2."year" = 2016 and
		fr2."month" = '1' and
		(fr2.weekday_id = '1' or
		fr2.weekday_id = '2' or
		fr2.weekday_id = '3' or
		fr2.weekday_id = '4' or
		fr2.weekday_id = '5')) as n,
	flight_reports fr3
where 
	fr3."year" = 2016 and 
	fr3."month" = '1' and 
	fr3.plane_tail_number = n.plane_tail_number
group by fr3.plane_tail_number
order by
	avg(cast(fr3.flight_time as float)/cast(fr3.flight_distance as float)) desc