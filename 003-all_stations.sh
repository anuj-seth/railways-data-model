#!/usr/bin/env bash

pguser=$1
pgdb=$2
pgpassword=$3

export PGPASSWORD=${pgpassword}

psql -U $pguser -d $pgdb -h 127.0.0.1 <<EOF

CREATE TEMP TABLE all_stations AS
SELECT station_code, station_name FROM staging_trains
UNION
SELECT source_station, source_station_name FROM staging_trains
UNION
SELECT destination_station, destination_station_name FROM staging_trains;

CREATE TEMP TABLE all_stations_ranked AS
SELECT station_code, station_name, rank() OVER (PARTITION BY station_code ORDER BY length(station_name) desc) AS r
FROM all_stations;

DROP TABLE IF EXISTS stations CASCADE;
CREATE TABLE stations AS
SELECT station_code, station_name FROM all_stations_ranked
WHERE r = 1;

ALTER TABLE stations ADD PRIMARY KEY (station_code);

ALTER TABLE stations ALTER COLUMN station_name SET NOT NULL;
EOF
