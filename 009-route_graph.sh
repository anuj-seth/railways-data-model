#!/usr/bin/env bash

pguser=$1
pgdb=$2
pgpassword=$3

export PGPASSWORD=${pgpassword}

psql -U $pguser -d $pgdb -h 127.0.0.1 <<EOF

CREATE TABLE trains_route_graph
( train_no integer,
  origin_seq smallint,
  origin_station_code text NOT NULL REFERENCES stations(station_code),
  departure_from_origin time without time zone NOT NULL,
  destination_seq smallint,
  destination_station_code text NOT NULL REFERENCES stations(station_code),
  arrival_at_destination time without time zone NOT NULL,
  CONSTRAINT trains_route_graph_pk PRIMARY KEY (train_no, origin_station_code, destination_station_code),
  CONSTRAINT trains_route_graph_origin_fk FOREIGN KEY (train_no, origin_seq) REFERENCES train_stations(train_no, seq),
  CONSTRAINT trains_route_graph_destination_fk FOREIGN KEY (train_no, destination_seq) REFERENCES train_stations(train_no, seq));

INSERT INTO trains_route_graph
(train_no, origin_seq, origin_station_code, departure_from_origin, destination_seq, destination_station_code, arrival_at_destination)
SELECT origin.train_no,
       origin.seq AS origin_seq,
       origin.station_code AS origin_station_code,
       departures.departure_time AS departure_from_origin,
       destination.seq as destination_seq,
       destination.station_code AS destination_station_code,
       arrivals.arrival_time AS arrival_at_destination
FROM train_stations origin
JOIN train_departures departures ON departures.train_no = origin.train_no AND departures.seq = origin.seq
JOIN train_stations destination ON destination.train_no = origin.train_no AND destination.seq = origin.seq + 1
JOIN train_arrivals arrivals ON arrivals.train_no = destination.train_no AND arrivals.seq = destination.seq;
--WHERE origin.station_code = 'SWV'
--ORDER BY origin.train_no, origin.seq;

EOF


