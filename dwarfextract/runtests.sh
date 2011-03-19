#!/bin/sh
#
#
./dwarfextract test1 test1out
../../dwarfdump/dwarfdump -a test1out >test1.new
diff test1.base test1.new
if [  $?  -ne 0 ] 
then
    echo FAIL dwarfextract
    exit 1
else
    echo PASS dwarfextract
fi
exit 0
