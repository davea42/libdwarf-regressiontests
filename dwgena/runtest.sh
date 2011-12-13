#! /bin/sh
# Assumes a single argument, naming a dwarfdump.
# So it's testing the new dwarfgen and a new dwarfdump.

dd=$1

../dwarfgen -t obj -c 0 ./dwarfgen-bin -o junk1.bin >junkgen.out
$dd -a junk1.bin >junk1.new
zcat test1.base.gz >test1.base
diff test1.base junk1.new
if [  $?  -ne 0 ]
then
    echo FAIL dwgena test 1
    exit 1
fi

$dd -a -vvv junk1.bin >junk2.new
zcat test2.base.gz >test2.base
diff test2.base junk2.new
if [  $?  -ne 0 ]
then
    echo FAIL dwgena test 2
    exit 1
fi
../dwarfgen -t obj -c 10 ./dwarfgen-bin -o junk3.bin >junkgen.out
$dd -a junk3.bin >junk3.new
zcat test3.base.gz >test3.base
diff test3.base junk3.new
if [  $?  -ne 0 ]
then
    echo FAIL dwgena test 3
    exit 1
fi

$dd -a -vvv junk3.bin >junk4.new
zcat test4.base.gz >test4.base
diff test4.base junk4.new
if [  $?  -ne 0 ]
then
    echo FAIL dwgena test 4
    exit 1
fi
echo PASS dwgena 
exit 0



