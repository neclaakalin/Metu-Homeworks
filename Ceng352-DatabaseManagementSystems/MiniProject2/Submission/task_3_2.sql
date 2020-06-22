select a3."name" as author_name, count(*) as pub_count
from article a, authored a2, author a3 
where a.journal like '%IEEE%' and 
	a.pub_id = a2.pub_id and 
	a2.author_id = a3.author_id
group by a2.author_id, a3."name" 
order by count(*) desc, a3."name" 
limit 50