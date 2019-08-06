#!/bin/bash
i=1
while [ "$i" -ne 30 ]
do
  i=$((i+1))
python start_sensor.py
  sleep 2
done
