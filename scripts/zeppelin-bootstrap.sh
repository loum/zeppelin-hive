#!/bin/sh

# Generate the Zeppelin Interpreter definition files.
python zeppelin/interpreter-setter.py -t "zeppelin/conf/interpreter-hive.json.j2"

# Create JDBC-based interpreter for Hive.
python zeppelin/interpreter-merge.py -p "zeppelin/conf"

# Restart Zeppelin for the new Interpreter list to take.
zeppelin/bin/zeppelin-daemon.sh start

# Block until we signal exit.
trap 'exit 0' TERM
while true; do sleep 0.5; done
