#!/bin/sh

. ../BASEFILES
echo $libdw/libdwarf
dw=$libdw/libdwarf
echo $dw/libdwarf
echo "cc -g -I $dw -L$dw get_globals.c -o getglobals -ldwarf -lelf -lz"
cc -g -I $dw -L $dw get_globals.c -ldwarf -lelf -lz -o getglobals
if [ $? -ne 0 ]
then
 echo FAIL to compile navarro/getglobals
 exit 1
fi
./getglobals
