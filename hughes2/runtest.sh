#!/bin/sh
if [ $# -ne 1 ]
then
   echo "fail hughes2/simplereader one arg required, not $#"
   echo "fail  the arg required is an elf object full path "
   exit 1
fi
echo "Now run: hughes2/runtest.sh $1"
r=../simplereader
tobj=$1

. ../BASEFILES.sh
ts=$testsrc/hughes2
tf=$bldtest/hughes2

m() {
e=$1
opts=$2
t=$3
b=$4
bt=junk.$4
expcore=$5
rm -f *core*
$e $opts $t > $bt
if [ $expcore = 'y' ]
then
  if [ x$NLIZE != 'xy' ]
  then
    echo "sleep 1, sometimes core is slow to show up?"
    sleep 1
    echo "look for core: ls -l *core*: " `ls -l *core*` 
    if [ ! -f *core* ]  
    then
      ls -l *
      echo "fail hughes2/simplereader expected  corefile! "
      exit 1
    fi
  else
    echo 'hughes2 test 1: $NLIZE set so skip looking for corefile' 
  fi
else
  if [ x$NLIZE != 'xy' ]
  then
    if [ -f *core* ]  
    then
      echo "fail hughes2/simplereader got a corefile unexpectedly"
      exit 1
    fi
  else
    echo 'hughes2 test 2: $NLIZE set so skip checking on corefile' 
  fi
fi
diff $ts/$b $bt
if [ $? -ne 0 ]
then
    echo "fail hughes2/simplereader $e $opts $t" 
    echo "update with mv $bt $ts/$b"
    echo "rerun: $ts/runtest.sh"
    exit 1
fi

}
m "$r" "--passnullerror"                  $tobj ne.base  y
m "$r" "--simpleerrhand --passnullerror"  $tobj hne.base n
echo "PASS hughes2/runtest.sh simplereader (coredump was expected, ignore it)"
exit 0
