#!/usr/bin/env bash

pguser=$1
pgdb=$2
pgpassword=$3

export PGPASSWORD=${pgpassword}

psql -U $pguser -d $pgdb -h 127.0.0.1 <<EOF

drop table if exists trains;

create table trains
(train_no integer primary key,
 train_name text,
 source_station_code text references stations(station_code),
 destination_station_code text references stations(station_code));

insert into trains (train_no, train_name, source_station_code, destination_station_code)
select distinct train_no, train_name, source_station, destination_station from staging_trains;

drop table if exists train_stations;

create table train_stations
(train_no integer,
 seq smallint,
 station_code text references stations(station_code),
 arrival_time time without time zone,
 departure_time time without time zone,
 distance_from_origin smallint,
 constraint train_stations_pk primary key (train_no, seq));

insert into train_stations (train_no, seq, station_code, arrival_time, departure_time, distance_from_origin)
select train_no, seq, station_code, arrival_time, departure_time, distance from staging_trains;


EOF


