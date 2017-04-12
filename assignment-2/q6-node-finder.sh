#!/usr/bin/env bash

# Check ccm is available
if ! [ -x "$(command -v ccm)" ]; then
  echo "Error: ccm is not installed." >&2
  exit 1
fi

# A normal start, list the whole table
ccm start >&1
ccm status >&1
ccm node1 cqlsh -e 'use ass2; select * from driver;' >&1

nodes=('node1' 'node2' 'node3' 'node4' 'node5');
for node in "${nodes[@]}"; do
  ccm switch single_dc
  ccm stop
  ccm ${node} start
  echo "Active node: ${node}"
  ccm status
  ccm ${node} cqlsh -e "use ass2; consistency one; select * from driver where driver_name='eileen';"
done
