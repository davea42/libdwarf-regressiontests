#!/bin/sh
#
# By default runs all 3 test sets.
# To run just one, add one  option, one of dd ddtodd2 or dd2

dodd=y
dodd2=y
doddtodd2=y

if [ $# -eq 0 ]
then
  echo "Running all 3 tests"
else
  if [ $# -eq 1 ]
  then
    dodd=n
    dodd2=n
    doddtodd2=n
    case $1 in
      dd) dodd=y ;;
      dd2) dodd2=y ;;
      ddtodd2) doddtodd2=y ;;
      *) echo "Incorrect arg, only one of: dd dd2 ddtodd2 allowed." ; exit 1 ;;
    esac
  else
    echo "Only one argument of: dd dd2 ddtodd2 allowed."
    exit 1
  fi
fi
echo "dd? $dodd dd2? $dodd2 ddtodd2? $doddtodd2"

chkres() {
if test $1 != 0
then
  echo "Test failure: $2"
  exit 2
fi
}

# We expect there to be 2 lines with the FAIL string
# in the message.
chkfail () {
  f=$1
  grep '^FAIL 0$' $f >junkck2 
  c=`wc -l <junkck2`
  if test $c -ne 2
  then
    rm -f junkck2
    echo "Failure $2"
    echo "We have $c lines saying FAIL 0 so something is wrong."
    echo "There should be two FAIL 0 lines if everything passed."
    echo "Here are the first few FAIL lines:"
    grep FAIL $f |head -10
    exit 2
  else
    echo "PASS $2"
  fi
  rm -f junkck2
}

if [ $dodd = "y" ]
then
  rm -f ALLdd 
fi
if [ $dodd2 = "y" ]
then
  rm -f ALLdd2 
fi
if [ $doddtodd2 = "y" ]
then
  rm -f ALLddtodd2
fi
start=`date`
echo "start $start"
if [ $dodd = "y" ]
then
  echo begin test dd
  ./DWARFTEST.sh dd 2>ALLdd 1>&2
  chkres $? "Failure building test dd results"
  chkfail ALLdd "running test dd"
fi

if [ $doddtodd2 = "y" ]
then
  echo begin test ddtodd2
  date
  ./DWARFTEST.sh ddtodd2 2>ALLddtodd2 1>&2
  chkres $? "Failure building test ddtodd2 results"
  chkfail ALLddtodd2 "running test ddtodd2"
fi

if [ $dodd2 = "y" ]
then
  echo begin test dd2
  date
  ./DWARFTEST.sh dd2 2>ALLdd2 1>&2
  chkres $? "Failure building test dd2 results"
  chkfail ALLdd2 "running test dd2"
fi


endt=`date`
echo "start $start"
echo "end   $endt"
exit 0
