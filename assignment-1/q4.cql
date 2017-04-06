-- ANSWERS FOR QUESTION 4

-- 1. Administrator creates a keyspace for the application. Keyspace name: `tranz_metro`.
CREATE KEYSPACE If NOT EXISTS tranz with replication = {'class': 'NetworkTopologyStrategy', 'datacenter1': 6};
USE tranz;

-- 2.1 Create a table for drivers if not exists. Table name: `driver`. Columns: `driver_name` (unique, if not exists, primary key), `password` (string), `mobile` (number), `current_position` (string), `skill` (`set` type with strings).
CREATE TABLE IF NOT EXISTS tranz.driver (
  driver_name TEXT,
  password TEXT,
  mobile INT,
  current_position TEXT,
  skill SET<TEXT>,
  PRIMARY KEY (driver_name)
);

-- We will filter drivers by skill and current_position. See Question 2, Read 5.
CREATE INDEX IF NOT EXISTS driver_skill_index ON tranz.driver (skill);
CREATE INDEX IF NOT EXISTS driver_current_position_index ON tranz.driver (current_position);

-- See Question 2, Read 6.
CREATE INDEX driver_password_index ON tranz.driver (password);

-- 4.1 Create a table for vehicles. Table name: `vehicle`. Columns: `vehicle_id` (string, unique, if not exists), `status` (string), type (string)
CREATE TABLE IF NOT EXISTS tranz.vehicle (
  vehicle_id TEXT,
  status TEXT,
  type TEXT,
  PRIMARY KEY (vehicle_id)
);

-- We will filter vehicles by status. See Question 2, Read 5.
CREATE INDEX vehicle_status_index on tranz.vehicle (status);

-- 6.1 Create a table for timetables. Table name: `time_table`. Columns: `line_name` (unique, if not exists, string), `service_no` (number, asc within line_name), `station_name` (string), `latitude` (double), `longitude` (double), `time` (int), `distance` (double),  Notes: time are departure times, except the last (destination) time, it is arrival time. Sorted `asc` by `time`.
CREATE TABLE IF NOT EXISTS tranz.time_table (
  line_name TEXT,
  service_no INT,
  station_name TEXT,
  longitude DOUBLE,
  latitude DOUBLE,
  time INT,
  distance DOUBLE,
  PRIMARY KEY (line_name, service_no, time)
) WITH CLUSTERING ORDER BY (service_no ASC, time ASC);

-- 7.1 Need a `vehicle_usage` table for logging vehicle usage. Administrator can create this table with the following columns: `vehicle_id`, `total_distance` (counter).
CREATE TABLE IF NOT EXISTS tranz.vehicle_usage (
  vehicle_id TEXT,
  total_distance COUNTER,
  PRIMARY KEY (vehicle_id)
);

-- 8. Recording data points after the vehicle's engine started.
-- 8.1 Administrator create a table. Table name: `data_point`. Columns: `day` (int), `sequence` (timestamp), `latitude` (double), `longitude` (double), `speed` (double)
CREATE TABLE IF NOT EXISTS tranz.data_point (
  day INT,
  sequence TIMESTAMP,
  longitude DOUBLE,
  latitude DOUBLE,
  speed DOUBLE,
  PRIMARY KEY (day, sequence, longitude, latitude)
);

-- Question 2, 1. Read the number of working days of a driver. (Payroll will use this information.). App collects this information in a separate table. Table name: `driver_working_days`, Columns: `driver_name` (unique, string), `working_day` (counter). This is a counter table and the app will update the counter, when the driver starts to work.
CREATE TABLE IF NOT EXISTS tranz.driver_working_days (
  driver_name TEXT,
  working_day COUNTER,
  PRIMARY KEY (driver_name)
);
