#!/bin/sh
# Testing both implicit const FORM
# and DW_AT_SUN_func_offsets attribute.
# We name temp files junk<something> as that way
# a normal 'make distclean' gets rid of them

# We do not regenerate t1.o as we don't want
# compiler changes to mean the test becomes
# meaningless.

dd=../dwarfdump
dg=../dwarfgen

. ../BASEFILES.sh
ts=$testsrc/implicitconst
tf=$bldtest/implicitconst

. $testsrc/BASEFUNCS.sh
cpifmissing $ts/t1.o t1.o

$dg  -c 0 --add-implicit-const --add-sun-func-offsets -s -v 5 -t obj -o junkimplcon.o t1.o 1>junkdg.new 2>&1
if [ $? -ne 0 ]
then
 echo fail implicitconst in dwarfgen exit code not zero
 echo "rerun: $ts/runtest.sh"
 exit 1
fi
if [ ! -f $ts/implicitconst.bin ]
then
    # For runtest testing without dwarfgen
    cp junkimplcon.o $ts/implicitconst.bin
fi

diff $ts/dgout.base junkdg.new
if [ $? -ne 0 ]
then
  echo "fail implicitconst diff dgout.base junkdg.new
  echo "If junkdg.new is correct do: mv $tf/junkdg.new $ts/dgout.base
 echo "rerun: $ts/runtest.sh"
  exit 1
fi


$dd -i -M junkimplcon.o >junk.new
if [ $? -ne 0 ]
then
  echo fail $dd build /junk.new from junkimplcon.o
 echo "rerun: $ts/runtest.sh"
  exit 1
fi

diff $ts/implicit.base junk.new  
if [ $? -ne 0 ]
then
  echo "fail implicitconst diff implicit.base junk.new
  echo "If junk.new is correct do: mv $tf/junk.new $ts/implicit.base
 echo "rerun: $ts/runtest.sh"
  exit 1
fi
echo PASS implicitconst/runtest.sh
exit 0
