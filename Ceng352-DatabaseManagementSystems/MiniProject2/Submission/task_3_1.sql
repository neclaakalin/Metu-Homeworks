select a2."name" as author_name, count(*) as pub_count
from authored a, author a2 
where a2.author_id = a.author_id 
group by a.author_id, a2."name" 
having count(*)>=150 and count(*)<200
order by count(*), a2."name" 