#!/bin/sh
l=$1
top_bld=$2
top_src=$3
withlibelf=$4
withlibz=$5
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

OPTS="-I$top_bld -I$top_bld/libdwarf -I$top_src/libdwarf"
cc -DWORKING=1 $opt $OPTS  test.c $l $libs -o test1
if [ $? -ne 0 ]
then
     echo fail test-alex1 cc 1
     exit 1
fi
cc  $opt $OPTS  test.c  $l $libs -o test2
if [ $? -ne 0 ]
then
     echo fail test-alex1 cc 2
     exit 1
fi

./test1 orig.a.out >out1
if [ $? -ne 0 ]
then
     echo fail test-alex1 run test1
     exit 1
fi
./test2 orig.a.out >out2
if [ $? -ne 0 ]
then
     echo fail test-alex1 run test2
     exit 1
fi
diff out1 out2 >outdiffs
if [ $? -ne  0 ]
then
	echo "fail alex-s test in test-alex1."
	exit 1
fi
echo "PASS test-alex1/runtest.sh"
exit 0
