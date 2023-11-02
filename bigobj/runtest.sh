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
. ../BASEFILES.sh
if [ $# -lt 1 ]
then
  dd=../dwarfdump
else
  dd=$1
fi

bn=junkbigobj.new
bb=$testsrc/bigobj.base
bo=bigobject
rm -f makebig
rm -f bigobject
rm -f $bn

cc $testsrc/makebig.c -o makebig
if [ $? -ne 0 ]
then
  echo "fail bigobject compile of makebig.c"
  echo "rerun: $ts/runtest.sh"
  exit 1
fi

./makebig 2500000000
if [ $? -ne 0 ]
then
  echo "fail bigobject creation"
  echo "rerun: $ts/runtest.sh"
  exit 1
fi

if [ ! -f ./bigobject ]
then
  echo "fail the file bigobject does not exist"
  echo "rerun: $ts/runtest.sh"
  exit 1
fi

$dd bigobject  1> $bn 2>&1 
if [ $? -ne 0 ]
then
  echo "fail  dwarfdump of bigobject"
  rm -f bigobject
  echo "rerun: $ts/runtest.sh"
  exit 1
fi

diff $diffopt $bb $bn
if [ $? -ne 0 ]
then
  echo "fail bigobject diff $bb $bn"
  echo "to update: mv $bn $bb"
  echo "rerun: $ts/runtest.sh"
  exit 1
fi
rm -f bigobject
rm -f $bn
rm -f makebig
rm -f a.out
echo "PASS bigobj/runtest.sh"
exit 0

