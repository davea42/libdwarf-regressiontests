#!/bin/sh
#
# This test only runs properly on a little-endian
# machine because the input file 'test1' is little-endian
# and dwarfextract does its own reading with no
# code to adapt to reading on a big-endian machine.
# 16 September 2019
#
dd=$1
top_builddir=$2
top_srcdir=$3
dwlib=$4
withlibelf=$5
withlibz=$6
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
INCS="-I$top_srcdir/libdwarf  -I/usr/local/include -I$top_builddir -I$top_builddir/libdwarf"
libs="-lelf"
if [ $withlibz ]
then
  libs="$libs -lz"
fi
cc -g $opt $INCS dwarfextract.c -o dwarfextract $dwlib $libs
# Use precompiled test1.c test2.c for test consistency.
#cc -g test1.c test2.c -o test1
./dwarfextract test1 test1out >basestdout
if [  $?  -ne 0 ] 
then
    echo fail dwarfextract test0 top_builddir=$2 top_srcdir=$3 dwlib=$4
    echo "rerun: runtest.sh $1 $2 $3 $4 $5 $6"

    exit 1
fi
diff basestdout basestdout.base
if [  $?  -ne 0 ] 
then
    echo fail dwarfextract dwex-1 top_builddir=$2 top_srcdir=$3 dwlib=$4
    echo "Fix with: mv basestdout basestdout.base"
    echo "rerun: runtest.sh $1 $2 $3 $4 $5 $6"
    exit 1
fi
$dd -a test1out >test1.new
diff test1.base test1.new
if [  $?  -ne 0 ] 
then
    echo fail dwarfextract test1 top_builddir=$2 top_srcdir=$3 dwlib=$4
    echo "Fix with: mv test1.new test1.base"
    echo "rerun: runtest.sh $1 $2 $3 $4 $5 $6"
    exit 1
fi
echo PASS dwarfextract

cc -g $opt -DPRODUCER_INIT_C=1 $INCS dwarfextract.c -o dwarfextractc -L .. -ldwarf $libs
./dwarfextractc test1 testcout >basecstdout
if [  $?  -ne 0 ]
then
    echo fail dwarfextract looking for error top_builddir=$2 top_srcdir=$3 dwlib=$4
    echo "rerun: runtest.sh $1 $2 $3 $4 $5 $6"
    exit 1
fi
diff basecstdout basecstdout.base
if [  $?  -ne 0 ] 
then
    echo fail dwarfextract dwexc-1 top_builddir=$2 top_srcdir=$3 dwlib=$4
    echo "Fix with: mv basecstdout basecstdout.base"
    echo "rerun: runtest.sh $1 $2 $3 $4 $5 $6"
    exit 1
fi
$dd -a testcout >testc.new
diff testc.base testc.new
if [  $?  -ne 0 ]
then
    echo fail dwarfextract testc  top_builddir=$2 top_srcdir=$3 dwlib=$4
    echo "Fix with: mv testc.new testc.base"
    echo "rerun: runtest.sh $1 $2 $3 $4 $5 $6"
    exit 1
fi
echo "PASS dwarfextractruntest.sh"
exit 0
