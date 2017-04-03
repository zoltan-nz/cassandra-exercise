CREATE KEYSPACE If NOT EXISTS tranz with replication = {'class': 'NetworkTopologyStrategy', 'datacenter1': 6};
USE tranz;

CREATE TABLE IF NOT EXISTS tranz.driver (
  driver_name TEXT,
  password TEXT,
  mobile INT,
  current_position TEXT,
  skill SET<TEXT>,
  PRIMARY KEY (driver_name)
);

CREATE TABLE IF NOT EXISTS tranz.vehicle (
  vehicle_id TEXT,
  status TEXT,
  type TEXT,
  PRIMARY KEY (vehicle_id)
);

CREATE TABLE IF NOT EXISTS tranz.time_table (
  line_name TEXT,
  service_no INT,
  station_name TEXT,
  latitude DOUBLE,
  longitude DOUBLE,
  time INT,
  distance DOUBLE,
  PRIMARY KEY (line_name, service_no, time)
) WITH CLUSTERING ORDER BY (service_no ASC, time ASC);

CREATE TABLE IF NOT EXISTS tranz.vehicle_usage (
  vehicle_id TEXT,
  date TIMESTAMP,
  total_distance COUNTER,
  PRIMARY KEY (vehicle_id, date)
);

CREATE TABLE IF NOT EXISTS data_point (
  day INT,
  sequence TIMESTAMP
);

CREATE TABLE station (

);

CREATE TABLE driver_working_days (

);
