#!/bin/sh

. ../BASEFILES.sh
# This gets us
#withlibz="withlibz"
#libzlink=" -lz -lzstd"
#libzhdr=""
#libzlib=""

ts=$testsrc/test-alex1
tf=$bldtest/test-alex1
top_bld=$bldtest
top_src=$testsrc
. $testsrc/BASEFUNCS.sh
if [ x$NLIZE = 'xy' ]
then
  opt=`checkargs -fsanitize=address -fsanitize=leak \
    -fsanitize=undefined`
else
  opt=
fi

OPTS="-I$bldtest -I$bldtest/libdwarf -I$codedir/src/lib/libdwarf -I$libbld/libdwarf"
x="cc -DWORKING=1 $opt $OPTS $libzhdr  $ts/test.c ../$filelibname $libzlib $libzlink -o test1"
echo "$x"
$x
if [ $? -ne 0 ]
then
     exit 1
fi
x="cc  $opt $OPTS $libzhdr  $ts/test.c ../$filelibname  $libzlib $libzlink -o test2"
echo "$x"
$x
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
     echo "rerun test-alex1: runtest.sh  $withlibz $withlibzstd"
     exit 1
fi
./test2 orig.a.out >out2
if [ $? -ne 0 ]
then
     echo fail test-alex1 run test2
     echo "rerun: $ts/runtest.sh $withlibz $withlibzstd"
     exit 1
fi
diff out1 out2 >outdiffs
if [ $? -ne  0 ]
then
     echo "fail alex-s test in test-alex1."
     echo "rerun: $ts/runtest.sh  $withlibz $withlibzstd"
     exit 1
fi
echo "PASS test-alex1/runtest.sh"
exit 0
