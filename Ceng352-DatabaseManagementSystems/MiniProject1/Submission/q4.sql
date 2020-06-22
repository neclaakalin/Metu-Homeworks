select
	alc.airline_name
from 
	airline_codes alc
where 
	alc.airline_code in (select 
							alc2.airline_code 
						from 
							airline_codes alc2, flight_reports fr
						where 
							fr.dest_city_name = 'Boston, MA' and fr.airline_code = alc2.airline_code and fr.is_cancelled = 0)
	and alc.airline_code in (select 
								alc2.airline_code 
							from 
								airline_codes alc2, flight_reports fr
							where 
								fr.dest_city_name = 'New York, NY' and fr.airline_code = alc2.airline_code and fr.is_cancelled = 0)
	and alc.airline_code in (select 
								alc2.airline_code 
							from 
								airline_codes alc2, flight_reports fr
							where 
								fr.dest_city_name = 'Portland, ME' and fr.airline_code = alc2.airline_code and fr.is_cancelled = 0)
	and alc.airline_code in (select 
								alc2.airline_code 
							from 
								airline_codes alc2, flight_reports fr
							where 
								fr.dest_city_name = 'Washington, DC' and fr.airline_code = alc2.airline_code and fr.is_cancelled = 0)
	and alc.airline_code in (select 
								alc2.airline_code 
							from 
								airline_codes alc2, flight_reports fr
							where 
								fr.dest_city_name = 'Philadelphia, PA' and fr.airline_code = alc2.airline_code and fr.is_cancelled = 0)
	and alc.airline_code not in (select 
								alc3.airline_code
							from
								airline_codes alc3
							where 
								alc3.airline_code in (select 
															alc2.airline_code 
														from 
															airline_codes alc2, flight_reports fr
														where 
															fr.dest_city_name = 'Boston, MA' and fr.airline_code = alc2.airline_code and fr.is_cancelled = 0 and fr."year" = 2017)
									and alc.airline_code in (select 
																alc2.airline_code 
															from 
																airline_codes alc2, flight_reports fr
															where 
																fr.dest_city_name = 'New York, NY' and fr.airline_code = alc2.airline_code and fr.is_cancelled = 0 and fr."year" = 2017)
									and alc.airline_code in (select 
																alc2.airline_code 
															from 
																airline_codes alc2, flight_reports fr
															where 
																fr.dest_city_name = 'Portland, ME' and fr.airline_code = alc2.airline_code and fr.is_cancelled = 0 and fr."year" = 2017)
									and alc.airline_code in (select 
																alc2.airline_code 
															from 
																airline_codes alc2, flight_reports fr
															where 
																fr.dest_city_name = 'Washington, DC' and fr.airline_code = alc2.airline_code and fr.is_cancelled = 0 and fr."year" = 2017)
									and alc.airline_code in (select 
																alc2.airline_code 
															from 
																airline_codes alc2, flight_reports fr
															where 
																fr.dest_city_name = 'Philadelphia, PA' and fr.airline_code = alc2.airline_code and fr.is_cancelled = 0 and fr."year" = 2017))
	and alc.airline_code not in (select 
								alc3.airline_code
							from
								airline_codes alc3
							where 
								alc3.airline_code in (select 
															alc2.airline_code 
														from 
															airline_codes alc2, flight_reports fr
														where 
															fr.dest_city_name = 'Boston, MA' and fr.airline_code = alc2.airline_code and fr.is_cancelled = 0 and fr."year" = 2016)
									and alc.airline_code in (select 
																alc2.airline_code 
															from 
																airline_codes alc2, flight_reports fr
															where 
																fr.dest_city_name = 'New York, NY' and fr.airline_code = alc2.airline_code and fr.is_cancelled = 0 and fr."year" = 2016)
									and alc.airline_code in (select 
																alc2.airline_code 
															from 
																airline_codes alc2, flight_reports fr
															where 
																fr.dest_city_name = 'Portland, ME' and fr.airline_code = alc2.airline_code and fr.is_cancelled = 0 and fr."year" = 2016)
									and alc.airline_code in (select 
																alc2.airline_code 
															from 
																airline_codes alc2, flight_reports fr
															where 
																fr.dest_city_name = 'Washington, DC' and fr.airline_code = alc2.airline_code and fr.is_cancelled = 0 and fr."year" = 2016)
									and alc.airline_code in (select 
																alc2.airline_code 
															from 
																airline_codes alc2, flight_reports fr
															where 
																fr.dest_city_name = 'Philadelphia, PA' and fr.airline_code = alc2.airline_code and fr.is_cancelled = 0 and fr."year" = 2016))
order by 
	alc.airline_name 