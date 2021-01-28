#!/bin/sh
#
# This test only runs properly on a little-endian
# machine because the input file 'test1' is little-endian
# and dwarfextract does its own reading with no
# code to adapt to reading on a big-endian machine.
# 16 September 2019
#
. ../BASEFILES
. $testsrc/BASEFUNCS
withlibelf=$1
withlibz=$2
dd=../dwarfdump

ts=$testsrc/dwarfextract
tf=$bldtest/dwarfextract
libdw=$codedir
bld=$bldtest
dwlib=$bldtest/libdwarf.a

if [ x$withlibz = "x" ]
then
   echo "fail dwarfextract runtest.sh missing libz arg"
   exit 1
fi
if [ x$NLIZE = 'xy' ]
then
  opt="-fsanitize=address -fsanitize=leak -fsanitize=undefined"
else
  opt=
fi


INCS="-I$libbld/libdwarf  -I/usr/local/include  -I$libdw"
libs="-lelf"
if [ $withlibz ]
then
  libs="$libs -lz"
fi
cc -g $opt $INCS $ts/dwarfextract.c -o dwarfextract $dwlib $libs
if [ $? -ne 0 ] 
then
    echo "fail dwarfextract compile "
    echo "rerun: $ts/runtest.sh $1 $2"
    
    exit 1
fi
# Use precompiled test1.c test2.c for test consistency.
# cc -g test1.c test2.c -o test1
cpifmissing $ts/test1 test1
./dwarfextract test1 test1out >basestdout
if [ $? -ne 0 ] 
then
    echo "fail dwarfextract test0"
    echo "rerun: $ts/runtest.sh $1 $2"
    exit 1
fi
diff $ts/basestdout.base basestdout
if [ $? -ne 0 ] 
then
    echo "fail dwarfextract dwex-1 "
    echo "Fix with: mv $tf/basestdout $ts/basestdout.base"
    echo "rerun: $ts/runtest.sh $1 $2  "
    exit 1
fi
$dd -a test1out >test1.new
diff $ts/test1.base test1.new
if [  $?  -ne 0 ] 
then
    echo "fail dwarfextract test1"
    echo "Fix with: mv $tf/test1.new $ts/test1.base"
    echo "rerun: $ts/runtest.sh $1 $2 "
    exit 1
fi

cc -g $opt -DPRODUCER_INIT_C=1 $INCS $ts/dwarfextract.c -o dwarfextractc -L .. -ldwarf $libs
./dwarfextractc test1 testcout >basecstdout
if [ $? -ne 0 ]
then
    echo "fail dwarfextract looking for error"
    echo "rerun: $ts/runtest.sh $1 $2  "
    exit 1
fi
diff basecstdout $ts/basecstdout.base
if [  $?  -ne 0 ] 
then
    echo fail dwarfextract dwexc-1 
    echo "Fix with: mv $tf/basecstdout $ts/basecstdout.base"
    echo "rerun: $ts/runtest.sh $1 $2  "
    exit 1
fi
$dd -a testcout >testc.new
diff $ts/testc.base testc.new
if [  $?  -ne 0 ]
then
    echo fail dwarfextract testc 
    echo "Fix with: mv testc.new $ts/testc.base"
    echo "rerun: $ts/runtest.sh $1 $2" 
    exit 1
fi
echo "PASS dwarfextract"
exit 0
