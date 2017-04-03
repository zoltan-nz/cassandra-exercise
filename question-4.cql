CREATE KEYSPACE If NOT EXISTS tranz with replication = {'class': 'NetworkTopologyStrategy', 'datacenter1': 6};
USE tranz;

CREATE TABLE driver (

  PRIMARY KEY ((), )
);

CREATE TABLE vehicle (

  PRIMARY KEY ((), )
);

CREATE TABLE time_table (

);

CREATE TABLE vehicle_usage (

);

CREATE TABLE data_point (

);

CREATE TABLE station (

);

CREATE TABLE driver_working_days (

);
