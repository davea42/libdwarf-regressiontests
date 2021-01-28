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
. ../BASEFILES

fix='s/.*last time 0x0 .*/last time 0x0/'

# FreeBSS 11.1 ctime() expands time 0 as start 1970, 
# Other Unix/Linux as end 1969
ts=$testsrc/dwgena
tf=$bldtest/dwgena

b=test9.base
bz=test9.base.gz
j=junk9.new
echo $dg -t obj -c 0  -o junk9.bin $ts/dwarfgen-bin 
$dg -t obj -c 0  -o junk9.bin $ts/dwarfgen-bin >junkgen9.out
echo $dd $ddopts -vvv  -a junk9.bin 
$dd $ddopts -vvv -a junk9.bin | sed "$fix"   > $j
$ourzcat $ts/$bz | sed "$fix" > $b
diff $b $j
if [  $?  -ne 0 ]
then
    echo fail dwgena test DWARF2 -vvv 9
    echo "update via  by : cd $tf ; cp $j $b "
    echo "  gzip $b ; mv $bz $ts"
    echo "rerun: $ts/runtest.sh "
    exit 1
fi

b=test1.base
bz=test1.base.gz
j=junk1.new
echo "$dg -t obj -c 0  -o junk1.bin $ts/dwarfgen-bin output to junkgen1.out"
$dg -t obj -c 0  -o junk1.bin $ts/dwarfgen-bin >junkgen1.out
echo $dd  $ddopts -a junk1.bin 
$dd  $ddopts -a junk1.bin  | sed "$fix" >$j
$ourzcat $ts/$bz | sed "$fix" >$b
diff $b $j
if [  $?  -ne 0 ]
then
    echo fail dwgena test DWARF2 1
    echo "update via: cd $tf ;  cp $j $b "
    echo "  gzip $b ; mv $bz $ts"
    echo "rerun: $ts/runtest.sh "
    exit 1
fi

b=test2.base
bz=test2.base.gz
j=junk2.new
echo "$dd $ddopts -a -vvv junk1.bin  output to junk2.new"
$dd $ddopts -a -vvv junk1.bin | sed "$fix" >junk2.new
$ourzcat $ts/$bz | sed "$fix" >$b
diff $b $j
if [  $?  -ne 0 ]
then
    echo fail dwgena test 2
    echo "update via: cd $tf ; cp $j $b "
    echo "  gzip $b ; mv $bz $ts"
    echo "rerun: $ts/runtest.sh "
    exit 1
fi


b=test3.base
bz=test3.base.gz
j=junk3.new
$dg -t obj -c 10 -o junk3.bin $ts//dwarfgen-bin >junkgen.out
echo $dd $ddopts -a junk3.bin 
$dd $ddopts -a junk3.bin |  sed "$fix"  >$j
$ourzcat $ts/$bz |  sed "$fix"  >$b
diff $b $j
if [  $?  -ne 0 ]
then
    echo fail dwgena test 3
    echo "update via: cd $tf ; cp $j $b "
    echo "  gzip $b ; mv $bz $ts"
    echo "rerun: $ts/runtest.sh "
    exit 1
fi

b=test4.base
bz=test4.base.gz
j=junk4.new
echo $dd $ddopts -a -vvv junk3.bin 
$dd $ddopts -a -vvv junk3.bin |  sed "$fix"  >$j
$ourzcat $ts/$bz |  sed "$fix"  >$b
diff $b $j
if [  $?  -ne 0 ]
then
    echo fail dwgena test 4
    echo "update via: cd $tf ; cp $j $b "
    echo "  gzip $b ; mv $bz $ts"
    echo "rerun: $ts/runtest.sh "
    exit 1
fi

b=test5.base
bz=test5.base.gz
j=junk5.new
# This has .debug_pubnames data.
echo $dg -t obj -c 2 -o junk5.bin $ts/dwarfdump-bin 
$dg -t obj -c 2 -o junk5.bin $ts/dwarfdump-bin >junkgen.out
echo $dd -a -y -p junk5.bin 
$dd -a -y -p junk5.bin |  sed "$fix"  >$j
$ourzcat $ts/$bz |  sed "$fix"  >$b
diff $b $j
if [  $?  -ne 0 ]
then
    echo fail dwgena test 5
    echo "update via: cd $tf ; cp $j $b "
    echo "  gzip $b ; mv $bz $ts"
    echo "rerun: $ts/runtest.sh "
    exit 1
fi

b=test8.base
bz=test8.base.gz
j=junk8.new
echo $dg -v 3 -t obj -c 0  -o junk8.bin $ts/dwarfgen-bin
$dg -v 3 -t obj -c 0  -o junk8.bin $ts/dwarfgen-bin >junkgen8.out
echo $dd -vvv -a junk8.bin
$dd -vvv -a -vvv junk8.bin |  sed "$fix"  >$j
$ourzcat $ts/$bz |  sed "$fix"  >$b
diff $b $j
if [  $?  -ne 0 ]
then
    echo fail dwgena test DWARF3 8
    echo "update via: cd $tf"  
    echo "  cp $j $b "
    echo "  gzip $b ; mv $bz $ts"
    echo "rerun: $ts/runtest.sh "
    exit 1
fi

b=test7.base
bz=test7.base.gz
j=junk7.new
echo $dg -v 4 -t obj -c 0  -o junk7.bin $ts/dwarfgen-bin
$dg -v 4 -t obj -c 0  -o junk7.bin $ts/dwarfgen-bin >junkgen7.out
echo $dd -vvv -a junk7.bin
$dd -vvv -a -vvv junk7.bin |  sed "$fix"  >$j
$ourzcat $ts/$bz  |  sed "$fix"  >$b
diff test7.base junk7.new
if [  $?  -ne 0 ]
then
    echo fail dwgena test DWARF4 7
    echo "update via: cd $tf ; cp $j $b "
    echo "  gzip $b ; mv $bz $ts"
    echo "rerun: $ts/runtest.sh "
    exit 1
fi

b=test6.base
bz=test6.base.gz
j=junk6.new
echo $dg -v 5 -t obj -c 0  -o junk6.bin $ts/dwarfgen-bin
$dg -v 5 -t obj -c 0  -o junk6.bin $ts/dwarfgen-bin >junkgen6.out
echo $dd -vvv -a junk6.bin
$dd -a -vvv junk6.bin |  sed "$fix"  >$j
$ourzcat $ts/$bz |  sed "$fix"  >$b
diff $b $j
if [  $?  -ne 0 ]
then
    echo fail dwgena test DWARF5 6
    echo "update via: cd $tf ; cp $j $b "
    echo "  gzip $b ; mv $bz $ts"
    echo "rerun: $ts/runtest.sh "
    exit 1
fi
echo "PASS dwgena/runtest.sh"
exit 0



