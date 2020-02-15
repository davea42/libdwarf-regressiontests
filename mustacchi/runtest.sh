#!/bin/sh

# We name temp files junk<something> as that way
# a normal 'make distclean' gets rid of them

dd=../dwarfdump

$dd -o -i -M m64t.o >junktest64o.x 

$dd  -Ei -i -M m32t.o >junktestei.x 
grep foo <junktest64o.x 1>/dev/null 2>/dev/null
if [ $? -ne 0 ]
then
 echo "FAIL mustacchi m32t.o missing foo symbol"
 exit 1
fi


diff m32outei.base junktestei.x
if [ $? -ne 0 ]
then
  echo "FAIL mustacchi m32t.o libelf output does not match."
  echo "If the new version is correct, update with:"
  echo "   mv junktestei.x m32outei.base"
  exit 1
fi


diff m64outo.base junktest64o.x
if [ $? -ne 0 ]
then
  echo "FAIL mustacchi m64t.o libelf output does not match."
  echo "If the new version is correct, update with:"
  echo "   mv junktest64o.x m64outo.base"
  exit 1
fi

echo "PASS mustacchi/runtest.sh libelf"
exit 0
