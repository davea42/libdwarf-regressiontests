#!/bin/sh
. ../BASEFILES.sh
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
withlibz=$1
withlibzstd=$2
if [ "x$withlibz" = x ]
then
   echo "fail legendre runtest.sh missing arguments"
   exit 1
fi

OPTS="-I$bopt -I$bopt/src/lib/libdwarf -I$libdw/src/lib/libdwarf -I$" 
libs=
if [ $withlibz = "withlibz" ]
then
  libs="$libs -lz"
fi
if [ $withlibzstd = "yezstd" ]
then
  if  [ ! "x$libzstdlibdir" = "x" ]
  then
      libs="$libs $libzstdlibdir"
  fi
  libs="$libs -lzstd"
fi

cpifmissing $ts/libmpich.so.1.0 libmpich.so.1.0

cc -I $libdw/libdwarf $opt $OPTS -DNEW $libzstdhdrdir \
  $ts/frame_test.c ../$filelibname $libs -o frame_test1
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
