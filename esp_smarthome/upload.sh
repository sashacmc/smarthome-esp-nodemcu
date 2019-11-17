#!/bin/bash

#-----------------------------------------------------------------
#-- Script for deploy smarthome code to esp 
#-- Alexander Bushnev <sashacmc@gmail.com>
#-- Dependencies: luatool.py (https://github.com/4refr0nt/luatool)
#--               luajit, curl
#-----------------------------------------------------------------

# for work in serial port mode need to set environment variables
# export SERIALPORT=/dev/ttyUSB5
# export SERIALBR=38400

MODULE=$1
IP_ADDRESS=$2

if [ -e $MODULE ]; then
    echo "usage $0 MODULE"
    exit 1
fi

MODULEDIR="cfg_$MODULE"

if [ ! -d $MODULEDIR ]; then
    echo "Wrong module $MODULE"
    exit 2
fi 

shift
shift

FILES=$*
if [ ! "$FILES" ]; then
    FILES=$(ls -r *.lua *.cfg a_private/* $MODULEDIR/*)
fi

echo "Validate code..."
for f in $(ls *.lua a_private/*.lua $MODULEDIR/*.lua); do
    luajit -bl $f >/dev/null || exit 1;
done

if [ -e $IP_ADDRESS ]; then
    CONN="-p $SERIALPORT -b $SERIALBR --delay 0.1"
else
    echo "Start telnet..."
    CONN="--ip $IP_ADDRESS"
    curl $IP_ADDRESS/telnet
fi

echo "Stop current activity..."
while true; do
    luatool.py $CONN -f test/stop.lua -d && break;
    sleep 1;
done

for f in $FILES; do
    while true; do
        echo "Upload $f"
        luatool.py $CONN --src $f
        if (( $? == "0" )); then
            break
        fi
    done
done

echo "Restart..."
while true; do
    luatool.py $CONN -f test/restart.lua -d && break;
    sleep 1;
done
