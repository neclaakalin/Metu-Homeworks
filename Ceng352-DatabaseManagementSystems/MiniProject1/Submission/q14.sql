select 
	fr."year",
	w2.weekday_name,
	cr.reason_desc as reason,
	count(*) as number_of_cancellations
from 
	flight_reports fr,
	cancellation_reasons cr,
	weekdays w2
where 
	fr.is_cancelled = 1 and 
	cr.reason_code = fr.cancellation_reason and 
	fr.weekday_id = w2.weekday_id
group by 
	fr."year",
	w2.weekday_name,
	fr.weekday_id,
	cr.reason_desc
having 
	count(*) >= all (
		select 
			count(*)
		from 
			flight_reports fr2 
		where 
			fr2.is_cancelled = 1 and 
			fr2."year" = fr."year" and 
			fr.weekday_id = fr2.weekday_id
		group by 
			fr2."year",
			fr2.weekday_id,
			fr2.cancellation_reason
	)
order by 
	fr."year",
	fr.weekday_id 