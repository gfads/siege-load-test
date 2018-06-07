#!/usr/bin/env bash

while :
do
  free -m | awk 'NR==2{print $3 }' >> mem.log
  sleep 1
done
