select a."name" as "name", count(*) as collab_count
from author a,
	(select distinct a2.author_id as f, a3.author_id as s
	from authored a2, authored a3
	where a2.author_id != a3.author_id and 
		a2.pub_id = a3.pub_id) as n
where a.author_id = n.f
group by n.f, a."name" 
order by count(*) desc, a."name"
limit 1000