select
	alc3.airline_name, 
	ttt."year", 
	sum(ttt.t_num) as total_num_flights, 
	sum(ccc.c_num) as cancelled_flights
from
	(select
		fr2."year",
		fr2.airline_code,
		count(*) as t_num
	from
		(select 
			m.airline_name
		from
			(select 
				alc.airline_name, n."year", sum(n.daily_count) as total_num_flights, sum(n_cancelled.cancelled_count) as cancelled_flights
			from
				(select 
					fr."year", fr.airline_code, count(*) as daily_count
				from 
					flight_reports fr
				group by 
					fr."year",
					fr."month",
					fr."day",
					fr.airline_code) as n,
				(select 
					fr."year", fr.airline_code, count(*) as cancelled_count
				from 
					flight_reports fr
				where
					is_cancelled = 1
				group by 
					fr."year",
					fr."month",
					fr."day",
					fr.airline_code) as n_cancelled,
				airline_codes alc
			where 
				alc.airline_code = n.airline_code and
				n_cancelled."year" = n."year" and 
				n_cancelled.airline_code = n.airline_code
			group by 
				n."year",
				alc.airline_name
			having 
				avg(n.daily_count) > 2000) as m
		group by 
			m.airline_name
		having count("year") = 4) as k,
		flight_reports fr2,
		airline_codes alc2
	where 
		k.airline_name = alc2.airline_name and
		fr2.airline_code = alc2.airline_code
	group by 
		fr2."year",
		fr2."month",
		fr2."day",
		fr2.airline_code) as ttt,
	(select
		fr2."year",
		fr2.airline_code,
		count(*) as c_num
	from
		(select 
			m.airline_name
		from
			(select 
				alc.airline_name, n."year", sum(n.daily_count) as total_num_flights, sum(n_cancelled.cancelled_count) as cancelled_flights
			from
				(select 
					fr."year", fr.airline_code, count(*) as daily_count
				from 
					flight_reports fr
				group by 
					fr."year",
					fr."month",
					fr."day",
					fr.airline_code) as n,
				(select 
					fr."year", fr.airline_code, count(*) as cancelled_count
				from 
					flight_reports fr
				where
					is_cancelled = 1
				group by 
					fr."year",
					fr."month",
					fr."day",
					fr.airline_code) as n_cancelled,
				airline_codes alc
			where 
				alc.airline_code = n.airline_code and
				n_cancelled."year" = n."year" and 
				n_cancelled.airline_code = n.airline_code
			group by 
				n."year",
				alc.airline_name
			having 
				avg(n.daily_count) > 2000) as m
		group by 
			m.airline_name
		having count("year") = 4) as k,
		flight_reports fr2,
		airline_codes alc2
	where 
		k.airline_name = alc2.airline_name and
		fr2.airline_code = alc2.airline_code and 
		fr2.is_cancelled = 1
	group by 
		fr2."year",
		fr2."month",
		fr2."day",
		fr2.airline_code) as ccc,
	airline_codes alc3
where
	ccc."year" = ttt."year" and 
	ccc.airline_code = ttt.airline_code and 
	alc3.airline_code = ttt.airline_code
group by 
	alc3.airline_name,
	ttt."year"
order by 
	alc3.airline_name 
	