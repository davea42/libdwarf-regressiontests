#!/bin/sh
#
# By default runs the entire test suite.
echo "Running all regressiontests tests"
. ./SHALIAS.sh

. ./BASEFILES.sh
chkres() {
if test $1 != 0
then
  echo "Test failure: $2"
  exit 2
fi
}

# We expect there to be 1 fail line saying "FAIL 0".
chkfail () {
  f=$1
  grep '^FAIL 0$' $f >junkck2 
  c=`wc -l <junkck2`
  if test $c -ne 1
  then
    rm -f junkck2
    echo "Failure $2"
    echo "We expected one line saying FAIL 0 so something is wrong."
    echo "Here are the first few lines with FAIL:"
    grep FAIL $f |head -n 5
    echo "Here are the last few lines of the test output:"
    tail -n 5 $f
    endt=`date`
  else
    echo "PASS $2"
  fi
  rm -f junkck2
}

loc=$bldtest
rm -f ALLdd 
start=`date`
echo "start regressiontests in $loc at: $start"
stsecs=`date '+%s'`
echo "Begin regressiontests    $loc/RUNALL.sh $withlibelf" 
echo "Write regressiontests to $loc/ALLdd" 
$testsrc/DWARFTEST.sh 2>ALLdd 1>&2
r=$?
chkres $r "Failure in $testsrc/DWARFTEST.sh."
chkfail ALLdd "RUNALL.sh regressiontests"
if [ $r -eq 0 ]
then
  echo "Status return 0 says PASS"
fi
ndsecs=`date '+%s'`
endt=`date`
echo "start regressiontests $start "
echo "end   regressiontests $endt"
showminutes() {
   t=`expr  \( $2 \- $1 \+ 29  \) \/ 60`
   echo "Run time in minutes: $t"
}
showminutes $stsecs $ndsecs
exit 0
