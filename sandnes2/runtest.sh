#!/bin/sh
. ../BASEFILES.sh
ts=$testsrc/sandnes2
tf=$bldtest/sandnes2

../dwarfdump -a $ts/cu_dir_added_to_complete_path.elf >junk.base
grep 'c:/programs/' <junk.base >junk.hasout
r=$?
if [ $r -ne 0 ]
then
   echo "fail sandnes2 missing path concat"
   echo "rerun: $ts/runtest.sh"
   exit 1
fi
# As of 0.1.0 we do not need dwarfdumpW as
# regular dwarfdump handles it all.
../dwarfdump -a $ts/cu_dir_added_to_complete_path.elf >junk.W
grep 'c:\\temp\\' <junk.W >junk.noout
r=$?
if [ $r -ne 0 ]
then
   echo "fail sandnes2 Failed to transform name: $r"
   echo "rerun: $ts/runtest.sh"
   exit 1
fi
echo PASS sandnes2/runtest.sh
# success!
exit 0

