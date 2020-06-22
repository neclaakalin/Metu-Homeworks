select 
	concat(fr."day",'/', fr."month",'/', fr."year") as flight_date, 
	fr.plane_tail_number, 
	fr.arrival_time as flight1_arrival_time, 
	fr2.departure_time as flight2_departure_time, 
	fr.origin_city_name as origin_city_name, 
	fr.dest_city_name as stop_city_name, 
	fr2.dest_city_name as dest_city_name,
	sum(fr.flight_time + fr.taxi_out_time + fr2.taxi_in_time + fr2.flight_time) as total_time,
	sum(fr.flight_distance + fr2.flight_distance) as total_distance
from 
	flight_reports fr, flight_reports fr2
where 
	fr."year" = fr2."year" and 
	fr."month" = fr2."month" and 
	fr."day" = fr2."day" and 
	fr.arrival_time < fr2.departure_time and 
	fr.origin_city_name like 'Seattle%' and 
	fr2.dest_city_name = 'Boston, MA' and 
	fr.dest_city_name = fr2.origin_city_name and 
	fr.is_cancelled = 0 and 
	fr2.is_cancelled = 0 and 
	fr.plane_tail_number = fr2.plane_tail_number
group by 
	fr."year", fr."month", fr."day",
	fr.plane_tail_number, 
	fr.arrival_time, 
	fr2.departure_time, 
	fr.origin_city_name, 
	fr.dest_city_name, 
	fr2.dest_city_name
order by 
	sum(fr.flight_time + fr.taxi_out_time + fr2.taxi_in_time + fr2.flight_time),
	sum(fr.flight_distance + fr2.flight_distance),
	fr.plane_tail_number,
	fr.dest_city_name