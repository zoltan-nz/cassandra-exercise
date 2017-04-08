USE ass2;

CREATE table driver (
  driver_name text,
  email text,
  password text,
  mobile int,
  current_position text,
  skill SET<text>,
  primary key (driver_name)) 
  WITH compaction = {'class':'LeveledCompactionStrategy'} AND dclocal_read_repair_chance = 1;

CREATE INDEX driver_skill_idx ON driver (values(skill));
CREATE INDEX driver_current_position_idx ON driver (current_position);

CREATE table vehicle (
  vehicle_id text, 
  status text, 
  type text, 
  primary key (vehicle_id)) 
  WITH compaction = {'class':'LeveledCompactionStrategy'};

CREATE INDEX veh_stat_idx ON vehicle (status);

CREATE table time_table (
  line_name text, 
  service_no int, 
  time int, 
  distance double, 
  latitude double, 
  longitude double, 
  stop text,
  primary key ((line_name, service_no), time))
  WITH clustering ORDER BY (time DESC);

CREATE table data_point (
  line_name text, 
  service_no int, 
  date int, 
  sequence timestamp, 
  longitude double, 
  latitude double,
  speed double, 
  primary key ((line_name, service_no, date), sequence))
  WITH clustering ORDER BY (sequence DESC);

