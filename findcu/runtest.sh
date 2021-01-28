#!/bin/sh

. ../BASEFILES

ts=$testsrc/findcu
tf=$bldtest/findcu

libdw=$libbld
bld=$libbld

withlibelf=$1
withlibz=$2
if [ x$withlibz = "x" ]
then
   echo "fail findcu runtest.sh missing arguments"
   exit 1
fi
h="-I$libdw/libdwarf -I$codedir/libdwarf"
l="-L$libdw/libdwarf"
libs="$bld/libdwarf/.libs/libdwarf.a"
if [ x$NLIZE = 'xy' ]
then
  nli="-fsanitize=address -fsanitize=leak -fsanitize=undefined"
else
  nli=
fi
opts="-I$bld -I$bld/libdwarf -I$codedir/libdwarf"

if [ $withlibelf = "withlibelf" ]
then
  libs="$libs -lelf"
fi
if [ $withlibz = "withlibz" ]
then
  libs="$libs -lz"
fi

cc $h $opts  $ts/cutest.c $nli $l -o cutest $libs
./cutest $ts/cutestobj.save
r=$?
if [ $r -ne 0 ]
then
   echo fail cutest, interface did not work.
   echo "rerun: $ts/runtest.sh $1 $2" 
   exit 1
fi
echo "PASS findcu/runtest.sh"
exit 0
