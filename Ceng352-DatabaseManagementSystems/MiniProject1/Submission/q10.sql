select
	alc.airline_name,
	count(*) as flight_count
from
	(select 
		fr.airline_code,
		fr.plane_tail_number 
	from 
		flight_reports fr
	where 
		fr.dest_city_name like '%, TX'
	except 
	select
		fr.airline_code,
		fr.plane_tail_number
	from 
		flight_reports fr
	where 
		(fr.dest_city_name not like '%, TX')) as n,
	airline_codes alc,
	flight_reports fr2
where 
	alc.airline_code = n.airline_code and
	fr2.airline_code = n.airline_code and
	fr2.dest_city_name like '%, TX' and
	n.plane_tail_number = fr2.plane_tail_number
group by 
	alc.airline_name
order by 
	alc.airline_name 