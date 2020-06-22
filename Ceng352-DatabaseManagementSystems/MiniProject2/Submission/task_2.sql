------------------------- PUBLICATION ------------------------- DONE
insert into "publication"(pub_id, pub_key, title, "year")
select
	row_number() over (order by p.pub_key) as "pub_id", 
	p.pub_key,
	t.field_value as "title",
	cast(y.field_value as int) as "year"
from
	pub p,
	(select f.pub_key, f.field_value 
	from field f
	where f.field_name = 'title') as t,
	(select f.pub_key, f.field_value 
	from field f
	where f.field_name = 'year') as y
where
	p.pub_key = t.pub_key and 
	p.pub_key = y.pub_key;

---------------------------- AUTHOR --------------------------- DONE
insert into author(author_id, "name")
select
	row_number() over (order by f.field_value) as "author_id",
	f.field_value as "name"
from field f
where f.field_name = 'author'
group by f.field_value;

--------------------------- ARTICLE --------------------------- DONE
insert into article(pub_id, journal, "month", volume, "number")
select pbl.pub_id, jrn.journals, mth.months, vlm.volumes, nbr.numbers
from "publication" pbl,
	(select p.pub_key, string_agg(distinct j.field_value, ', ') as journals
	from (select pub.pub_key
		from pub 
		where pub.pub_type = 'article') as p
	left join 
		(select f.pub_key, f.field_value
		from field f
		where f.field_name= 'journal') as j on j.pub_key = p.pub_key
	group by p.pub_key) as jrn,
	(select p.pub_key, string_agg(distinct m.field_value, ', ') as months
	from (select pub.pub_key
		from pub 
		where pub.pub_type = 'article') as p
	left join 
		(select f.pub_key, f.field_value
		from field f
		where f.field_name= 'month') as m on m.pub_key = p.pub_key
	group by p.pub_key) as mth,
	(select p.pub_key, string_agg(distinct v.field_value, ', ') as volumes
	from (select pub.pub_key
		from pub 
		where pub.pub_type = 'article') as p
	left join 
		(select f.pub_key, f.field_value
		from field f
		where f.field_name= 'volume') as v on v.pub_key = p.pub_key
	group by p.pub_key) as vlm,
	(select p.pub_key, string_agg(distinct n.field_value, ', ') as numbers
	from (select pub.pub_key
		from pub 
		where pub.pub_type = 'article') as p
	left join 
		(select f.pub_key, f.field_value
		from field f
		where f.field_name= 'number') as n on n.pub_key = p.pub_key
	group by p.pub_key) as nbr
where pbl.pub_key = jrn.pub_key and 
	pbl.pub_key = mth.pub_key and 
	pbl.pub_key = vlm.pub_key and 
	pbl.pub_key = nbr.pub_key;
	
----------------------------- BOOK ---------------------------- DONE
insert into book(pub_id, publisher, isbn)
select distinct pbl.pub_id, pbls.publishers as publisher, isb.ii as isbn
from "publication" pbl,
	(select p.pub_key, string_agg(distinct pb.field_value, ', ') as publishers
	from (select pub.pub_key
		from pub 
		where pub.pub_type = 'book') as p
	left join 
		(select f.pub_key, f.field_value
		from field f
		where f.field_name= 'publisher') as pb on pb.pub_key = p.pub_key
	group by p.pub_key) as pbls,
	(select p.pub_key, max(i.field_value) as ii
	from (select pub.pub_key
		from pub 
		where pub.pub_type = 'book') as p
	left join 
		(select f.pub_key, f.field_value
		from field f
		where f.field_name= 'isbn') as i on i.pub_key = p.pub_key
	group by p.pub_key) as isb
where pbl.pub_key = pbls.pub_key and
	pbl.pub_key = isb.pub_key;
	
------------------------- INCOLLECTION ------------------------ DONE
insert into incollection(pub_id, book_title, publisher, isbn)
select distinct pbl.pub_id, tit.titles as book_title, edi.publishers as publisher, isb.ii as isbn
from "publication" pbl,
	(select p.pub_key, string_agg(distinct t.field_value, ', ') as titles
	from (select pub.pub_key
		from pub 
		where pub.pub_type = 'incollection') as p
	left join 
		(select f.pub_key, f.field_value
		from field f
		where f.field_name= 'booktitle') as t on t.pub_key = p.pub_key
	group by p.pub_key) as tit,
	(select p.pub_key, string_agg(distinct e.field_value, ', ') as publishers
	from (select pub.pub_key
		from pub 
		where pub.pub_type = 'incollection') as p
	left join 
		(select f.pub_key, f.field_value
		from field f
		where f.field_name= 'publisher') as e on e.pub_key = p.pub_key
	group by p.pub_key) as edi,
	(select p.pub_key, max(i.field_value) as ii
	from (select pub.pub_key
		from pub 
		where pub.pub_type = 'incollection') as p
	left join 
		(select f.pub_key, f.field_value
		from field f
		where f.field_name= 'isbn') as i on i.pub_key = p.pub_key
	group by p.pub_key) as isb
where pbl.pub_key = tit.pub_key and
	pbl.pub_key = edi.pub_key and 
	pbl.pub_key = isb.pub_key;
	
------------------------ INPROCEEDINGS ------------------------ DONE
insert into inproceedings(pub_id, book_title, editor)
select distinct pbl.pub_id, tit.titles as book_title, edi.editors as editor
from "publication" pbl,
	(select p.pub_key, string_agg(distinct t.field_value, ', ') as titles
	from (select pub.pub_key
		from pub 
		where pub.pub_type = 'inproceedings') as p
	left join 
		(select f.pub_key, f.field_value
		from field f
		where f.field_name= 'booktitle') as t on t.pub_key = p.pub_key
	group by p.pub_key) as tit,
	(select p.pub_key, string_agg(distinct e.field_value, ', ') as editors
	from (select pub.pub_key
		from pub 
		where pub.pub_type = 'inproceedings') as p
	left join 
		(select f.pub_key, f.field_value
		from field f
		where f.field_name= 'editor') as e on e.pub_key = p.pub_key
	group by p.pub_key) as edi
where pbl.pub_key = tit.pub_key and
	pbl.pub_key = edi.pub_key;

--------------------------- AUTHORED -------------------------- DONE
insert into authored(author_id, pub_id)
select distinct a.author_id, p.pub_id 
from author a, "publication" p, field f
where f.field_name = 'author' and 
	p.pub_key = f.pub_key and 
	a."name" = f.field_value;