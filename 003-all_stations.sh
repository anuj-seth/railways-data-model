#!/usr/bin/env bash

pguser=$1
pgdb=$2
pgpassword=$3

export PGPASSWORD=${pgpassword}

psql -U $pguser -d $pgdb -h 127.0.0.1 <<EOF

create temp table all_stations as
select station_code, station_name from staging_trains
union
select source_station, source_station_name from staging_trains
union
select destination_station, destination_station_name from staging_trains;

create temp table all_stations_ranked as
select station_code, station_name, rank() over (partition by station_code order by length(station_name) desc) as r
from all_stations;

drop table if exists stations cascade;
create table stations as
select station_code, station_name from all_stations_ranked where r = 1;

alter table stations add primary key (station_code);
EOF
