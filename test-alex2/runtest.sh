#!/bin/sh
#  This is really a test of the new dwarf_get_form_class function.
l=$1
top_builddir=$2
top_srcdir=$3
withlibelf=$4
withlibz=$5
OPTS="-I$top_builddir -I$top_builddir/libdwarf -I$top_srcdir/libdwarf"
if [ x$withlibz = "x" ]
then
  echo "fail test-alex2. missing withlibz arg 5. $withlibelf , $withlibz"
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


cc -DWORKING=1 $OPTS  test.c $l $libs -o test2

./test2 orig.a.out >out1
if [ $? != 0 ]
then
    echo fail dwarf_get_form_class, oops, in test-alex2
    exit 1
fi
grep "DW_FORM_CLASS_STRING" out1 >/dev/null
if [ $? != 0 ]
then
    echo fail dwarf_get_form_class in test-alex2
    exit 1
fi
echo "PASS test-alex2/runtest.sh"
exit 0
