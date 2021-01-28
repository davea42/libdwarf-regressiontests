#!/bin/sh
#  This is really a test of the new dwarf_get_form_class function.

. ../BASEFILES
. $testsrc/BASEFUNCS
ts=$testsrc/test-alex2
tf=$bldtest/test-alex2
l=$bldtest/libdwarf.a
withlibelf=$1
withlibz=$2

OPTS="-I$bldtest -I$bldtest/libdwarf -I$codedir/libdwarf -I$libbld/libdwarf"
if [ x$withlibz = "x" ]
then
  echo "fail test-alex2. missing withlibz"
  echo " arg 2. We got: $withlibelf , $withlibz"
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

cc -DWORKING=1 $OPTS  $ts/test.c $l $libs -o test2

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
