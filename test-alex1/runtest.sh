#!/bin/sh

. ../BASEFILES.sh
ts=$testsrc/test-alex1
tf=$bldtest/test-alex1
top_bld=$bldtest
top_src=$testsrc
. $testsrc/BASEFUNCS.sh

withlibelf=$1
withlibz=$2
withlibzstd=$3
if [ x$NLIZE = 'xy' ]
then
  opt="-fsanitize=address -fsanitize=leak -fsanitize=undefined"
else
  opt=
fi
if [ x$withlibz = "x" ]
then
  echo "Missing final withlibz arg in test-alex1/runtest.sh"
  echo "fail test-alex1 due to missing withlibz arg"
  echo "rerun: $ts/runtest.sh $withlibelf $withlibz"
  exit 1
fi
libs=
if [ $withlibelf = "withlibelf" ]
then
  libs="$libs -lelf"
fi
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

OPTS="-I$bldtest -I$bldtest/libdwarf -I$codedir/src/lib/libdwarf -I$libbld/libdwarf"
echo "cc -DWORKING=1 $opt $OPTS $libzstdhdrdir  $ts/test.c ../$filelibname $libs -o test1"
cc -DWORKING=1 $opt $OPTS  $ts/test.c ../$filelibname $libs -o test1
if [ $? -ne 0 ]
then
     exit 1
fi
cc  $opt $OPTS $libzstdhdrdir  $ts/test.c ../$filelibname  $libs -o test2
if [ $? -ne 0 ]
then
     echo fail test-alex1 cc 2
     exit 1
fi
cpifmissing $ts/orig.a.out orig.a.out
./test1 orig.a.out >out1
if [ $? -ne 0 ]
then
     echo fail test-alex1 run test1
     echo "rerun test-alex1: runtest.sh $withlibelf $withlibz $withlibzstd"
     exit 1
fi
./test2 orig.a.out >out2
if [ $? -ne 0 ]
then
     echo fail test-alex1 run test2
     echo "rerun: $ts/runtest.sh $withlibelf $withlibz $withlibzstd"
     exit 1
fi
diff out1 out2 >outdiffs
if [ $? -ne  0 ]
then
     echo "fail alex-s test in test-alex1."
     echo "rerun: $ts/runtest.sh $withlibelf $withlibz $withlibzstd"
     exit 1
fi
echo "PASS test-alex1/runtest.sh"
exit 0
