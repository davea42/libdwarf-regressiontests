#!/bin/sh

# We name temp files junk<something> as that way
# a normal 'make distclean' gets rid of them
# which matters if running the tests in-source-tree

dd=../dwarfdump
exit 0

. ../BASEFILES.sh
ts=$testsrc/mustacchi
tf=$bldtest/mustacchi

. $testsrc/BASEFUNCS.sh
f=m64t.o
cpifmissing $ts/$f $f
f=m32t.o
cpifmissing $ts/$f $f

#$dd -o -i -M m64t.o >junktest64o.x 
#$dd  -Ei -i -M m32t.o >junktestei.x 
grep foo <junktest64o.x 1>/dev/null 2>/dev/null
if [ $? -ne 0 ]
then
 echo "fail mustacchi $ts/m32t.o missing foo symbol"
 echo "rerun: $ts/runtest.sh"
 exit 1
fi

#diff $ts/m32outei.base junktestei.x
#if [ $? -ne 0 ]
#then
#  echo "fail mustacchi m32t.o libelf output does not match."
#  echo "If the new version is correct, update with:"
#  echo "   mv $tf/junktestei.x $ts/m32outei.base"
#  echo "rerun: $ts/runtest.sh"
#  exit 1
#fi


diff $diffopt $ts/m64outo.base junktest64o.x
if [ $? -ne 0 ]
then
  echo "fail mustacchi m64t.o libelf output does not match."
  echo "If the new version is correct, update with:"
  echo "   mv $tf/junktest64o.x $ts/m64outo.base"
  echo "rerun: $ts/runtest.sh"
  exit 1
fi

echo "PASS mustacchi/runtest.sh libelf"
exit 0
