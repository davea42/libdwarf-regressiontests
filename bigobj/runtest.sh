#!/bin/sh
# Normal use:
#     sh runtest.sh [../dwarfdump]
# Creates a temp object bigobject which is
# over 2GB in size from the executable "hello".  
# Moves the section headers
# from hello up high in bigobject, over the 2GB size
# and zeros out the original section headers to guarantee
# that we will read the new copy or fail.
# Then verifies dwarfdump works.

dd=../dwarfdump
if [ $# -lt 1 ]
then
  dd=../dwarfdump
else
  dd=$1
fi

bn=junkbigobj.new
bb=bigobj.base
bo=bigobject
rm -f makebig
rm -f bigobject
rm -f $bn

gcc makebig.c -o makebig
if [ $? -ne 0 ]
then
  echo "FAIL bigobject compile of makebig.c"
  exit 1
fi

./makebig 2500000000
if [ $? -ne 0 ]
then
  echo "FAIL bigobject creation"
  exit 1
fi

if [ ! -f ./bigobject ]
then
  echo "FAIL the file bigobject does not exist"
  exit 1
fi

$dd bigobject  1> $bn 2>&1 
if [ $? -ne 0 ]
then
  echo "FAIL  dwarfdump of bigobject"
  rm -f bigobject
  exit 1
fi

diff $bb $bn
if [ $? -ne 0 ]
then
  echo "FAIL bigobject diff $bb $bn"
  echo "to update: mv $bn $bb"
  exit 1
fi
rm -f bigobject
rm -f $bn
rm -f makebig
rm -f a.out
echo PASS
exit 0

