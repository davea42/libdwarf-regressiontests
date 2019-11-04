#!/bin/sh
libdw=$1
bld=$2
withlibelf=$3
withlibz=$4
if [ x$withlibz = "x" ]
then
   echo "FAIL findcu runtest.sh missing arguments"
   exit 1
fi
h="-I$libdw/libdwarf"
l="-L$libdw/libdwarf"
libs="$bld/libdwarf/.libs/libdwarf.a"
if [ x$NLIZE = 'xy' ]
then
  nli="-fsanitize=address -fsanitize=leak -fsanitize=undefined"
else
  nli=
fi
opts="-I$bld -I$bld/libdwarf"

if [ $withlibelf = "withlibelf" ]
then
  libs="$libs -lelf"
fi
if [ $withlibz = "withlibz" ]
then
  libs="$libs -lz"
fi

cc $h $opts  cutest.c $nli $l -o cutest $libs
./cutest cutestobj.save
r=$?
if [ $r -ne 0 ]
then
   echo FAIL cutest, interface did not work.
   exit 1
fi
echo "PASS findcu/runtest.sh"
exit 0
