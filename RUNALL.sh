


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

rm -f ALLdd 
rm -f ALLdd2 
rm -f ALLddtodd2
start=`date`
echo "start $start"
echo begin test dd
./DWARFTEST.sh dd 2>ALLdd 1>&2
chkres $? "Failure building test dd results"
chkfail ALLdd "running test dd"

echo begin test dd2
date
./DWARFTEST.sh dd2 2>ALLdd2 1>&2
chkres $? "Failure building test dd2 results"
chkfail ALLdd2 "running test dd2"

echo begin test ddtodd2
date
./DWARFTEST.sh ddtodd2 2>ALLddtodd2 1>&2
chkres $? "Failure building test ddtodd2 results"
chkfail ALLddtodd2 "running test ddtodd2"

endt=`date`
echo "start $start"
echo "end   $endt"
exit 0
