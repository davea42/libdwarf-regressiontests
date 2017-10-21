#!/bin/bash

# We name temp files junk<something> as that way
# a normal 'make distclean' gets rid of them

dd=../dwarfdump
dg=../dwarfgen

# First a basic test that we can add data16
# to a trivial object file.
cc -g -O0 -c test.c
if [ $? -ne 0 ]
then
  echo FAIL data16 compile.
  exit 1
fi
mv test.o junktest.o
$dd -i -M junktest.o >junktest.ddo 
grep DW_FORM_data16 <junktest.ddo 1>/dev/null 2>/dev/null
if [ $? -eq 0 ]
then
 echo FAIL data16 already have DW_FORM_data16
 exit 1
fi

$dg --adddata16 -t obj -c 0 -o junk.bin  ./junktest.o 1>junk1.out 2>junkstderr.out 
if [ $? -ne 0 ]
then
  echo FAIL data16 build junk.bin from dwarfgen
  exit 1
fi
$dd -i -M junk.bin  >junkdata16.new 2>/dev/null
if [ $? -ne 0 ]
then
  echo FAIL data16 dwarfdump junk.bin from dwarfgen
  exit 1
fi
grep DW_FORM_data16 <junkdata16.new 1>/dev/null 2>/dev/null
if [ $? -ne 0 ]
then
 echo FAIL data16 failed to add data16 to junktest.o  by dwarfgen
 exit 1
fi



# Now ensure that the full dwarfdump output is unchanged
# measured against a saved object: test.bin
$dd -i -M  test.bin  >junkdata16.new 2>/dev/null
if [ $? -ne 0 ]
then
  echo FAIL data16 dwarfdump -i -M data16.bin from dwarfgen
  exit 1
fi

diff data16.base junkdata16.new  1>/dev/null 2>/dev/null
if [ $? -ne 0 ]
then
  echo "FAIL data16 diff data16.base  junkdata16.new"
  echo "If data16.new is correct do: mv junkdata16.new data16.base"
  exit 1
fi


# This checks if dwarfgen works on test.bin
$dg -t obj --adddata16 -c 0 -o junk3.bin  ./test.bin 1>junk2.out 2>junk2stderr.out
if [ $? -ne 0 ]
then
  echo FAIL data16 build junk2.bin  from junk.bin via dwarfgen
  exit 1
fi

#Now lets see if adding data16 worked.
$dd -i -M junk3.bin  >junk2data16.new 2>/dev/null
if [ $? -ne 0 ]
then
  echo FAIL data16 dwarfdump on junk3.bin from dwarfgen
  exit 1
fi

grep DW_FORM_data16 <junk2data16.new 1>junk4data16.new 2>/dev/null
if [ $? -ne 0 ]
then
 echo FAIL data16 failed to add data16 to test.bin by dwarfgen
 exit 1
fi

diff data16-2.base junk4data16.new  1>/dev/null 2>/dev/null
if [ $? -ne 0 ]
then
  echo "FAIL data16 diff data16-2.base junk4data16.new"
  echo "If data16.new is correct do: mv junk4data16.new data16-2.base"
  exit 1
fi


echo PASS data16
exit 0



