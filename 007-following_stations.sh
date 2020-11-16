#!/usr/bin/env bash

pguser=$1
pgdb=$2
pgpassword=$3

export PGPASSWORD=${pgpassword}

psql -U $pguser -d $pgdb -h 127.0.0.1 <<EOF

DROP TABLE IF EXISTS train_following_stations;

CREATE TABLE train_following_stations
(train_no integer,
 seq smallint,
 station_code text NOT NULL REFERENCES stations(station_code),
 following_stations text ARRAY NOT NULL,
 CONSTRAINT train_following_stations_pk PRIMARY KEY (train_no, seq, station_code),
 FOREIGN KEY (train_no, seq) REFERENCES train_stations(train_no, seq));

CREATE INDEX train_following_stations_following_stations_idx ON train_following_stations USING GIN (following_stations);

INSERT INTO train_following_stations
SELECT *
FROM (SELECT train_no,
             seq,
             station_code,
             array_agg(station_code) OVER following_stations_window AS following_stations
      FROM train_stations
      WINDOW following_stations_window AS (PARTITION BY train_no ORDER BY seq ASC ROWS BETWEEN 1 following AND unbounded following)) AS foo
WHERE foo.following_stations IS NOT NULL;

EOF
