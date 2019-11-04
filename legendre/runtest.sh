#!/bin/sh
if [ x$NLIZE = 'xy' ]
then
  opt="-fsanitize=address -fsanitize=leak -fsanitize=undefined"
else
  opt=
fi
libdw=$1
bopt=$2
withlibelf=$3
withlibz=$4
if [ x$withlibz = "x" ]
then
   echo "FAIL frame1 runtest.sh missing arguments"
   exit 1
fi

OPTS="-I$bopt -I$bopt/libdwarf" 
libs=
if [ $withlibelf = "withlibelf" ]
then
  libs="$libs -lelf"
fi
if [ $withlibz = "withlibz" ]
then
  libs="$libs -lz"
fi


cc -I $libdw/libdwarf $opt $OPTS -DNEW frame_test.c ../libdwarf.a $libs -o frame_test1
./frame_test1
if [  $? -ne 0 ]
then
  echo FAIL frame CFA reg new
  exit 1
fi

cc -I $libdw/libdwarf -DOLD $opt $OPTS frame_test.c ../libdwoldframecol.a $libs -o frame_test2
./frame_test2
if [  $? -ne 0 ]
then
  echo FAIL frame CFA reg old
  exit 1
fi
rm -f ./frame_test1
rm -f ./frame_test2
echo "PASS legendre/runtest.sh frame test"
exit 0
