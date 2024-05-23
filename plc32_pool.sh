#!/bin/bash
#
date
./plc32
status=$?
echo $status
while [ $status -eq 0 ]
  do
    ./plc32
    status=$?
    echo $status
    sleep 1
  done
