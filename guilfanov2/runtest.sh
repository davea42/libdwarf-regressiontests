#!/bin/sh

. ../BASEFILES.sh
ts=$testsrc/guilfanov2
tf=$bldtest/guilfanov2

../dwarfdump -a $ts/double-free-poc >junkn
diff $ts/double-free-poc.base junkn
if [ $? -ne 0 ]
then
  echo "FAIL dwarfdump -a guilfanov2/double-free-poc"
  echo "To update baseline: mv $tf/junkn $ts/double-free-poc.base"
  echo "rerun: $ts/runtest.sh"
  return 1
fi
return 0
