# Learning Cassandra

## Content

```
./
 ├─ practicing/ --- Miscellaneous files
 ├─ assignment-1/ --- Files related to Assignment 1
 ├─ assignment-2/ --- Files related to Assginement 2
```


# Setup Cassandra environment on Mac

Install cassandra with brew:

```
$ brew install cassandra
```

Create a loop alias for cluster IPs. A bash command with the following content in `./bin/loop-alias.sh`.

```
#!/bin/bash
sudo ifconfig lo0 alias 127.0.0.2 up
sudo ifconfig lo0 alias 127.0.0.3 up
sudo ifconfig lo0 alias 127.0.0.4 up
sudo ifconfig lo0 alias 127.0.0.5 up
sudo ifconfig lo0 alias 127.0.0.6 up
sudo ifconfig lo0 alias 127.0.0.7 up
```

```
$ ./bin/loop-alias.sh
```

Run cassandra:

```
$ cassandra -f
```

# Run the project

* Run `loop-alias.sh`
* Run `ccm start`
* Launch shell `ccm node1 cqlsh`

# Cassandra Notes

1. Reading driver and vehicle data must be strongly consistent.

    STRONG -> QUORUM

2. Reading Data Point and other data may be eventually consistent.

    EVENTUALLY -> LEVEL SET ONE

* single data center

* A table with lot of updates has to use `LeveledCompactionStrategy`
`CREATE TABLE <table_name>
