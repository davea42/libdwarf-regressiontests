#!/bin/sh

. ../BASEFILES.sh
ts=$testsrc/supplementary
tf=$bldtest/supplementary


dd=../dwarfdump
rm -f junkn
$dd --print-debug-sup  $ts/dwarfstringsup.o  >junkn
diff $diffopt $ts/sup1.base junkn
if [ $? -ne 0 ]
then
    echo "fail output of --print-debug-sup  dwarfstringsup.o"
    echo "To update baseline in supplementary/ directory"
    echo "  mv $tf/junkn $ts/sup1.base "
    echo "rerun: $ts/runtest.sh"
    exit 1
fi
echo "PASS supplementary/runtest.sh of .debug_sup printing"
exit 0
