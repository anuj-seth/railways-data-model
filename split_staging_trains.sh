pguser=$1
pgdb=$2
pgpassword=$3

export PGPASSWORD=${pgpassword}

psql -U $pguser -d $pgdb -h 127.0.0.1 <<EOF

drop table if exists trains;

create table trains
(train_no integer primary key,
 train_name text,
 source_station text,
 source_station_name text,
 destination_station text,
 destination_station_name text);

insert into trains (train_no, train_name, source_station, source_station_name, destination_station, destination_station_name)
select distinct train_no, train_name, source_station, source_station_name, destination_station, destination_station_name from staging_trains;

drop table if exists train_stations;

create table train_stations
(train_no integer,
 seq smallint,
 station_code text,
 station_name text,
 arrival_time time without time zone,
 departure_time time without time zone,
 distance smallint,
 constraint train_station_seq primary key (train_no, seq));

insert into train_stations (train_no, seq, station_code, station_name, arrival_time, departure_time, distance)
select train_no, seq, station_code, station_name, arrival_time, departure_time, distance from staging_trains;
EOF


