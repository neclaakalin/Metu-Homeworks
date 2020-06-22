select 
	n.plane_tail_number,
	n."year",
	avg(n.daily_count) as daily_avg
from
	(select 
		fr.plane_tail_number,
		fr."year",
		count(*) as daily_count
	from 
		flight_reports fr
	where 
		fr.is_cancelled = 0
	group by 
		fr."year",
		fr."month",
		fr."day",
		fr.plane_tail_number) as n
group by 
	n.plane_tail_number,
	n."year"
having 
	avg(n.daily_count)>5
order by 
	n.plane_tail_number,
	n."year"