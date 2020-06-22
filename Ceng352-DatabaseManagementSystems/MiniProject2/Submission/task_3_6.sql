select p."year" as "year", 
	a2."name" as "name",
	count(*) as "count"
from "publication" p, 
	authored a,
	author a2, 
	(select cnt."year" as "year", 
		max(cnt.c) as mx
	from 
		(select p2."year", count(*) as c
		from "publication" p2, authored a3
		where p2.pub_id = a3.pub_id and 
			p2."year" <= 1990 and 
			p2."year" >= 1940
		group by a3.author_id, p2."year") as cnt
	group by cnt."year") as n
where p."year" >= 1940 and
	p."year" <= 1990 and
	p."year" = n."year" and
	p.pub_id = a.pub_id and 
	a.author_id = a2.author_id 
group by p."year", a.author_id, a2."name", n.mx
having count(*) >= n.mx
order by p."year", a2."name"