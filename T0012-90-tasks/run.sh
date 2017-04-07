#!/bin/bash

make clean_data
DIR=`basename $PWD`
if [ ! -e $DIR ]; then
	echo "ERROR: File not compiled! Type make"
	exit
fi
$TRACECMD reset
echo "Running test $DIR..."
dmesg -c > /dev/null
SEQ=$(seq 1 90)
for RUN in $SEQ
do
./$DIR $TESTDL_SCHED_FLAG &
done
sleep 120
echo "Killing test $DIR..."
killall -s SIGKILL $DIR > /dev/null
sleep 60
dmesg -c > ./dmesg.txt

