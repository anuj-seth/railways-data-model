#!/usr/bin/env bash

pguser=$1
pgdb=$2
pgpassword=$3

export PGPASSWORD=${pgpassword}

psql -U $pguser -d $pgdb -h 127.0.0.1 <<EOF

ALTER TABLE train_stations ALTER COLUMN arrival_time DROP NOT NULL;

ALTER TABLE train_stations ALTER COLUMN departure_time DROP NOT NULL;

UPDATE train_stations SET arrival_time = NULL WHERE seq = 1;

UPDATE train_stations SET departure_time = NULL
WHERE (train_no, seq) IN (SELECT train_no, max(seq) as seq
                          FROM train_stations
                          GROUP BY train_no);

--select * from train_stations where station_code = 'SWV' order by arrival_time;

--select arrival_time - previous_arrival from (select arrival_time, lag(arrival_time) over (order by arrival_time) as previous_arrival from train_stations where station_code = 'SWV' order by arrival_time) as foo;

EOF


# SELECT *
# FROM train_stations t_s_1
# WHERE departure_time = '00:00:00'
# and station_code = 'NDLS'
# AND (train_no, seq) NOT IN (SELECT train_no, max(seq)
#                             FROM train_stations t_s_2
#                             WHERE t_s_2.station_code = t_s_1.station_code
#                             GROUP BY t_s_2.train_no);


# select *
#               from train_stations t_s
#               where t_s.departure_time = '00:00:00'
#               and (train_no, seq) not in (SELECT train_no, max(seq)
#                                           FROM train_stations t_s_1
#                                           group by train_no);
