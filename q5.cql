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
