#!/bin/sh

. ../BASEFILES.sh
ts=$testsrc/guilfanov
tf=$bldtest/guilfanov

../dwarfdump -a $ts/libdwarf_crash.elf >junkn
diff $diffopt $ts/crash.base junkn
if [ $? -ne 0 ]
then
  echo "FAIL dwarfdump -a -v -M guilfanov/libdwarf_crash.elf"
  echo "To update baseline: mv $tf/junkn $ts/crash.base"
  echo "rerun: $ts/runtest.sh"
  exit 1
fi
exit 0
