#!/bin/bash

# We name temp files junk<something> as that way
# a normal make distclean gets rid of them

dd=../dwarfdump
dg=../dwarfgen
cc -g -O0 -c test.c
if [ $? -ne 0 ]
then
  echo FAIL data16 compile.
  exit 1
fi
mv test.o junktest.o
$dg --adddata16 -t obj -c 0 -o junk.bin  ./junktest.o 1>junk1.out 2>junkstderr.out 
if [ $? -ne 0 ]
then
  echo FAIL data16 build junk.bin from dwarfgen
  exit 1
fi
$dd -i -M junk.bin  >junkdata16.new
if [ $? -ne 0 ]
then
  echo FAIL data16 dwarfdump junk.bin from dwarfgen
  exit 1
fi

diff data16.base junkdata16.new  1>/dev/null 2>/dev/null
if [ $? -ne 0 ]
then
  echo "FAIL data16 diff data16.base  junkdata16.new"
  echo "If data16.new is correct do: mv junkdata16.new data16.base"
  exit 1
fi

# This checks if dwarfgen works on data16
$dg -t obj -c 0 -o junk2.bin  ./junk.bin 1>junk2.out 2>junk2stderr.out
if [ $? -ne 0 ]
then
  echo FAIL data16 build junk2.bin  from dwarfgen
  exit 1
fi

$dd -i -M junk2.bin  >junk2data16.new
if [ $? -ne 0 ]
then
  echo FAIL data16 dwarfdump junk2.bin from dwarfgen
  exit 1
fi

diff data16-2.base junk2data16.new  1>/dev/null 2>/dev/null
if [ $? -ne 0 ]
then
  echo "FAIL data16 diff data16-2.base junk2data16.new"
  echo "If data16.new is correct do: mv junk2data16.new data16-2.base"
  exit 1
fi


echo PASS data16
exit 0



