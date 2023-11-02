#!/bin/sh

. ../BASEFILES.sh
ts=$testsrc/guilfanov2
tf=$bldtest/guilfanov2

../dwarfdump -a $ts/double-free-poc >junkn
diff $diffopt $ts/double-free-poc.base junkn
if [ $? -ne 0 ]
then
  echo "FAIL dwarfdump -a guilfanov2/double-free-poc"
  echo "To update baseline: mv $tf/junkn $ts/double-free-poc.base"
  echo "rerun: $ts/runtest.sh"
  exit 1
fi
exit 0
