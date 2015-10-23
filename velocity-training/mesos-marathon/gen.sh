#!/bin/sh

while true
do
  timestamp=$(date +%s)
  echo '<html><h1>Something important happened:' "$timestamp" '</h1>' > "$1"
  sleep 2
done
