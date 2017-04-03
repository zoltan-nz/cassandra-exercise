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
