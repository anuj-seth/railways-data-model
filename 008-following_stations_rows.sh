#!/usr/bin/env bash

pguser=$1
pgdb=$2
pgpassword=$3

export PGPASSWORD=${pgpassword}

psql -U $pguser -d $pgdb -h 127.0.0.1 <<EOF

DROP TABLE IF EXISTS train_following_stations_rows;

CREATE TABLE train_following_stations_rows
(train_no integer,
 seq smallint,
 station_code text NOT NULL REFERENCES stations(station_code),
 following_station_order smallint,
 following_station_code text NOT NULL REFERENCES stations(station_code),
 CONSTRAINT train_following_stations_rows_pk PRIMARY KEY (train_no, seq, station_code, following_station_order),
 FOREIGN KEY (train_no, seq) REFERENCES train_stations(train_no, seq));

INSERT INTO train_following_stations_rows
(train_no, seq, station_code, following_station_order, following_station_code)
SELECT t_f_s.train_no, t_f_s.seq, t_f_s.station_code, f.station_order, f.station 
FROM train_following_stations t_f_s, unnest(t_f_s.following_stations) WITH ORDINALITY f(station, station_order);

CREATE INDEX train_following_stations_rows_search_ix ON train_following_stations_rows (station_code, following_station_code);

EOF



