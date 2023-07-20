#!/bin/sh

dd=../dwarfdump
. ../BASEFILES.sh
ts=$testsrc/baddie1
tf=$bldtest/baddie1
. $testsrc/BASEFUNCS.sh
. $testsrc/RUNTIMEFILES.sh
# Avoid spurious differences because of the names of the
# various dwarfdump versions being tested.
  echo "====== command:  $dwdumper $opts $obj"  >> $ntimeout
# This only deals with names like /tmp*dwarfdump2 and /tmp*dwarfdump
# and .*/dwarfdump2 and .*/dwarfdump

echo "====== $ntimeout"

m() {
  dwdumper=$1
  obj=$2
  test=$3
  base=$4
  opts="$5"
  # Skip all this timing stuff. No longer wanted, really.
  #echo "====== command:  $dwdumper $opts $obj"  >> $ntimeout
  #echo "====== ntimeout $ntimeout wrtimen: $wrtimen"
  #echo "====== base: $base test: $test" 
  #echo "====== $wrtimen $dwdumper $opts  $obj"
  #$wrtimen 
  $dwdumper $opts $obj 1>junk1 2>&1
  unifyddname junk1 $test
  diff $base $test
  if test  $?  -ne 0
  then
      echo "fail test baddie1/$obj, mismatch base $base vs $test "
      echo "Update via cp $tf/$test $base"
      echo "rerun: $ts/runtest.sh"
      exit 1
  fi
}

# The test_sibling_loop.o will not terminate unless
# dwarfdump[2] is from February 2013 or later.
m $dd $ts/test_sibling_loop.o    testincorrecta            \
      $ts/incorrectdies.base         "-i -G"
m $dd $ts/badsiblingatchild      testincorrectatchild      \
      $ts/incorrectatchild.base  "-i -G"
m $dd $ts/badsiblingatitself     testincorrectatitself     \
      $ts/incorrectatitself.base     "-i -G"
m $dd $ts/badsiblingbeforeitself testincorrectbeforeitself \
      $ts/incorrectbeforeitself.base "-i -G"
m $dd $ts/badsiblingbeforechild  testincorrectbeforechild  \
      $ts/incorrectbeforechild.base  "-i -G"
m $dd $ts/badsiblingnest         testincorrectnest         \
      $ts/incorrectnest.base         "-i -G"
m $dd $ts/badsiblingnest2        testincorrectnest2        \
      $ts/incorrectnest2.base        "-i -G"
m $dd $ts/badsiblingnest2        testincorrectlinetab      \
      $ts/linetaberr.base            "-l"
echo "PASS baddie1/runtest.sh"
exit 0
