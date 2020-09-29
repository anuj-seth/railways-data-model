#!/usr/bin/env bash

pguser=$1
pgdb=$2
pgpassword=$3

export PGPASSWORD=${pgpassword}

psql -U $pguser -d $pgdb -h 127.0.0.1 <<EOF

drop table if exists trains;

CREATE TABLE trains
(train_no integer PRIMARY KEY,
 train_name text NOT NULL,
 source_station_code text NOT NULL REFERENCES stations(station_code),
 destination_station_code text NOT NULL REFERENCES stations(station_code));

CREATE INDEX trains_source_station_code_idx ON trains(source_station_code);

CREATE INDEX trains_destination_station_code_idx ON trains(destination_station_code);

INSERT INTO trains
(train_no, train_name, source_station_code, destination_station_code)
SELECT distinct train_no, train_name, source_station, destination_station FROM staging_trains;

DROP TABLE IF EXISTS train_stations;

CREATE TABLE train_stations
(train_no integer,
 seq smallint,
 station_code text NOT NULL REFERENCES stations(station_code),
 arrival_time time without time zone NOT NULL,
 departure_time time without time zone NOT NULL,
 distance_from_origin smallint NOT NULL,
 CONSTRAINT train_stations_pk PRIMARY KEY (train_no, seq));

CREATE INDEX train_stations_station_code_idx ON train_stations(station_code);

INSERT INTO train_stations
(train_no, seq, station_code, arrival_time, departure_time, distance_from_origin)
SELECT train_no, seq, station_code, arrival_time, departure_time, distance FROM staging_trains;


EOF


