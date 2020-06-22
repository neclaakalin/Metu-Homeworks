create table if not exists ActiveAuthors (name text);

insert into ActiveAuthors("name")
select distinct a."name" 
from author a, authored a2, "publication" p
where p."year" >= 2018 and 
	p."year" <= 2020 and 
	p.pub_id = a2.pub_id and 
	a.author_id = a2.author_id;

create or replace function trigger_function()
	returns trigger as $$
	begin 
		if (NEW.pub_id in (select distinct p2.pub_id
								from "publication" p2
								where p2."year"  >= 2018 and
									p2."year" <= 2020) and 
			NEW.author_id not in (select distinct a3.author_id
										from author a3, ActiveAuthors a4
										where a3."name" = a4."name")) then
		insert into ActiveAuthors("name")
		select a5."name" 
		from author a5
		where a5.author_id =new.author_id;
		end if;
	end; $$
language plpgsql;

	
create trigger to_actives
	after insert on authored
	for each row
	execute procedure trigger_function();
	