#!/bin/sh
#
# By default runs the entire test suite.
echo "Running all  tests"
. ./SHALIAS.sh
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

rm -f ALLdd 
start=`date`
echo "start $start"
stsecs=`date '+%s'`
echo begin test
./DWARFTEST.sh dd 2>ALLdd 1>&2
chkres $? "Failure in DWARFTEST.sh. Possibly coredump new dwarfdump? "
chkfail ALLdd "running tests"
ndsecs=`date '+%s'`
endt=`date`
echo "start $start"
echo "end   $endt"
showminutes() {
   t=`expr  \( $2 \- $1 \+ 29  \) \/ 60`
   echo "Run time in minutes: $t"
}
showminutes $stsecs $ndsecs
exit 0
