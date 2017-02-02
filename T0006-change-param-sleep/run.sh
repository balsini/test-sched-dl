#!/bin/bash

make clean_data
DIR=`basename $PWD`
if [ ! -e $DIR ]; then
	echo "ERROR: File not compiled! Type make"
	exit
fi
trace-cmd reset
echo "Running test $DIR..."
dmesg -c > /dev/null
trace-cmd record -a -r 90 -b 100000 -e sched -o trace.dat ./$DIR &
sleep 1
## ps aux | grep -i $DIR
PID=`ps aux | grep -i $DIR | grep -v trace-cmd | grep -v grep | xargs -r | awk '{print $2}'`
echo "PID is $PID"
sleep 10
echo "Killing test $DIR..."
killall $DIR > /dev/null
dmesg -c > ./dmesg.txt
cat dmesg.txt

