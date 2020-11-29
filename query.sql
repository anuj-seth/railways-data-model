CREATE TABLE

SELECT count(*)

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


with recursive multi_train_journeys as
(select train_no, origin_seq, origin_station_code, departure_from_origin, destination_seq, destination_station_code, arrival_at_destination, 0 as depth
from trains_route_graph
where origin_station_code = 'JUC'
UNION --ALL
select t_r_g.train_no, t_r_g.origin_seq, t_r_g.origin_station_code, t_r_g.departure_from_origin, t_r_g.destination_seq, t_r_g.destination_station_code, t_r_g.arrival_at_destination, m_t_j.depth + 1 as depth
from trains_route_graph t_r_g
join multi_train_journeys m_t_j on m_t_j.destination_station_code = t_r_g.origin_station_code
where t_r_g.destination_station_code <> m_t_j.origin_station_code
and m_t_j.depth < 2
)
select max(depth) from multi_train_journeys;

