#!/usr/bin/env bash

pguser=$1
pgdb=$2
pgpassword=$3

export PGPASSWORD=${pgpassword}

psql -U $pguser -d $pgdb -h 127.0.0.1 <<EOF
drop table if exists staging_trains;

create table staging_trains
(train_no integer,
 train_name text,
 seq smallint,
 station_code text,
 station_name text,
 arrival_time time without time zone,
 departure_time time without time zone,
 distance smallint,
 source_station text,
 source_station_name text,
 destination_station text,
 destination_station_name text);

drop table if exists day_of_week;

create table day_of_week
(day_number smallint,
 one_letter_abbreviation varchar(1),
 two_letter_abbreviation varchar(2),
 three_letter_abbreviation varchar(3),
 full_name text);
insert into day_of_week
values
(0, 'S', 'Su', 'Sun', 'Sunday'),
(1, 'M', 'Mo', 'Mon', 'Monday'),
(2, 'T', 'Tu', 'Tue', 'Tuesday'),
(3, 'W', 'We', 'Wed', 'Wednesday'),
(4, 'T', 'Th', 'Thu', 'Thursday'),
(5, 'F', 'Fr', 'Fri', 'Friday'),
(6, 'S', 'Sa', 'Sat', 'Saturday');
EOF


