select a3."name" as "name", count(*) as pub_count
from article a, authored a2, author a3
where a.journal = 'IEEE Trans. Wireless Communications' and 
	a.pub_id = a2.pub_id and 
	a2.author_id = a3.author_id and 
	a3.author_id not in 
		(select a3.author_id
		from article a, authored a2, author a3
		where a.journal = 'IEEE Wireless Commun. Letters' and 
			a.pub_id = a2.pub_id and 
			a2.author_id = a3.author_id
		group by a3.author_id)
group by a2.author_id, a3."name"
having count(*) >= 10
order by count(*) desc, a3."name"