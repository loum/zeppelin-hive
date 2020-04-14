#!/bin/sh

#zeppelin/bin/zeppelin-daemon.sh start

# Pause until Zeppelin Interpreter bootstrap completes.
#counter=0
#sleep_time=5
#break_out=19
#file_to_check="zeppelin/conf/interpreter.json"
#while : ; do
#    if [ -f "$file_to_check" -o $counter -gt $break_out ]
#    then
#        if [ -f "$file_to_check" ]
#        then
#            echo "### Zeppelin Interpreter bootstrap complete"
#        else
#            echo "### ERROR: Zeppelin Interpreter boostrap timeout"
#        fi
#        break
#    else
#        echo "$0 pausing until $file_to_check exists."
#        sleep $sleep_time
#        counter=$((counter+$sleep_time))
#    fi
#done

# Create JDBC-based interpreter for Hive.
python zeppelin/interpreter-merge.py -p "zeppelin/conf"

# Restart Zeppelin for the new Interpreter list to take.
zeppelin/bin/zeppelin-daemon.sh start

# Block until we signal exit.
trap 'exit 0' TERM
while true; do sleep 0.5; done
