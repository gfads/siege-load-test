#!/usr/bin/env bash

while :
do
  top -bn1 | grep CPU | head -n 1 | echo $((100 - $(awk '{printf "%d\n", $8}'))) >> cpu.log
  sleep 1
done
