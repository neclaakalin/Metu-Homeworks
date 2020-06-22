select fp.field_name
from (
	select f.field_name, p.pub_type
	from field f, pub p
	where f.pub_key = p.pub_key
	group by p.pub_type, f.field_name 
	order by f.field_name asc) as fp
group by fp.field_name
having count(*) = 7
order by fp.field_name asc