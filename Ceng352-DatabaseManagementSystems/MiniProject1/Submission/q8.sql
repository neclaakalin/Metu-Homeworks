select
	fr.plane_tail_number,
	alc.airline_name as first_owner,
	alc2.airline_name as second_owner
from 
	flight_reports fr,
	flight_reports fr2,
	airline_codes alc,
	airline_codes alc2 
where 
	fr.plane_tail_number = fr2.plane_tail_number and 
	fr.airline_code != fr2.airline_code and 
	(fr."year" < fr2."year" or 
	(fr."year" = fr2."year" and 
	fr."month" < fr2."month") or 
	(fr."year" = fr2."year" and 
	fr."month" = fr2."month"and
	fr."day" < fr2."day")) and 
	alc.airline_code = fr.airline_code and 
	alc2.airline_code = fr2.airline_code
group by
	fr.plane_tail_number,
	alc.airline_name,
	alc2.airline_name 
order by 
	plane_tail_number