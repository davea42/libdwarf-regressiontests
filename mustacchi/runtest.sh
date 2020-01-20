#!/bin/sh

# We name temp files junk<something> as that way
# a normal 'make distclean' gets rid of them

dd=../dwarfdump

$dd -i -M m32t.o >junktest.x 
grep foo <junktest.x 1>/dev/null 2>/dev/null
if [ $? -ne 0 ]
then
 echo "FAIL mustacchi m32t.o missing foo symbol"
 exit 1
fi

diff m32out.base junktest.x
if [ $? -ne 0 ]
then
  echo "FAIL mustacchi m32t.o dwarfdump output does not match."
  echo "If the new version is correct, update with:"
  echo "   mv junktest.x m32out.base"
  exit 1
fi

echo "PASS mustacchi/runtest.sh"
exit 0
