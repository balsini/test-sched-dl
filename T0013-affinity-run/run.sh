#!/bin/bash

enable_cpuset() {
	echo "Enabling cpuset..."
	if [ ! -e /dev/cpuset ]; then
		mkdir /dev/cpuset
	fi
	mount -t cgroup -o cpuset cpuset /dev/cpuset
	echo 0 > /dev/cpuset/cpuset.sched_load_balance
	echo 1 > /dev/cpuset/cpuset.cpu_exclusive

	if [ ! -e /dev/cpuset/cpu0 ]; then
		mkdir /dev/cpuset/cpu0
	fi
	echo 0 > /dev/cpuset/cpu0/cpuset.cpus
	echo 0 > /dev/cpuset/cpu0/cpuset.mems
	echo 1 > /dev/cpuset/cpu0/cpuset.cpu_exclusive
	echo 0 > /dev/cpuset/cpu0/cpuset.mem_exclusive

	if [ ! -e /dev/cpuset/cpu1 ]; then
		mkdir /dev/cpuset/cpu1
	fi
	echo 1 > /dev/cpuset/cpu1/cpuset.cpus
	echo 0 > /dev/cpuset/cpu1/cpuset.mems
	echo 1 > /dev/cpuset/cpu1/cpuset.cpu_exclusive
	echo 0 > /dev/cpuset/cpu1/cpuset.mem_exclusive
}

disable_cpuset() {
	echo "Disabling cpuset..."
	echo 1 > /dev/cpuset/cpuset.sched_load_balance
	umount /dev/cpuset
}

enable_cpuset
make clean_data
DIR=`basename $PWD`
if [ ! -e $DIR ]; then
	echo "ERROR: File not compiled! Type make"
	exit
fi
$TRACECMD reset
echo "Running test $DIR..."
dmesg -c > /dev/null
$TRACECMD record -a -r 90 -b 100000 -e sched -o trace.dat ./$DIR $TESTDL_SCHED_FLAG &
sleep 3
## ps aux | grep -i $DIR
PID=`ps aux | grep -i $DIR | grep -v trace-cmd | grep -v grep | xargs -r | awk '{print $2}'`
if [[ $PID == "" ]]; then
	echo "ERROR: no PID!"
	ps aux | grep -i $DIR
else
	echo "PID is $PID"
	echo $PID > /dev/cpuset/cpu0/tasks
	sleep 2
	echo $PID > /dev/cpuset/cpu1/tasks
	sleep 2
	echo $PID > /dev/cpuset/cpu0/tasks
	sleep 2
	echo $PID > /dev/cpuset/cpu1/tasks
	sleep 2
	echo $PID > /dev/cpuset/cpu0/tasks
	sleep 2
fi
echo "Killing test $DIR..."
killall -s SIGKILL $DIR > /dev/null
sleep 3
dmesg -c > ./dmesg.txt
disable_cpuset

