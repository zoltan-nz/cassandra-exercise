-- This file is just a merged version of reset.cql, q4.cql, q5.cql and q6.cql

-- RESET
DROP TABLE IF EXISTS tranz.driver;
DROP TABLE IF EXISTS tranz.vehicle;
DROP TABLE IF EXISTS tranz.time_table;
DROP TABLE IF EXISTS tranz.vehicle_usage;
DROP TABLE IF EXISTS tranz.data_point;
DROP TABLE IF EXISTS tranz.driver_working_days;

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

-- ANSWERS FOR QUESTION 5

-- 2.2 Seed the initial drivers data.
/*
==========================================================================
driver_name     current_position    mobile      password       skill
--------------------------------------------------------------------------
milan           Upper Hutt          211111      mm77          { Matangi }
pavle           Upper Hutt          213344      pm33          { Ganz Mavag, Guliver }
pondy           Wellington          216677      pondy         { Matangi, Kiwi Rail }
fred            Taita               210031      f5566f        { Gulliver, Ganz Mavag }
jane            Waikanae            213141      jjjj          { Matangi }
==========================================================================
*/

-- For strong consistency we have to use quorum.
CONSISTENCY QUORUM;
INSERT INTO tranz.driver
  (driver_name, current_position, mobile, password, skill )
  VALUES ('milan', 'Upper Hutt', 211111, 'mm77', { 'Matangi' })
  IF NOT EXISTS;

CONSISTENCY QUORUM;
INSERT INTO tranz.driver
  (driver_name, current_position, mobile, password, skill )
  VALUES ('pavle', 'Upper Hutt', 213344, 'pm33', { 'Ganz Mavag', 'Guliver' })
  IF NOT EXISTS;

CONSISTENCY QUORUM;
INSERT INTO tranz.driver
  (driver_name, current_position, mobile, password, skill )
  VALUES ('pondy', 'Wellington', 216677, 'pondy', { 'Matangi', 'Kiwi Rail' })
  IF NOT EXISTS;

CONSISTENCY QUORUM;
INSERT INTO tranz.driver
  (driver_name, current_position, mobile, password, skill )
  VALUES ('fred', 'Taita', 210031, 'f5566f', { 'Gulliver', 'Ganz Mavag' })
  IF NOT EXISTS;

CONSISTENCY QUORUM;
INSERT INTO tranz.driver
  (driver_name, current_position, mobile, password, skill )
  VALUES ('jane', 'Waikanae', 213141, 'jjjj', { 'Matangi' })
  IF NOT EXISTS;

-- 3.1 Drivers can change their password. They provide `old_password` and `new_password`. Update the driver's row with `new_password` only if the `old_password` equal with the stored `password`. If the conditions apply, `password` will be equal with `new_password`.
CONSISTENCY QUORUM;
UPDATE tranz.driver
  SET password = 'dhy@@EE3#'
  WHERE driver_name = 'pondy'
  IF password = 'pondy';

-- 3.2 Drivers can update their `current_position`: (with city name string) `'Wellington'` OR (with vehicle) `vehicle_id` OR (with not available string constant) `'not_available'`. The update process managed by the app, based on the driver's skill and the location of the train. See Question 2, Read 5.
CONSISTENCY QUORUM;
UPDATE tranz.driver
  SET current_position = 'Petone'
  WHERE driver_name = 'pavle';


-- 3.3 Drivers can add new skill to `skill` column. Skill column type is `SET<string>`.
CONSISTENCY QUORUM;
UPDATE tranz.driver
  SET skill = skill + {'Ganz Mavag'}
  WHERE driver_name = 'milan';


-- 3.4 App updates a counter log table for payrol. See Question 2, Read 1.
CONSISTENCY QUORUM;
UPDATE tranz.driver_working_days
  SET working_day = working_day + 1
  WHERE driver_name = 'jane';

-- 4.2 Seed the initial vehicles data.
/*
=============================================
vehicle_id        status          type
---------------------------------------------
FA1122            Upper Hutt      Matangi
FP8899            maintenance     Ganz Mavag
FA4864            Wellington      Matangi
KW3300            Wellington      KiwiRail
=============================================
*/

CONSISTENCY QUORUM;
INSERT INTO tranz.vehicle
  (vehicle_id, status, type )
  VALUES ('FA1122', 'Upper Hutt', 'Matangi')
  IF NOT EXISTS;

CONSISTENCY QUORUM;
INSERT INTO tranz.vehicle
  (vehicle_id, status, type )
  VALUES ('FP8899', 'maintenance', 'Ganz Mavag')
  IF NOT EXISTS;

CONSISTENCY QUORUM;
INSERT INTO tranz.vehicle
  (vehicle_id, status, type )
  VALUES ('FA4864', 'Wellington', 'Matangi')
  IF NOT EXISTS;

CONSISTENCY QUORUM;
INSERT INTO tranz.vehicle
  (vehicle_id, status, type )
  VALUES ('KW3300', 'Wellington', 'KiwiRail')
  IF NOT EXISTS;

-- 5. App automatically updates the `status` of a `vehicle`. Station name, like `Wellington` OR `in_use` OR `maintenance` OR `out_of_order`.
-- 5.1 Status will be updated based on timetable (departure). `Status` will be the departure station name. See Question 2, Read 4.
CONSISTENCY QUORUM;
UPDATE tranz.vehicle
  SET status = 'Wellington'
  WHERE vehicle_id = 'FA1122';

--   5.2 `Status` will be updated to `in_use`, when driver turns on the engine.
CONSISTENCY QUORUM;
UPDATE tranz.vehicle
  SET status = 'in_use'
  WHERE vehicle_id = 'KW3300';

-- 5.3 Status will be updated when the driver turns off the engine on the destination station. `status` will be the destination station name.
-- A log event will be called also, see Question 1, Update 7.2.
CONSISTENCY QUORUM;
UPDATE tranz.vehicle
  SET status = 'Upper Hut'
  WHERE vehicle_id = 'FA4864';

-- 6.2 Seed `time_table`.
/*
============================================================================================
line_name,               service_no, station_name, longitude, latitude, time, distance
--------------------------------------------------------------------------------------------
'Hutt Valley Line (north bound)', 1, 'Wellington', 174.7762, -41.2865, 605, 0
'Hutt Valley Line (north bound)', 1, 'Petone', 174.8851, -41.227, 617, 8.3
'Hutt Valley Line (north bound)', 1, 'Waterloo', 174.9081, -41.2092, 625, 13.3
'Hutt Valley Line (north bound)', 1, 'Taita', 174.9608, -41.1798, 634, 19.0
'Hutt Valley Line (north bound)', 1, 'Silverstream', 175.010276, -41.147283, 642, 26.5
'Hutt Valley Line (north bound)', 1, 'Upper Hutt', 175.0708, -41.1244, 650, 34.3
'Hutt Valley Line (north bound)', 11, 'Wellington', 174.7762, -41.2865, 1935, 0
'Hutt Valley Line (north bound)', 11, 'Petone', 174.8851, -41.227, 1947, 8.3
'Hutt Valley Line (north bound)', 11, 'Woburn', 174.911249, -41.220841, 1950, 11.0
'Hutt Valley Line (north bound)', 11, 'Waterloo', 174.9081, -41.2092, 1955, 13.3
'Hutt Valley Line (north bound)', 11, 'Naenae', 174.946160, -41.197805, 2001, 16.9
'Hutt Valley Line (north bound)', 11, 'Taita', 174.9608, -41.1798, 2010, 19.0
'Hutt Valley Line (north bound)', 11, 'Silverstream', 175.010276, -41.147283, 2019, 26.5
'Hutt Valley Line (north bound)', 11, 'Upper Hutt', 175.0708, -41.1244, 2025, 34.3

'Hutt Valley Line (south bound)', 2, 'Upper Hutt', 175.0708, -41.1244, 700, 0
'Hutt Valley Line (south bound)', 2, 'Silverstream', 175.010276, -41.147283, 708, 7.8
'Hutt Valley Line (south bound)', 2, 'Taita', 174.9608, -41.1798, 716, 15.03
'Hutt Valley Line (south bound)', 2, 'Woburn', 174.911249, -41.220841, 725, 23.3
'Hutt Valley Line (south bound)', 2, 'Wellington', 174.7762, -41.2865, 745, 34.3
'Hutt Valley Line (south bound)', 12, 'Upper Hutt', 175.0708, -41.1244, 1900, 0
'Hutt Valley Line (south bound)', 12, 'Silverstream', 175.010276, -41.147283, 1907, 7.8
'Hutt Valley Line (south bound)', 12, 'Taita', 174.9608, -41.1798, 1918, 15.03
'Hutt Valley Line (south bound)', 12, 'Naenae', 174.946160, -41.197805, 1927, 17.04
'Hutt Valley Line (south bound)', 12, 'Waterloo', 174.9081, -41.2092, 2028, 21.0
'Hutt Valley Line (south bound)', 12, 'Woburn', 174.911249, -41.220841, 2030, 23.3
'Hutt Valley Line (south bound)', 12, 'Petone', 174.8851, -41.227, 2035, 26.0
'Hutt Valley Line (south bound)', 12, 'Wellington', 174.7762, -41.2865, 2050, 34.3

'Waikanae Line (north bound)', 5, 'Wellington', 174.7762, -41.2865, 1025, 0
'Waikanae Line (north bound)', 5, 'Paekakariki', 174.951, -40.9881, 1059, 33.1
'Waikanae Line (north bound)', 5, 'Paraparaumu', 175.0084, -40.9142, 1118, 51.3
'Waikanae Line (north bound)', 5, 'Waikanae', 175.0668, -40.8755, 1139, 62.8
===========================================================================================
*/

-- Based on consistency requirement, timetable data can be eventually consistent.
CONSISTENCY ONE;
INSERT INTO tranz.time_table (line_name, service_no, station_name, longitude, latitude, time, distance) VALUES ('Hutt Valley Line (north bound)', 1, 'Wellington', 174.7762, -41.2865, 605, 0) IF NOT EXISTS;
INSERT INTO tranz.time_table (line_name, service_no, station_name, longitude, latitude, time, distance) VALUES ('Hutt Valley Line (north bound)', 1, 'Petone', 174.8851, -41.227, 617, 8.3) IF NOT EXISTS;
INSERT INTO tranz.time_table (line_name, service_no, station_name, longitude, latitude, time, distance) VALUES ('Hutt Valley Line (north bound)', 1, 'Waterloo', 174.9081, -41.2092, 625, 13.3) IF NOT EXISTS;
INSERT INTO tranz.time_table (line_name, service_no, station_name, longitude, latitude, time, distance) VALUES ('Hutt Valley Line (north bound)', 1, 'Taita', 174.9608, -41.1798, 634, 19.0) IF NOT EXISTS;
INSERT INTO tranz.time_table (line_name, service_no, station_name, longitude, latitude, time, distance) VALUES ('Hutt Valley Line (north bound)', 1, 'Silverstream', 175.010276, -41.147283, 642, 26.5) IF NOT EXISTS;
INSERT INTO tranz.time_table (line_name, service_no, station_name, longitude, latitude, time, distance) VALUES ('Hutt Valley Line (north bound)', 1, 'Upper Hutt', 175.0708, -41.1244, 650, 34.3) IF NOT EXISTS;
INSERT INTO tranz.time_table (line_name, service_no, station_name, longitude, latitude, time, distance) VALUES ('Hutt Valley Line (north bound)', 11, 'Wellington', 174.7762, -41.2865, 1935, 0) IF NOT EXISTS;
INSERT INTO tranz.time_table (line_name, service_no, station_name, longitude, latitude, time, distance) VALUES ('Hutt Valley Line (north bound)', 11, 'Petone', 174.8851, -41.227, 1947, 8.3) IF NOT EXISTS;
INSERT INTO tranz.time_table (line_name, service_no, station_name, longitude, latitude, time, distance) VALUES ('Hutt Valley Line (north bound)', 11, 'Woburn', 174.911249, -41.220841, 1950, 11.0) IF NOT EXISTS;
INSERT INTO tranz.time_table (line_name, service_no, station_name, longitude, latitude, time, distance) VALUES ('Hutt Valley Line (north bound)', 11, 'Waterloo', 174.9081, -41.2092, 1955, 13.3) IF NOT EXISTS;
INSERT INTO tranz.time_table (line_name, service_no, station_name, longitude, latitude, time, distance) VALUES ('Hutt Valley Line (north bound)', 11, 'Naenae', 174.946160, -41.197805, 2001, 16.9) IF NOT EXISTS;
INSERT INTO tranz.time_table (line_name, service_no, station_name, longitude, latitude, time, distance) VALUES ('Hutt Valley Line (north bound)', 11, 'Taita', 174.9608, -41.1798, 2010, 19.0) IF NOT EXISTS;
INSERT INTO tranz.time_table (line_name, service_no, station_name, longitude, latitude, time, distance) VALUES ('Hutt Valley Line (north bound)', 11, 'Silverstream', 175.010276, -41.147283, 2019, 26.5) IF NOT EXISTS;
INSERT INTO tranz.time_table (line_name, service_no, station_name, longitude, latitude, time, distance) VALUES ('Hutt Valley Line (north bound)', 11, 'Upper Hutt', 175.0708, -41.1244, 2025, 34.3) IF NOT EXISTS;
INSERT INTO tranz.time_table (line_name, service_no, station_name, longitude, latitude, time, distance) VALUES ('Hutt Valley Line (south bound)', 2, 'Upper Hutt', 175.0708, -41.1244, 700, 0) IF NOT EXISTS;
INSERT INTO tranz.time_table (line_name, service_no, station_name, longitude, latitude, time, distance) VALUES ('Hutt Valley Line (south bound)', 2, 'Silverstream', 175.010276, -41.147283, 708, 7.8) IF NOT EXISTS;
INSERT INTO tranz.time_table (line_name, service_no, station_name, longitude, latitude, time, distance) VALUES ('Hutt Valley Line (south bound)', 2, 'Taita', 174.9608, -41.1798, 716, 15.03) IF NOT EXISTS;
INSERT INTO tranz.time_table (line_name, service_no, station_name, longitude, latitude, time, distance) VALUES ('Hutt Valley Line (south bound)', 2, 'Woburn', 174.911249, -41.220841, 725, 23.3) IF NOT EXISTS;
INSERT INTO tranz.time_table (line_name, service_no, station_name, longitude, latitude, time, distance) VALUES ('Hutt Valley Line (south bound)', 2, 'Wellington', 174.7762, -41.2865, 745, 34.3) IF NOT EXISTS;
INSERT INTO tranz.time_table (line_name, service_no, station_name, longitude, latitude, time, distance) VALUES ('Hutt Valley Line (south bound)', 12, 'Upper Hutt', 175.0708, -41.1244, 1900, 0) IF NOT EXISTS;
INSERT INTO tranz.time_table (line_name, service_no, station_name, longitude, latitude, time, distance) VALUES ('Hutt Valley Line (south bound)', 12, 'Silverstream', 175.010276, -41.147283, 1907, 7.8) IF NOT EXISTS;
INSERT INTO tranz.time_table (line_name, service_no, station_name, longitude, latitude, time, distance) VALUES ('Hutt Valley Line (south bound)', 12, 'Taita', 174.9608, -41.1798, 1918, 15.03) IF NOT EXISTS;
INSERT INTO tranz.time_table (line_name, service_no, station_name, longitude, latitude, time, distance) VALUES ('Hutt Valley Line (south bound)', 12, 'Naenae', 174.946160, -41.197805, 1927, 17.04) IF NOT EXISTS;
INSERT INTO tranz.time_table (line_name, service_no, station_name, longitude, latitude, time, distance) VALUES ('Hutt Valley Line (south bound)', 12, 'Waterloo', 174.9081, -41.2092, 2028, 21.0) IF NOT EXISTS;
INSERT INTO tranz.time_table (line_name, service_no, station_name, longitude, latitude, time, distance) VALUES ('Hutt Valley Line (south bound)', 12, 'Woburn', 174.911249, -41.220841, 2030, 23.3) IF NOT EXISTS;
INSERT INTO tranz.time_table (line_name, service_no, station_name, longitude, latitude, time, distance) VALUES ('Hutt Valley Line (south bound)', 12, 'Petone', 174.8851, -41.227, 2035, 26.0) IF NOT EXISTS;
INSERT INTO tranz.time_table (line_name, service_no, station_name, longitude, latitude, time, distance) VALUES ('Hutt Valley Line (south bound)', 12, 'Wellington', 174.7762, -41.2865, 2050, 34.3) IF NOT EXISTS;
INSERT INTO tranz.time_table (line_name, service_no, station_name, longitude, latitude, time, distance) VALUES ('Waikanae Line (north bound)', 5, 'Wellington', 174.7762, -41.2865, 1025, 0) IF NOT EXISTS;
INSERT INTO tranz.time_table (line_name, service_no, station_name, longitude, latitude, time, distance) VALUES ('Waikanae Line (north bound)', 5, 'Paekakariki', 174.951, -40.9881, 1059, 33.1) IF NOT EXISTS;
INSERT INTO tranz.time_table (line_name, service_no, station_name, longitude, latitude, time, distance) VALUES ('Waikanae Line (north bound)', 5, 'Paraparaumu', 175.0084, -40.9142, 1118, 51.3) IF NOT EXISTS;
INSERT INTO tranz.time_table (line_name, service_no, station_name, longitude, latitude, time, distance) VALUES ('Waikanae Line (north bound)', 5, 'Waikanae', 175.0668, -40.8755, 1139, 62.8) IF NOT EXISTS;

-- 7. Recording the travelled distance of a vehicle.
-- 7.2 This log will run after the app updated the vehicle `status`. See Question 1, Update 5.3. Distance information comes from Question 2, Read 7.

-- Vehicle related data has to be strongly consistent.
CONSISTENCY QUORUM;
UPDATE tranz.vehicle_usage
  SET total_distance = total_distance + 34
  WHERE vehicle_id = 'FA1122';

-- 8. Recording data points after the vehicle's engine started.
-- 8.2 The app creates a new log entry in this table in every 10 seconds, when the vehicle's engine is on.

/*
================================================
day,      sequence,    longitude, latitude, speed
------------------------------------------------
20170322, 10:37:50+1300, 174.77, -41.2262, 29.1
20170326, 10:07:40+1300, 175, -41.2012, 70.1
20170326, 10:02:10+1300, 175.07, -41.1255, 40.5
20170326, 10:49:40+1300, 174.8, -41.968, 30.8
20170326, 10:48:40+1300, 176.06, -41.3, 38
20170326, 10:48:10+1300, 175.89, -41.523, 67.6
20170326, 10:47:40+1300, 175.44, -40.081, 54
20170326, 10:47:10+1300, 174.8, -40.478, 36
================================================
*/

-- "Reading Data Point and other data may be eventually consistent."
CONSISTENCY ONE;
INSERT INTO tranz.data_point (day, sequence, longitude, latitude, speed) VALUES (20170322, '2017-03-22 10:37:50+1300', 174.77, -41.2262, 29.1);
INSERT INTO tranz.data_point (day, sequence, longitude, latitude, speed) VALUES (20170326, '2017-03-26 10:07:40+1300', 175, -41.2012, 70.1);
INSERT INTO tranz.data_point (day, sequence, longitude, latitude, speed) VALUES (20170326, '2017-03-26 10:02:10+1300', 175.07, -41.1255, 40.5);
INSERT INTO tranz.data_point (day, sequence, longitude, latitude, speed) VALUES (20170326, '2017-03-26 10:49:40+1300', 174.8, -41.968, 30.8);
INSERT INTO tranz.data_point (day, sequence, longitude, latitude, speed) VALUES (20170326, '2017-03-26 10:48:40+1300', 176.06, -41.3, 38);
INSERT INTO tranz.data_point (day, sequence, longitude, latitude, speed) VALUES (20170326, '2017-03-26 10:48:10+1300', 175.89, -41.523, 67.6);
INSERT INTO tranz.data_point (day, sequence, longitude, latitude, speed) VALUES (20170326, '2017-03-26 10:47:40+1300', 175.44, -40.081, 54);
INSERT INTO tranz.data_point (day, sequence, longitude, latitude, speed) VALUES (20170326, '2017-03-26 10:47:10+1300', 174.8, -40.478, 36);

-- ANSWERS FOR QUESTION 6

-- 1. Read the number of working days of a driver. (Payroll will use this information.). App collects this information in a separate table. Table name: `driver_working_days`, Columns: `driver_name` (unique, string), `working_day` (counter). This is a counter table and the app will update the counter, when the driver starts to work.
CONSISTENCY QUORUM;
SELECT * FROM tranz.driver_working_days WHERE driver_name = 'jane';

-- 2. Read timetable data for showing timetable for passengers. Requested columns from `time_table` table: `line_name`, `station_name`, `time`.
CONSISTENCY ONE;
SELECT line_name, station_name, time FROM tranz.time_table;

-- 3. Application can list `station_name`, `service_no`, `time` from `time_table`. `desc` sorted by `time`.
-- The sorting is ASC in this table, the data will be provided as ordered by ASC.
CONSISTENCY ONE;
SELECT station_name, service_no, time FROM tranz.time_table;

-- 4. The iPhone app, which is on the train can read `station_name`, `time`, `line_name`, `service_no`. The iPhone app connected with a train with `line_name` and `service_no`. If the `line_name`, `service_no` and `time` matches, we can update the vehicle status. See Question 1, Update 5.1
CONSISTENCY ONE;
SELECT station_name, time, line_name, service_no FROM tranz.time_table WHERE line_name = 'Hutt Valley Line (north bound)' AND service_no = 11 LIMIT 1;

-- 5. The application runs a query to list trains on a station. The application reads from `driver` table driver's `current_position` and check their `skill` values. If the list of skills contains the `vehicle`'s `type`, the driver will get a text message and the driver will be allocated to this train. The driver's `current_postion` will be updated. See Question 1, Update 3.2.
CONSISTENCY QUORUM;
SELECT * FROM tranz.vehicle WHERE status = 'Wellington';

-- Unfortunatelly, the created indexes are not enough, we still have to use ALLOW FILTERING.
-- Custom filter table could help, but some reason, it is not really working, some error always appeared.
CONSISTENCY QUORUM;
SELECT * FROM tranz.driver WHERE current_position = 'Wellington' and skill CONTAINS 'Matangi' ALLOW FILTERING;

-- 6. The app authentication service reads from the database, from `driver` table, `password` column for checking password, which provided by the driver after she/he entered in the vehicle.
-- Return the `driver_name` if the provided authentication data is right, otherwise no matching data, return an empty table.
CONSISTENCY QUORUM;
SELECT driver_name FROM tranz.driver WHERE driver_name = 'pondy' and password = 'dhy@@EE3#';

-- 7. For logging `vehicle_usage`, the app has to be able to read distances from `time_table`. See Question 1, Update 7.2.
-- Need Allow filtering. The `station_name` cannot be primary_key because of time is ordered by ASC.
CONSISTENCY ONE;
SELECT distance FROM tranz.time_table WHERE line_name = 'Hutt Valley Line (north bound)' AND service_no = 1 AND station_name = 'Upper Hutt' ALLOW FILTERING;

-- 8. Readings from `data_point` table:
-- 8.1 Last entry of a service, based on `line_name` and `service_no`.
-- Cassandra stores timestamps in UTC format, cqlsh convert timezones only if pytz python package is installed.
-- Please install with `pip install pytz`.
-- Launch cqlsh with the following command: `TZ=Pacific/Auckland ccm node1 cqlsh`
CONSISTENCY ONE;
SELECT * FROM tranz.data_point WHERE day = 20170326 ORDER BY sequence DESC LIMIT 1;

-- 8.2 List of entries in a time interval (`start_time`, `end_time`). List all the entries, where `sequence` between the given time intervals.
CONSISTENCY ONE;
SELECT * FROM tranz.data_point WHERE day = 20170326 and sequence >= '2017-03-26 10:47:40+1300' and sequence <= '2017-03-26 10:48:40+1300' ORDER BY sequence DESC;

-- 8.3 Find a data point in `data_point` table. It can provide a `time` and `latitude`.
CONSISTENCY ONE;
SELECT dateof(maxtimeuuid(sequence)) as time, latitude FROM tranz.data_point WHERE day = 20170326 ORDER BY sequence DESC LIMIT 1;

-- With results from the above query find the previous and next station in `time_table`. List city names as `north_neighbour` and `south_neighbour`.
CONSISTENCY ONE;
SELECT station_name as north_neighbour from tranz.time_table WHERE latitude > -41.968 AND time > 1049 AND service_no IN (5) LIMIT 1 ALLOW FILTERING;

-- There isn't any city which is southern from this coordinate, so this query return with empty table.
CONSISTENCY ONE;
SELECT station_name as south_neighbour from tranz.time_table WHERE latitude < -41.968 AND time < 1049 AND service_no IN (5) LIMIT 1 ALLOW FILTERING;
