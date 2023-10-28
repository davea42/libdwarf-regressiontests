#!/bin/sh
. ../BASEFILES.sh
# This gets us
#withlibz="withlibz"
#libzlink=" -lz -lzstd"
#libzhdr=""
#libzlib=""

. $testsrc/BASEFUNCS.sh
if [ x$NLIZE = 'xy' ]
then
  opt=`checkargs -fsanitize=address -fsanitize=leak \
    -fsanitize=undefined`
else
  opt=
fi

ts=$testsrc/legendre
tf=$bldtest/legendre
libdw=$libdw
bopt=$libbld

OPTS="-I$bopt -I$bopt/src/lib/libdwarf -I$libdw/src/lib/libdwarf -I$" 
libs=

cpifmissing $ts/libmpich.so.1.0 libmpich.so.1.0

x="cc -I $libdw/libdwarf $opt $OPTS -DNEW $libzhdr \
  $ts/frame_test.c ../$filelibname $libs $libzlib $libzlink\
  -o frame_test1"
echo "$x"
$x
if [ $? -ne 0 ]
then
  echo fail legendre cc frame_test.c frame CFA reg new
  echo "rerun: $ts/runtest.sh $1 $2"
  exit 1
fi

./frame_test1
if [ $? -ne 0 ]
then
  echo fail legendre frame CFA reg new
  echo "rerun: $ts/runtest.sh $1 $2"
  exit 1
fi
rm -f ./frame_test1
echo "PASS legendre/runtest.sh frame test"
exit 0
