#!/bin/sh

. ../BASEFILES.sh
ts=$testsrc/navarro
tf=$bldtest/navarro

echo $libdw/libdwarf
dw=$libdw/libdwarf
echo $dw/libdwarf
libs=
if [ $withlibz = "withlibz" ]
then
  libs="$libs -lz"
fi
staticopt=
if [ $sharedlib = "n" ]
then
staticopt="-DLIBDWARF_STATIC"
fi


cc -g -I$dw -L$dw $staticopt $ts/get_globals.c -ldwarf $libs -o getglobals
if [ $? -ne 0 ]
then
 echo fail to compile navarro/getglobals
 echo "rerun: $ts/runtest.sh"
 exit 1
fi
./getglobals
if [ $? -ne 0 ]
then
 echo fail to run navarro/getglobals
 echo "rerun: $ts/runtest.sh"
 exit 1
fi
echo PASS navarro/runtest.sh
exit 0
