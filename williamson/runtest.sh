#!/bin/sh
# We expect a core file, we do not worry about that.
# Hopeless bogus executable.

dd=../dwarfdump
. ../BASEFILES
ts=$testsrc/williamson
tf=$bldtest/williamson
. $testsrc/BASEFUNCS

m() {
  dwdumper=$1
  obj=$2
  test=$3
  base=$4
  $dwdumper -i -G $obj 1>junk1 2>&1
  unifyddname junk1 $test
  diff $base $test
  if test  $?  -ne 0
  then
      echo "fail test williamson/...exe mismatch base $base vs $test "
      exit 1
  fi
}

# The test_sibling_loop.o will not terminate unless
# dwarfdump[2] is from February 2013 or later.
t=$ts/heap_buffer_overflow.exe
m $t newout baseout
rm -f core*
t=$ts/hbo_unminimized.exe
m $t newunminout baseunminout
rm -f core*
echo "PASS williamson/runtest.sh tests"
exit 0
