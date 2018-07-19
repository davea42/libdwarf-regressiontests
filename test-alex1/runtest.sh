#!/bin/sh
l=$1
top_bld=$2
top_src=$3
if [ x$NLIZE = 'xy' ]
then
  opt="-fsanitize=address -fsanitize=leak -fsanitize=undefined"
else
  opt=
fi
OPTS="-I$top_bld -I$top_bld/libdwarf -I$top_src/libdwarf"
if [ -f /usr/include/zlib.h ]
then
  gcc -DWORKING=1 $opt $OPTS  test.c $l -lelf -lz -o test1
  if [ $? -ne 0 ]
  then
     echo FAIL test-alex1 gcc 1
     exit 1
  fi
  gcc  $opt $OPTS  test.c  $l -lelf -lz -o test2
  if [ $? -ne 0 ]
  then
     echo FAIL test-alex1 gcc 2
     exit 1
  fi
else
  gcc -DWORKING=1 $opt $OPTS  test.c $l -lelf -o test1
  if [ $? -ne 0 ]
  then
     echo FAIL test-alex1 gcc 3
     exit 1
  fi
  gcc  $opt $OPTS  test.c  $l -lelf -o test2
  if [ $? -ne 0 ]
  then
     echo FAIL test-alex1 gcc 4
     exit 1
  fi
fi

./test1 orig.a.out >out1
if [ $? -ne 0 ]
then
     echo FAIL test-alex1 run test1
     exit 1
fi
./test2 orig.a.out >out2
if [ $? -ne 0 ]
then
     echo FAIL test-alex1 run test2
     exit 1
fi
diff out1 out2 >outdiffs
if [ $? -ne  0 ]
then
	echo FAIL alex-s test in test-alex1.
	exit 1
fi
exit 0
