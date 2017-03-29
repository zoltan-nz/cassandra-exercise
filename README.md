# Cassandra Exercise

* [Assigment](./assignment.pdf)

# Assignment Questions

## Question 1.
List the database write and update requests the application requires using plain English. [10 marks]

1. ADMINISTRATOR creates a keyspace for the application. Keyspace name: `tranz_metro`.

2. ADMINISTRATOR creates accounts for drivers:

    2.1 Create a table for drivers if not exists. Table name: `driver`. Columns: `driver_name` (unique, if not exists), `password` (string), `mobile` (number), `current_position` (string), `skill` (`set` type with strings).

    2.2 Seed the initial drivers data.

3. DRIVERS updates:

    3.1 Drivers can change their password. They provide `old_password` and `new_password`. Update the driver's row with `new_password` only if the `old_password` equal with the stored `password`. If the conditions apply, `password` will be equal with `new_password`.

    3.2 Drivers can update their `current_position`: (with city name string) `'Wellington'` OR (with vehicle) `vehicle_id` OR (with not available string constant) `'not_available'`

    3.3 Drivers can add new skill to `skill` column. Skill column type is `SET<string>`.

4. ADMINISTRATOR initializes vehicles:

    4.1 Create a table for vehicles. Table name: `vehicles`. Columns: `vehicle_id` (uuid, unique, if not exists), `status` (string), type (string)

    4.2 Seed the initial vehicles data.

5. Update status of a vehicle. Station name OR `in_use` OR `maintenance` OR `out_of_order`.

6. ADMINISTRATOR initializes timetables:

    6.1 Create a table for timetables. Table name: `time_table`. Columns: `line_name` (unique, if not exists, string), `service_no` (number, asc within line_name), `sequence` (map type: station_name, time, distance) Notes: time are departure times, except the last (destination) time, it is arrival time. `sequence` sorted `asc` by `time`.

## Question 2.
List the read requests the application requires using plain English. [12 marks]

1. Read the number of working days of a driver. (Payroll will use this information.)

## Question 3.
Consider Cassandra data model design guidelines we discussed in lectures and list names of database tables the application requires using plain English. Recall, Cassandra tables strongly depend on requested queries. If there is no queries needing a table, the table should not exist. (Don’t invent queries to justify the existence of any tables.) After each table name, list those queries you identified in your answer to question 2 that use the table.
[9 marks]

## Question 4.
A/ Create data model using CQL 3 statements that support the requirements. To answer questions, use Cassandra CCM. In your answers, copy your CCM and CQL commands.
[20 marks]

B/ Create a cluster and a keyspace that will satisfy infrastructure and availability requirements above.
[5 marks]

C/ Define tables listed in your answer to question 3 above. For the table definitions include any non default property settings. Optimize your database solution just for iPhone application queries you identified in question 2 above.
[15 marks]

## Question 5.
Provide CQL3 statements to support each of the application write and update requests you specified in Question 1 above. Show the consistency level before each write and update statement.
[20 marks]

## Question 6.
Provide CQL3 statements to support each of the application read requests you specified in Question 2 above. Show the consistency level before each read statement. In your answer copy your CQL statement and the result produced by Cassandra from the screen.
[29 marks]