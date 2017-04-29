#!/usr/bin/env bash

# Check ccm is available
if ! [ -x "$(command -v ccm)" ]; then
  echo "Error: ccm is not installed." >&2
  exit 1
fi

# A normal start, list the whole table
nodes=('node1' 'node2' 'node3' 'node4' 'node5' 'node6' 'node7' 'node8' 'node9');
for node in "${nodes[@]}"; do
  ccm switch multi_dc
  ccm stop
  ccm ${node} start
  echo "Active node: ${node}"
  ccm status
  sleep 60; # For some reason ccm cannot connect to the node immediately, we have to wait roughly a minute.
  ccm ${node} cqlsh -e "CONSISTENCY LOCAL_ONE; SELECT * FROM ass2.time_table WHERE line_name='Hutt Valley Line' AND service_no=2 AND time=1045 ;"
done
