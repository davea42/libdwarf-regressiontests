#!/bin/sh
libdw=$1
bld=$2
h="-I$libdw/libdwarf"
l="-L$libdw/libdwarf"
libs="$bld/libdwarf/.libs/libdwarf.a -lelf"
if [ x$NLIZE = 'xy' ]
then
  nli="-fsanitize=address -fsanitize=leak -fsanitize=undefined"
else
  nli=
fi

opts="-I$bld -I$bld/libdwarf"

if [ -f /usr/include/zlib.h ]
then
  cc $h $opts  cutest.c $nli $l -o cutest $libs -lz
else
  cc $h $opts cutest.c $nli $l -o cutest $libs
fi
./cutest cutestobj.save
r=$?
if [ $r -ne 0 ]
then
   echo FAIL cutest, interface did not work.
   exit 1
fi
echo "PASS findcu/runtest.sh"
exit 0
