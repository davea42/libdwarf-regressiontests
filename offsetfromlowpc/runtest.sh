#!/bin/sh
# This should create testhipcoffset.o  with several
# instances of DW_AT_high_pc being a class constant (offset).
# The dwarfdump??.o has all the high pc as class address.
# WE don't check for non-zero exit codes of dwarfgen
# as with --enable-sanitized there are leaks.
# The add-frame-advance_loc don't fully work with
# 32 bit because the big address values get chopped to 32bit.

#set -x
# arg 1 is dwarfgen name, 2 is dwarfdumpname 3 is simplereader
gen=../dwarfgen
dd=../dwarfdump
sim=../simplereader
. ../BASEFILES
ts=$testsrc/offsetfromlowpc
tf=$bldtest/offsetfromlowpc


objf=$ts/dwarfdumpLE32V2.o
objf2=$ts/dwarfdumpLE64V4.o

tx=junktesthipcoffset.o
ty=junktesthipcoffsetorig.o
tz=junktesthipcoffsetstrp.o
ta=junkstrp.iM
t1=junk1.highpc
t2=junk2.highpc
t3=junk3.basehighpc3
t4=junk4.genout
t5=junkh.basehighpc1
t6=junk2h.basehighpc2
t7=junk.basehighpc4
t8=junk8.genout
t8e=junk8.genoutstderr
t9=junkstrp.genout
t9e=junkstrp.genoutstderr
tg1=junkadvlocgen
tg2=junkadvlocf
rm -f $tx
rm -f $ty
rm -f $tz
rm -f $ta
rm -f $t1
rm -f $t2
rm -f $t3
rm -f $t4
rm -f $t5
rm -f $t6
rm -f $t7
rm -f $t8
rm -f $t8e
rm -f $t9
rm -f $t9e
rm -f $tg1
rm -f $tg2

if [ ! -x $gen ]
then
    echo "fail: Unable to find dwarfgen named $gen"
    echo "rerun: $ts/runtest.sh"
    exit 1
fi
if [ ! -x $dd ]
then
    echo "fail: Unable to find dwarfdump named $dd"
    echo "rerun: $ts/runtest.sh"
    exit 1
fi
if [ ! -x $sim ]
then
    echo "fail: Unable to find simplereader named $sim"
    echo "rerun: $ts/runtest.sh"
    exit 1
fi

$gen  --high-pc-as-const -t obj -c 0 -o $tx $objf  >$t4 2>/dev/null
#if [ $? -ne 0 ]
#then
#  echo "fail A run dwarfgen $gen  -h -t obj -c 0 -o $tx $objf" 
#  exit 1
#fi

# This one no conversion, DW_FORM_string.
$gen --show-reloc-details  -t obj -c 0 -o $ty $objf  >$t8 2> $t8e
#if [ $? -ne 0 ]
#then
#  echo "fail B run dwarfgen $gen -r  -t obj -c 0 -o $ty $objf"
#  exit 1
#fi
$dd -i -M $ty  >$t1 2> /dev/null
if [ $? -ne 0 ]
then
  echo "fail C run $dd -i -M $ty "
  echo "rerun: $ts/runtest.sh"
  exit 1
fi

# gens DW_FORM_strp
$gen --show-reloc-details  --default-form-strp  -t obj -c 0 -o $tz $objf |grep 'Debug_Str:'  >$t9 2> $t9e
#if [ $? -ne 0 ]
#then
#  echo "fail D run dwarfgen $gen -r  -s  -t obj -c 0 -o $tz $objf"
#  exit 1
#fi
echo Now show FORM_str and more for $tz >$ta
$dd -i -M $tz |grep DW_FORM_str  >>$ta 2> /dev/null
if [ $? -ne 0 ]
then
  echo "fail E run $dd -i -M $tz | grep DW_FORM_str"
  echo "rerun: $ts/runtest.sh"
  exit 1
fi

diff $ts/basestrpiM  $ta
if [ $? -ne 0 ]
then
    echo fail diff basestrpiM $ta . Object gen is $tz
    echo fail offsetfromlowpc/runtest.sh Generating strp strings
    echo "to update baseline do: mv $tf/$ta $ts/basestrpiM"
    echo "rerun: $ts/runtest.sh"
    exit 1
fi

diff $ts/basestrpgenout  $t9
if [ $? -ne 0 ]
then
    echo fail diff basestrpgenout $t9. Object gen is $tz
    echo fail offsetfromlowpc/runtest.sh Generating strp strings
    echo "to update baseline do: mv $tf/$t9 $ts/basestrpgenout"
    echo "rerun: $ts/runtest.sh"
    exit 1
fi


grep high_pc $t1 >$t5
echo Now show FORM_str for $ty >> $t5
grep DW_FORM_str $t1 >>$t5

diff  $ts/basehighpc1 $t5
if [ $? -ne 0 ]
then
    echo fail diff basehighpc1 $t5 object gen is $ty
    echo fail offsetfromlowpc/runtest.sh  incorrect list of high_pc data.
    echo "to update baseline do: mv $tf/$t5 $ts/basehighpc1"
    echo "rerun: $ts/runtest.sh"
    exit 1
fi

$dd -i -M $tx  >$t2 2> /dev/null
if [ $? -ne 0 ]
then
  echo "fail F run $dd -i -M $tx "
  exit 1
fi

grep high_pc $t2  >$t6 2>/dev/null

bas=basehighpc2
diff  $ts/$bas $t6
if [ $? -ne 0 ]
then
    echo "did: $gen  -h -t obj -c 0 -o $tx $objf  >$t4 "
    echo "did: $dd -i -M $tx > $t6"
    echo "did: diff $bas $t6"
    echo fail diff basehighpc2 $t6
    echo "to update baseline do: mv $tf/$t6 $ts/$bas"
    echo fail offsetfromlowpc/runtest.sh  incorrect transformed high_pc offset
    echo "rerun: $ts/runtest.sh"
    exit 1
fi

$sim --check $tx >$t3  2>/dev/null
if [ $? -ne 0 ]
then
  echo "fail G run $sim --check $tx "
  echo "rerun: $ts/runtest.sh"
  exit 1
fi

bas=basehighpc3
diff $ts/$bas $t3
if [ $? -ne 0 ]
then
  echo "fail offsetfromlowpc/runtest.sh mismatch transformation to offset"
  echo "to update baseline do: mv $tf/$t3 $ts/$bas"
  echo "rerun: $ts/runtest.sh"
  exit 1
fi

$sim --check $ty >$t7  2>/dev/null
if [ $? -ne 0 ]
then
  echo "fail H run $sim --check $tx "
  exit 1
fi
bas=basehighpc4
diff $ts/$bas $t7
if [ $? -ne 0 ]
then
  echo fail dwarfdump -vvv -f  junk.o offsetfromlowpc advloc err
  echo "to update baseline do: mv $tf/$t7 $ts/$bas"
  echo "rerun: $ts/runtest.sh"
  exit 1
fi

bas=baseadvlocf
$dd -f junk.o  > $tg2      2>/dev/null
diff $ts/$bas $tg2
if [ $? -ne 0 ]
then
  echo "fail dwarfdump -f junk.o  offsetfromlowpc advloc err"
  echo "to update baseline do: mv $tf/$tg2 $ts/$bas"
  echo "rerun: $ts/runtest.sh"
  exit 1
fi

echo PASS offsetfromlowpc/runtest.sh
exit 0
