#!/bin/sh
#
#
. ../BASEFILES
cc -g -I $libdw/libdwarf  dwarfextract.c -o dwarfextract -L ../ -ldwarf -lelf
cc -g test1.c test2.c -o test1
./dwarfextract test1 test1out >basestdout
if [  $?  -ne 0 ] 
then
    echo FAIL dwarfextract
    exit 1
fi
diff basestdout basestdout.base
if [  $?  -ne 0 ] 
then
    echo FAIL dwarfextract dwex-1
    exit 1
fi
../dwarfdump -a test1out >test1.new
diff test1.base test1.new
if [  $?  -ne 0 ] 
then
    echo FAIL dwarfextract
    exit 1
fi
echo PASS dwarfextract

cc -g -DPRODUCER_INIT_C=1 -I $libdw/libdwarf  dwarfextract.c -o dwarfextractc -L .. -ldwarf -lelf
./dwarfextractc test1 testcout >basecstdout
if [  $?  -ne 0 ]
then
    echo FAIL dwarfextract c
    exit 1
fi
diff basecstdout basecstdout.base
if [  $?  -ne 0 ] 
then
    echo FAIL dwarfextract dwexc-1
    exit 1
fi
../dwarfdump -a testcout >testc.new
diff testc.base testc.new
if [  $?  -ne 0 ]
then
    echo FAIL dwarfextract c
    exit 1
fi
echo PASS dwarfextract c
exit 0
