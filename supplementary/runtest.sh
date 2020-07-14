#!/bin/sh

dd=../dwarfdump
rm -f junkn
$dd --print-debug-sup  dwarfstringsup.o  >junkn
diff sup1.base junkn
if [ $? -ne 0 ]
then
    echo "FAIL output of --print-debug-sup  dwarfstringsup.o"
    echo "To update baseline in supplementary/ directory"
    exho "  mv junkn sup1.base "
fi
echo "PASS supplementary/string
exit 0
