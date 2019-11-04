#!/bin/sh
#
# By default runs the entire test suite.
echo "Running all regressiontests tests"
. ./SHALIAS.sh

# dwarfgen and libelf go together here.
withlibelf="withlibelf"
if [ $# -gt 0 ]
then
  withlibelf="withlibelf"
  if [ $1 = "nolibelf" ]
  then
     echo "RUNALL.sh arg is nolibelf" 
     withlibelf="nolibelf"
  else
     if [ $1 != "withlibelf" ]
     then
       echo "Improper argument to RUNALL.sh, use withlibelf or nolibelf"
       exit 1
     fi
     echo "RUNALL.sh arg is withlibelf" 
  fi
else
  echo "RUNALL.sh arg defaults to withlibelf" 
fi


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

loc=`pwd`
rm -f ALLdd 
start=`date`
echo "start regressiontests in $loc at: $start"
stsecs=`date '+%s'`
echo "Begin regressiontests    $loc/RUNALL.sh $withlibelf" 
echo "Write regressiontests to $loc/ALLdd" 
./DWARFTEST.sh $withlibelf 2>ALLdd 1>&2
chkres $? "Failure in regressiontests DWARFTEST.sh."
chkfail ALLdd "RUNALL.sh regressiontests"
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
