#!/bin/sh

. ../BASEFILES.sh
ts=$testsrc/strsize
tf=$bldtest/strsize


dd=../dwarfdump
gen=../dwarfgen
t1=junkstdout
t2=junkstderr
ta=junkgen.o

rm -f $t1
rm -f $t2
rm -f $ta

$gen -s -t obj  -c 0 -o $ta $ts/createirepformfrombinary.o > $t1 2> $t2 
if [ $? -ne 0 ]
then
  echo "fail strsize/runtest.sh dwarfgen"
  echo "rerun: $ts/runtest.sh"
  exit 1
fi
echo "PASS strsize/runtest.sh dwarfgen"
exit 0
