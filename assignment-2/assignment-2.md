# Assignment 2

Zoltan Debre - 300360191

## Question 1

(2 marks)

* Use `ccm` to make a single data center Cassandra cluster having 5 nodes call it `single_dc` 
* Start the cluster
* Run the `ccm node1 ring` command 
* Save the output of the ring command for future use and show it in the answer to the question.

```
$ ccm create single_dc --nodes=5
$ ccm start
```

```
$ ccm status -v

Cluster: 'single_dc'
--------------------
node1: UP
       auto_bootstrap=False
       thrift=('127.0.0.1', 9160)
       binary=('127.0.0.1', 9042)
       storage=('127.0.0.1', 7000)
       jmx_port=7100
       remote_debug_port=0
       byteman_port=0
       initial_token=-9223372036854775808
       pid=41519

node3: UP
       auto_bootstrap=False
       thrift=('127.0.0.3', 9160)
       binary=('127.0.0.3', 9042)
       storage=('127.0.0.3', 7000)
       jmx_port=7300
       remote_debug_port=0
       byteman_port=0
       initial_token=-1844674407370955162
       pid=41547

node2: UP
       auto_bootstrap=False
       thrift=('127.0.0.2', 9160)
       binary=('127.0.0.2', 9042)
       storage=('127.0.0.2', 7000)
       jmx_port=7200
       remote_debug_port=0
       byteman_port=0
       initial_token=-5534023222112865485
       pid=41588

node5: UP
       auto_bootstrap=False
       thrift=('127.0.0.5', 9160)
       binary=('127.0.0.5', 9042)
       storage=('127.0.0.5', 7000)
       jmx_port=7500
       remote_debug_port=0
       byteman_port=0
       initial_token=5534023222112865484
       pid=41629

node4: UP
       auto_bootstrap=False
       thrift=('127.0.0.4', 9160)
       binary=('127.0.0.4', 9042)
       storage=('127.0.0.4', 7000)
       jmx_port=7400
       remote_debug_port=0
       byteman_port=0
       initial_token=1844674407370955161
       pid=41665
```

```
$ ccm node1 ring

Datacenter: datacenter1
==========
Address    Rack        Status State   Load            Owns                Token
                                                                          5534023222112865484
127.0.0.1  rack1       Up     Normal  98.97 KiB       40.00%              -9223372036854775808
127.0.0.2  rack1       Up     Normal  98.98 KiB       40.00%              -5534023222112865485
127.0.0.3  rack1       Up     Normal  98.98 KiB       40.00%              -1844674407370955162
127.0.0.4  rack1       Up     Normal  98.98 KiB       40.00%              1844674407370955161
127.0.0.5  rack1       Up     Normal  98.98 KiB       40.00%              5534023222112865484
```

## Question 2

(14 marks)

* a) (2 marks) What is the setting of the `endpoint_snitch` property?

Location of `node1`'s `cassandra.yaml`: `~/.ccm/single_dc/node1/conf/cassandra.yaml`
(You can find a copy of `cassandra.yaml` in `node1` sub-folder.)

```
endpoint_snitch: SimpleSnitch
```

* b) (6 Marks) What is the value of the `initial_token` property?

```
initial_token: -9223372036854775808
```

* Which Cassandra component has calculated it?
 
default partitioner: 
```
Murmur3Partitioner
``` 

* Is there any relationship between `initial_token` property value and the output of the `ccm node1 ring` command?

Yes.

The first node from the ccm node1 ring output:

```
127.0.0.1  rack1       Up     Normal  98.97 KiB       40.00%              -9223372036854775808
```

The hash value of the first node is the same as the `initial_token`.

* c) (2 marks) What is the setting of the `partitioner` property?

```
partitioner: org.apache.cassandra.dht.Murmur3Partitioner
```

* d) (4 marks) What is the setting of the `rpc_address` property?

```
rpc_address: 127.0.0.1
```

* Is there any relationship between `rpc_address` property value and the output of the `ccm node1 ring` command?

Yes, this value is the ip address of the first node

```
127.0.0.1  rack1       Up     Normal  98.97 KiB       40.00%              -9223372036854775808
```

## Question 3. 

(2 marks) Consider the `casssandra.topology.properties` file of `node1` and comment on the relationship between file’s content and the output of the `ccm node1 ring` command.

Location of the file: `~/.ccm/single_dc/node1/conf/cassandra-topology.properties`
(Copy saved in `node1` sub-folder.)

The main content of the property file:

```
# Cassandra Node IP=Data Center:Rack
192.168.1.100=DC1:RAC1
192.168.2.200=DC2:RAC2

10.0.0.10=DC1:RAC1
10.0.0.11=DC1:RAC1
10.0.0.12=DC1:RAC2

10.20.114.10=DC2:RAC1
10.20.114.11=DC2:RAC1

10.21.119.13=DC3:RAC1
10.21.119.10=DC3:RAC1

10.0.0.13=DC1:RAC2
10.21.119.14=DC3:RAC2
10.20.114.15=DC2:RAC2

# default for unknown nodes
default=DC1:r1
```

Because of using a single data center (Simple Snitch) we don't see any relation between this file and our `ccm node1 ring` output. Simple Snitch doesn't recognize data center or rack information.

## Question 4. 

(8 marks)

a) (3marks) Connect to `cqlsh` prompt and create a keyspace with the name `ass2`. Replication strategy should be `simple`, and the replication factor equal `3`. In your answer, show your keyspace declaration.

```
$ ccm node1 cqlsh
cqlsh> CREATE KEYSPACE IF NOT EXISTS ass2 with replication = { 'class' : 'SimpleStrategy', 'replication_factor' : 3 };
```

b) (5marks) 

The following files:
   
   ```
   table_declarations.cql
   data_point_data.txt
   driver_data_txt
   time_table_data.txt
   vehicle_data.txt
   ```
   
are given on the course Assignments page. The file `table_declarations.cql` contains create table statements, while the other files contain comma separated table data. Use these files, and `SOURCE` and `COPY` cqlsh commands to implement a version of the train time table data base. In your answer show the results of running the cqlsh command `describe tables` and of running `select` statements on each table for a row of your choice.

```
$ ccm node1 cqlsh
cqlsh> SOURCE './table_declarations.cql'
cqlsh> DESCRIBE TABLES;

Keyspace system_schema
----------------------
tables     triggers    views    keyspaces  dropped_columns
functions  aggregates  indexes  types      columns

Keyspace system_auth
--------------------
resource_role_permissons_index  role_permissions  role_members  roles

Keyspace system
---------------
available_ranges          peers               batchlog        transferred_ranges
batches                   compaction_history  size_estimates  hints
prepared_statements       sstable_activity    built_views
"IndexInfo"               peer_events         range_xfers
views_builds_in_progress  paxos               local

Keyspace system_distributed
---------------------------
repair_history  view_build_status  parent_repair_history

Keyspace system_traces
----------------------
events  sessions

Keyspace ass2
-------------
time_table  data_point  driver  vehicle
```

```
cqlsh> COPY ass2.time_table (line_name, service_no, time, distance, latitude, longitude, stop) FROM './time_table_data.txt';
Using 7 child processes

Starting copy of ass2.time_table with columns [line_name, service_no, time, distance, latitude, longitude, stop].
Processed: 30 rows; Rate:      44 rows/s; Avg. rate:      66 rows/s
30 rows imported from 1 files in 0.458 seconds (0 skipped).
cqlsh> SELECT * FROM ass2.time_table;

 line_name        | service_no | time | distance | latitude | longitude | stop
------------------+------------+------+----------+----------+-----------+--------------
          Melling |          3 |  807 |     13.7 | -41.2036 |  174.9054 |      Melling
          Melling |          3 |  801 |     11.4 | -41.2118 |    174.89 | Western Hutt
          Melling |          3 |  754 |      8.3 |  -41.227 |  174.8851 |       Petone
          Melling |          3 |  741 |        0 | -41.2865 |  174.7762 |   Wellington
 Hutt Valley Line |          1 |  650 |     34.3 | -41.1244 |  175.0708 |   Upper Hutt
 Hutt Valley Line |          1 |  642 |     26.5 | -41.1479 |  175.0122 | Silverstream
 Hutt Valley Line |          1 |  634 |       19 | -41.1798 |  174.9608 |        Taita
 Hutt Valley Line |          1 |  629 |     15.8 | -41.2024 |  174.9423 |       Naenae
 Hutt Valley Line |          1 |  625 |     13.3 | -41.2092 |  174.9081 |     Waterloo
 Hutt Valley Line |          1 |  622 |       11 | -41.2204 |  174.9081 |       Woburn
 Hutt Valley Line |          1 |  617 |      8.3 |  -41.227 |  174.8851 |       Petone
 Hutt Valley Line |          1 |  605 |        0 | -41.2865 |  174.7762 |   Wellington
         Waikanae |          5 | 1139 |     62.8 | -40.8755 |  175.0668 |     Waikanae
         Waikanae |          5 | 1118 |     51.3 | -40.9142 |  175.0084 |  Paraparaumu
         Waikanae |          5 | 1059 |     33.1 | -40.9881 |   174.951 |  Paekakariki
         Waikanae |          5 | 1042 |     15.9 | -41.1339 |  174.8406 |      Porirua
         Waikanae |          5 | 1025 |        0 | -41.2865 |  174.7762 |   Wellington
 Hutt Valley Line |         11 | 2025 |     34.3 | -41.1244 |  175.0708 |   Upper Hutt
 Hutt Valley Line |         11 | 2019 |     26.5 | -41.1479 |  175.0122 | Silverstream
 Hutt Valley Line |         11 | 2010 |       19 | -41.1798 |  174.9608 |        Taita
 Hutt Valley Line |         11 | 2001 |     15.8 | -41.2024 |  174.9423 |       Naenae
 Hutt Valley Line |         11 | 1955 |     13.3 | -41.2092 |  174.9081 |     Waterloo
 Hutt Valley Line |         11 | 1952 |       11 | -41.2204 |  174.9081 |       Woburn
 Hutt Valley Line |         11 | 1947 |      8.3 |  -41.227 |  174.8851 |       Petone
 Hutt Valley Line |         11 | 1935 |        0 | -41.2865 |  174.7762 |   Wellington
 Hutt Valley Line |          2 | 1045 |     34.3 | -41.2865 |  174.7762 |   Wellington
 Hutt Valley Line |          2 | 1033 |       26 |  -41.227 |  174.8851 |       Petone
 Hutt Valley Line |          2 | 1025 |       21 | -41.2092 |  174.9081 |     Waterloo
 Hutt Valley Line |          2 | 1015 |     15.3 | -41.1798 |  174.9608 |        Taita
 Hutt Valley Line |          2 | 1000 |        0 | -41.1244 |  175.0708 |   Upper Hutt

(30 rows)
```

```
cqlsh> COPY ass2.data_point FROM './data_point_data.txt';
Using 7 child processes

Starting copy of ass2.data_point with columns [line_name, service_no, date, sequence, latitude, longitude, speed].
Processed: 5 rows; Rate:       8 rows/s; Avg. rate:      11 rows/s
5 rows imported from 1 files in 0.437 seconds (0 skipped).
cqlsh> SELECT * FROM ass2.data_point;

 line_name       | service_no | date     | sequence                        | latitude | longitude | speed
-----------------+------------+----------+---------------------------------+----------+-----------+-------
 Hutt Valey Line |          2 | 20160326 | 2016-03-25 21:07:40.000000+0000 | -41.2012 |       175 |  70.1
 Hutt Valey Line |          2 | 20160326 | 2016-03-25 21:02:10.000000+0000 | -41.1255 |    175.07 |  40.5
 Hutt Valey Line |          2 | 20160326 | 2016-03-24 21:27:10.000000+0000 | -41.2262 |    174.77 |  29.1
 Hutt Valey Line |          2 | 20150322 | 2015-03-21 21:44:10.000000+0000 | -41.2862 |  174.7759 |   9.1
 Hutt Valey Line |          2 | 20160322 | 2016-03-21 21:37:50.000000+0000 | -41.2272 |    174.77 |  29.1

(5 rows)
```

```
cqlsh> COPY ass2.driver FROM './driver_data.txt';
Using 7 child processes

Starting copy of ass2.driver with columns [driver_name, current_position, email, mobile, password, skill].
Processed: 6 rows; Rate:      10 rows/s; Avg. rate:      14 rows/s
6 rows imported from 1 files in 0.430 seconds (0 skipped).
cqlsh> SELECT * FROM ass2.driver;

 driver_name | current_position | email                | mobile   | password | skill
-------------+------------------+----------------------+----------+----------+--------------------------------------
        fred |            Taita |   fred@ecs.vuw.ac.nz |  2799797 |     f00f |            {'Ganz Mavag', 'Guliver'}
        jane |         Waikanae |   jane@ecs.vuw.ac.nz |  2131131 |     jj77 |                          {'Matangi'}
         ann |    not available |    ann@ecs.vuw.ac.nz | 21998877 |     aaaa |                          {'Matangi'}
       milan |       Upper Hutt |  milan@ecs.vuw.ac.nz |   211111 |     mm77 |                          {'Matangi'}
       pondy |       Wellington |  pondy@ecs.vuw.ac.nz |   214455 |     pd66 |               {'Guliver', 'Matangi'}
       pavle |       Upper Hutt | pmogin@ecs.vuw.ac.nz |   213344 |     pm33 | {'Ganz Mavag', 'Guliver', 'Matangi'}

(6 rows)
```

```
cqlsh> COPY ass2.vehicle FROM './vehicle_data.txt';
Using 7 child processes

Starting copy of ass2.vehicle with columns [vehicle_id, status, type].
Processed: 6 rows; Rate:      10 rows/s; Avg. rate:      14 rows/s
6 rows imported from 1 files in 0.433 seconds (0 skipped).
cqlsh> SELECT * FROM ass2.vehicle;

 vehicle_id | status       | type
------------+--------------+------------
     KW3300 |   Wellington |    Matangi
     FP3003 | out of order |    Guliver
     FA3456 |       in_use |    Matangi
     FP8899 |   Upper Hutt |    Matangi
     FA4864 |  maintenance |    Matangi
     FA1122 |   Upper Hutt | Ganz Mavag

(6 rows)
```

