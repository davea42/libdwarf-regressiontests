#!/bin/sh
# Now no arguments needed.
# Testing the new dwarfgen and a new dwarfdump.

dd=../dwarfdump
dg=../dwarfgen
ddopts=" -M"
ddopts=
ourzcat=zcat
which gzcat 1>/dev/null
if [ $? -eq 0 ]
then
  # On MacOS gzcat does what zcat does on Linux.
  ourzcat=gzcat
fi

fix='s/.*last time 0x0 .*/last time 0x0/'

# FreeBSS 11.1 ctime() expands time 0 as start 1970, 
# Other Unix/Linux as end 1969

echo $dg -t obj -c 0  -o junk9.bin ./dwarfgen-bin 
$dg -t obj -c 0  -o junk9.bin ./dwarfgen-bin >junkgen9.out
echo $dd $ddopts -vvv  -a junk9.bin 
$dd $ddopts -vvv -a junk9.bin | sed "$fix"   >junk9.new
$ourzcat test9.base.gz | sed "$fix" >test9.base
diff test9.base junk9.new
if [  $?  -ne 0 ]
then
    echo FAIL dwgena test DWARF2 -vvv 9
    echo "update via: mv junk9.new test9.base ; gzip test9.base"
    exit 1
fi

echo "$dg -t obj -c 0  -o junk1.bin ./dwarfgen-bin output to junkgen1.out"
$dg -t obj -c 0  -o junk1.bin ./dwarfgen-bin >junkgen1.out
echo $dd  $ddopts -a junk1.bin 
$dd  $ddopts -a junk1.bin  | sed "$fix" >junk1.new
$ourzcat test1.base.gz | sed "$fix" >test1.base
diff test1.base junk1.new
if [  $?  -ne 0 ]
then
    echo FAIL dwgena test DWARF2 1
    echo "update via: mv junk1.new test1.base ; gzip test1.base"
    exit 1
fi

echo "$dd $ddopts -a -vvv junk1.bin  output to junk2.new"
$dd $ddopts -a -vvv junk1.bin | sed "$fix" >junk2.new
$ourzcat test2.base.gz | sed "$fix" >test2.base
diff test2.base junk2.new
if [  $?  -ne 0 ]
then
    echo FAIL dwgena test 2
    echo "update via: mv junk2.new test2.base ; gzip test2.base"
    exit 1
fi
$dg -t obj -c 10 -o junk3.bin ./dwarfgen-bin >junkgen.out
echo $dd $ddopts -a junk3.bin 
$dd $ddopts -a junk3.bin |  sed "$fix"  >junk3.new
$ourzcat test3.base.gz |  sed "$fix"  >test3.base
diff test3.base junk3.new
if [  $?  -ne 0 ]
then
    echo FAIL dwgena test 3
    echo "update via: mv junk3.new test3.base ; gzip test3.base"
    exit 1
fi

echo $dd $ddopts -a -vvv junk3.bin 
$dd $ddopts -a -vvv junk3.bin |  sed "$fix"  >junk4.new
$ourzcat test4.base.gz |  sed "$fix"  >test4.base
diff test4.base junk4.new
if [  $?  -ne 0 ]
then
    echo FAIL dwgena test 4
    echo "update via: mv junk4.new test4.base ; gzip test4.base"
    exit 1
fi

# This has .debug_pubnames data.
echo $dg -t obj -c 2 -o junk5.bin ./dwarfdump-bin 
$dg -t obj -c 2 -o junk5.bin ./dwarfdump-bin >junkgen.out
echo $dd -a -y -p junk5.bin 
$dd -a -y -p junk5.bin |  sed "$fix"  >junk5.new
$ourzcat test5.base.gz |  sed "$fix"  >test5.base
diff test5.base junk5.new
if [  $?  -ne 0 ]
then
    echo FAIL dwgena test 5
    echo "update via: mv junk5.new test5.base ; gzip test5.base"
    exit 1
fi

echo $dg -v 3 -t obj -c 0  -o junk8.bin ./dwarfgen-bin
$dg -v 3 -t obj -c 0  -o junk8.bin ./dwarfgen-bin >junkgen8.out
echo $dd -vvv -a junk8.bin
$dd -vvv -a -vvv junk8.bin |  sed "$fix"  >junk8.new
$ourzcat test8.base.gz |  sed "$fix"  >test8.base
diff test8.base junk8.new
if [  $?  -ne 0 ]
then
    echo FAIL dwgena test DWARF3 8
    echo "update via: mv junk8.new test8.base ; gzip test8.base"
    exit 1
fi

echo $dg -v 4 -t obj -c 0  -o junk7.bin ./dwarfgen-bin
$dg -v 4 -t obj -c 0  -o junk7.bin ./dwarfgen-bin >junkgen7.out
echo $dd -vvv -a junk7.bin
$dd -vvv -a -vvv junk7.bin |  sed "$fix"  >junk7.new
$ourzcat test7.base.gz |  sed "$fix"  >test7.base
diff test7.base junk7.new
if [  $?  -ne 0 ]
then
    echo FAIL dwgena test DWARF4 7
    echo "update via: mv junk7.new test7.base ; gzip test7.base"
    exit 1
fi

echo $dg -v 5 -t obj -c 0  -o junk6.bin ./dwarfgen-bin
$dg -v 5 -t obj -c 0  -o junk6.bin ./dwarfgen-bin >junkgen6.out
echo $dd -vvv -a junk6.bin
$dd -a -vvv junk6.bin |  sed "$fix"  >junk6.new
$ourzcat test6.base.gz |  sed "$fix"  >test6.base
diff test6.base junk6.new
if [  $?  -ne 0 ]
then
    echo FAIL dwgena test DWARF5 6
    echo "update via: mv junk6.new test6.base ; gzip test6.base"
    exit 1
fi
echo "PASS dwgena/runtest.sh"
exit 0



