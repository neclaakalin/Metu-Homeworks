select p.pub_type, count(*) as "total_count"
from pub p
group by p.pub_type
order by count(*) desc