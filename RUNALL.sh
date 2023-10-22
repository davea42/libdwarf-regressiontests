#!/usr/bin/env sh
#
# Runs the entire test suite in your testing directory
# where this is all run, for example /var/tmp/dwtest .
# In the test directory execute 
#    /path/to/configure 
# (using a full path, with no configure options) before RUNALL.sh .
# 
# configure up SHALIAS.sh and BASEFILES.sh in your testing directory.

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

# We expect there to be 1 fail line saying "FAIL     count: 0"
finalfailcheck () {
  f=$1
  grep '^FAIL     count: 0$' $f >junkck2 
  c=`wc -l <junkck2`
  if test $c -ne 1
  then
    rm -f junkck2
    echo "Failure $2"
    echo "We expected one line saying FAIL     count: 0"
    echo "so something is wrong."
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
$testsrc/CHECKIFRUNNING.sh
chkres $? "Checking if tests running already"
$testsrc/PICKUPBIN.sh
chkres $? "Trying to build from libdwarf etc sources"

loc=$bldtest
rm -f ALLdd 
start=`date`
echo "start regressiontests in $loc at: $start"
stsecs=`date '+%s'`
echo "Begin regressiontests    $testsrc/RUNALL.sh "
echo "Write regressiontests to $loc/ALLdd" 
$testsrc/DWARFTEST.sh 2>ALLdd 1>&2
r=$?
chkres $r "Failure in $testsrc/DWARFTEST.sh."
finalfailcheck ALLdd "RUNALL.sh regressiontests"
finalpass=
if [ $r -eq 0 ]
then
  echo "Status return 0 says PASS"
  finalpass=y
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
if test "$finalpass" = "y" ; then
  $testsrc/CLEANUP.sh
else
  echo "Not cleaning up due to error"
  echo "Run $testsrc/CLEANUP.sh to clean up here"
fi
exit 0
