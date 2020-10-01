#!/usr/bin/env bash

pguser=$1
pgdb=$2
pgpassword=$3

export PGPASSWORD=${pgpassword}

psql -U $pguser -d $pgdb -h 127.0.0.1 <<EOF

ALTER TABLE train_stations ALTER COLUMN arrival_time DROP NOT NULL;

UPDATE train_stations SET arrival_time = NULL WHERE seq = 1;

UPDATE train_stations SET departure_time = NULL
WHERE (train_no, seq) IN (SELECT train_no, seq
                          FROM train_stations t_s_1
                          WHERE seq = (SELECT max(seq)
                                       FROM train_stations t_s_2
                                       WHERE t_s_2.train_no = t_s_1.train_no));

select * from train_stations where station_code = 'SWV' order by arrival_time;

select arrival_time - previous_arrival from (select arrival_time, lag(arrival_time) over (order by arrival_time) as previous_arrival from train_stations where station_code = 'SWV' order by arrival_time) as foo;

EOF
