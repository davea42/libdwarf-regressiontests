#!/bin/sh

# We name temp files junk<something> as that way
# a normal 'make distclean' gets rid of them

dd=../dwarfdump

. ../BASEFILES.sh
ts=$testsrc/mustacchi
tf=$bldtest/mustacchi

. $testsrc/BASEFUNCS.sh
cpifmissing $ts/m64t.o m64t.o
cpifmissing $ts/m32t.o m32t.o

$dd -i -M m64t.o >junktest64.x 
$dd -i -M m32t.o >junktest.x 

grep foo <junktest.x 1>/dev/null 2>/dev/null
if [ $? -ne 0 ]
then
 echo "FAIL mustacchi  nolibelf $ts/m32t.o missing foo symbol"
 exit 1
fi


diff $ts/m32out.base junktest.x
if [ $? -ne 0 ]
then
  echo "FAIL mustacchi m32t.o nolibelf output does not match."
  echo "If the new version is correct, update with:"
  echo "   mv $tf/junktest.x $ts/m32out.base"
  exit 1
fi


diff $ts/m64out.base junktest64.x
if [ $? -ne 0 ]
then
  echo "FAIL mustacchi m64t.o nolibelf output does not match."
  echo "If the new version is correct, update with:"
  echo "   mv $tf/junktest64.x $ts/m64out.base"
  exit 1
fi

echo "PASS mustacchi/runtestnolibelf.sh"
exit 0
