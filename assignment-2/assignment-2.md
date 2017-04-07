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

