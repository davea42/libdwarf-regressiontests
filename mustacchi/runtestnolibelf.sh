#!/bin/sh

# We name temp files junk<something> as that way
# a normal 'make distclean' gets rid of them

dd=../dwarfdump

$dd -i -M m64t.o >junktest64.x 
$dd -i -M m32t.o >junktest.x 

grep foo <junktest.x 1>/dev/null 2>/dev/null
if [ $? -ne 0 ]
then
 echo "FAIL mustacchi  nolibelf m32t.o missing foo symbol"
 exit 1
fi


diff m32out.base junktest.x
if [ $? -ne 0 ]
then
  echo "FAIL mustacchi m32t.o nolibelf output does not match."
  echo "If the new version is correct, update with:"
  echo "   mv junktest.x m32out.base"
  exit 1
fi


diff m64out.base junktest64.x
if [ $? -ne 0 ]
then
  echo "FAIL mustacchi m64t.o nolibelf output does not match."
  echo "If the new version is correct, update with:"
  echo "   mv junktest64.x m64out.base"
  exit 1
fi

echo "PASS mustacchi/runtestnolibelf.sh"
exit 0
