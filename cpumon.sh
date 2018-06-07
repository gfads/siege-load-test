#!/usr/bin/env bash

while :
do
  top -bn1 | grep load | awk '{printf "%.2f\t\t\n", $(NF-2)}' >> cpu.log
  sleep 1
done
