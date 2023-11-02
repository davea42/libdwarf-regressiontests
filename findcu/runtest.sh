#!/bin/sh

. ../BASEFILES.sh
# This gets us 
#withlibz="withlibz"
#libzlink=" -lz -lzstd"
#libzhdr=""
#libzlib=""

. $testsrc/BASEFUNCS.sh

ts=$testsrc/findcu
tf=$bldtest/findcu

libdw=$libbld
bld=$libbld

if [ x$withlibz = "x" ]
then
   echo "fail findcu runtest.sh missing arguments"
   exit 1
fi
h="-I$libdw/libdwarf -I$codedir/src/lib/libdwarf"
l="-L$libdw/libdwarf"
libs="../$filelibname"
if [ x$NLIZE = 'xy' ]
then
  nli=`checkargs -fsanitize=address -fsanitize=leak \
    -fsanitize=undefined`
else
  nli=
fi
staticopt=
if [ $sharedlib = "n" ]
then
staticopt="-DLIBDWARF_STATIC"
fi

opts="-I$bld -I$bld/l$bdwarf $staticopt -I$codedir/src/lib/libdwarf"

cc $h $opts  $libzhdr $ts/cutest.c $nli $l -o cutest $libs $libzlib $libzlink
./cutest $ts/cutestobj.save
r=$?
if [ $r -ne 0 ]
then
   echo FAIL cutest.c, interface did not work.
   echo "rerun: $ts/runtest.sh $1 $2" 
   exit 1
fi
echo "PASS findcu/runtest.sh"
exit 0
