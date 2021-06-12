#!/bin/sh
. ../BASEFILES.sh
# We name temp files junk<something> as that way
# a normal 'make distclean' gets rid of them

dd=../dwarfdump
dg=../dwarfgen
ts=$testsrc/data16
tf=$bldtest/data16


# First a basic test that we can add data16
# to a trivial object file.
cc -g -O0 -c $ts/test.c
if [ $? -ne 0 ]
then
  echo fail data16 compile.
  exit 1
fi
mv test.o junktest.o
$dd -i -M junktest.o >junktest.ddo 
grep DW_FORM_data16 <junktest.ddo 1>/dev/null 2>/dev/null
if [ $? -eq 0 ]
then
 echo fail data16 already have DW_FORM_data16
 echo "rerun: $ts/runtest.sh"
 exit 1
fi

$dg --adddata16 -t obj -c 0 -o junk.bin  ./junktest.o 1>junk1.out 2>junkstderr.out 
if [ $? -ne 0 ]
then
  echo fail data16 build junk.bin from dwarfgen
  echo "rerun: $ts/runtest.sh"
  exit 1
fi
$dd -i -M junk.bin  >junkdata16.new 2>/dev/null
if [ $? -ne 0 ]
then
  echo fail data16 dwarfdump junk.bin from dwarfgen
  echo "rerun: $ts/runtest.sh"
  exit 1
fi
grep DW_FORM_data16 <junkdata16.new 1>/dev/null 2>/dev/null
if [ $? -ne 0 ]
then
  echo fail data16 failed to add data16 to junktest.o  by dwarfgen
  echo "rerun: $ts/runtest.sh"
  exit 1
fi

echo PASS data16
exit 0
