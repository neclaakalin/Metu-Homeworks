create index pub_index on pub using btree (pub_key);
cluster pub using pub_index;

create index name_index on field using btree (pub_key, field_name);
cluster field using name_index;

-- drop index inproceedings_pkey;