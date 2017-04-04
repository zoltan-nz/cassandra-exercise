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
