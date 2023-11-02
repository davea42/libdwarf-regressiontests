#!/bin/sh
#  This is really a test of the new dwarf_get_form_class function.

. ../BASEFILES.sh
#This gets us
#withlibz="withlibz"
#libzlink=" -lz -lzstd"
#libzhdr=""
#libzlib=""
#properly set up

. $testsrc/BASEFUNCS.sh
ts=$testsrc/test-alex2
tf=$bldtest/test-alex2
l=../$filelibname

staticopt=
if [ $sharedlib = "n" ]
then
staticopt="-DLIBDWARF_STATIC"
fi

OPTS="-I$bldtest -I$bldtest/libdwarf -I$codedir/src/lib/libdwarf -I$libbld/libdwarf $staticopt"
libs=
x="cc -DWORKING=1 $OPTS  $libzhdr $ts/test.c $l $libs $libzlib $libzlink -o test2"
echo "$x"
$x

cpifmissing $ts/orig.a.out orig.a.out
./test2 orig.a.out >out1
if [ $? != 0 ]
then
    echo fail dwarf_get_form_class, oops, in test-alex2
    echo "rerun: $ts/runtest.sh $1 $2"
    exit 1
fi
grep "DW_FORM_CLASS_STRING" out1 >/dev/null
if [ $? != 0 ]
then
    echo fail dwarf_get_form_class in test-alex2
    echo "rerun: $ts/runtest.sh $1 $2"
    exit 1
fi
echo "PASS test-alex2/runtest.sh"
exit 0
