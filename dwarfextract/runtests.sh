#!/bin/sh
#
#
. ../BASEFILES
cc -g -I $libdw/libdwarf  dwarfextract.c -o dwarfextract -L ../libdwarf -ldwarf -lelf
cc -g test1.c test2.c -o test1
./dwarfextract test1 test1out
if [  $?  -ne 0 ] 
then
    echo FAIL dwarfextract
    exit 1
fi
../dwarfdump -a test1out >test1.new
diff test1.base test1.new
if [  $?  -ne 0 ] 
then
    echo FAIL dwarfextract
    exit 1
else
    echo PASS dwarfextract
fi

cc -g -DDWARF_PRODUCER_C=1 -I $libdw/libdwarf  dwarfextract.c -o dwarfextractc -L ../libdwarf -ldwarf -lelf
./dwarfextractc test1 testcout
if [  $?  -ne 0 ]
then
    echo FAIL dwarfextract c
    exit 1
fi
../dwarfdump -a testcout >testc.new
diff testc.base testc.new
if [  $?  -ne 0 ]
then
    echo FAIL dwarfextract c
    exit 1
else
    echo PASS dwarfextract c
fi


exit 0
