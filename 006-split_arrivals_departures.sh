#!/usr/bin/env bash

pguser=$1
pgdb=$2
pgpassword=$3

export PGPASSWORD=${pgpassword}

psql -U $pguser -d $pgdb -h 127.0.0.1 <<EOF

DROP TABLE IF EXISTS train_arrivals CASCADE;

CREATE TABLE train_arrivals
(train_no integer,
 seq smallint,
 arrival_time time without time zone NOT NULL,
 CONSTRAINT train_arrivals_pk PRIMARY KEY (train_no, seq),
 CONSTRAINT train_arrivals_fk FOREIGN KEY (train_no, seq) REFERENCES train_stations(train_no, seq));

INSERT INTO train_arrivals (train_no, seq, arrival_time)
SELECT train_no, seq, arrival_time
FROM train_stations
WHERE arrival_time is not null;

DROP TABLE IF EXISTS train_departures CASCADE;

CREATE TABLE train_departures
(train_no integer,
 seq smallint,
 departure_time time without time zone NOT NULL,
 CONSTRAINT train_departures_pk PRIMARY KEY (train_no, seq),
 CONSTRAINT train_departures_fk FOREIGN KEY (train_no, seq) REFERENCES train_stations(train_no, seq));

INSERT INTO train_departures (train_no, seq, departure_time)
SELECT train_no, seq, departure_time
FROM train_stations
WHERE departure_time is not null;

ALTER TABLE train_stations DROP COLUMN arrival_time;

ALTER TABLE train_stations DROP COLUMN departure_time;

EOF
