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

objf=dwarfdumpLE32V2.o
objf2=dwarfdumpLE64V4.o

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
tg3=junkadvlocvf
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
rm -f $tg3

if [ ! -x $gen ]
then
    echo "FAIL: Unable to find dwarfgen named $gen"
    exit 1
fi
if [ ! -x $dd ]
then
    echo "FAIL: Unable to find dwarfdump named $dd"
    exit 1
fi
if [ ! -x $sim ]
then
    echo "FAIL: Unable to find simplereader named $sim"
    exit 1
fi

$gen  --high-pc-as-const -t obj -c 0 -o $tx $objf  >$t4 2>/dev/null
#if [ $? -ne 0 ]
#then
#  echo "FAIL A run dwarfgen $gen  -h -t obj -c 0 -o $tx $objf" 
#  exit 1
#fi

# This one no conversion, DW_FORM_string.
$gen --show-reloc-details  -t obj -c 0 -o $ty $objf  >$t8 2> $t8e
#if [ $? -ne 0 ]
#then
#  echo "FAIL B run dwarfgen $gen -r  -t obj -c 0 -o $ty $objf"
#  exit 1
#fi
$dd -i -M $ty  >$t1 2> /dev/null
if [ $? -ne 0 ]
then
  echo "FAIL C run $dd -i -M $ty "
  exit 1
fi

# gens DW_FORM_strp
$gen --show-reloc-details  --default-form-strp  -t obj -c 0 -o $tz $objf |grep 'Debug_Str:'  >$t9 2> $t9e
#if [ $? -ne 0 ]
#then
#  echo "FAIL D run dwarfgen $gen -r  -s  -t obj -c 0 -o $tz $objf"
#  exit 1
#fi
echo Now show FORM_str and more for $tz >$ta
$dd -i -M $tz |grep DW_FORM_str  >>$ta 2> /dev/null
if [ $? -ne 0 ]
then
  echo "FAIL E run $dd -i -M $tz | grep DW_FORM_str"
  exit 1
fi

diff basestrpiM  $ta
if [ $? -ne 0 ]
then
    echo FAIL diff basestrpiM $ta . Object gen is $tz
    echo FAIL offsetfromlowpc/runtest.sh Generating strp strings
    echo "to update baseline do: mv $ta basestrpiM"
    exit 1
fi

diff basestrpgenout  $t9
if [ $? -ne 0 ]
then
    echo FAIL diff basestrpgenout $t9. Object gen is $tz
    echo FAIL offsetfromlowpc/runtest.sh Generating strp strings
    echo "to update baseline do: mv $t9 basestrpgenout"
    exit 1
fi


grep high_pc $t1 >$t5
echo Now show FORM_str for $ty >> $t5
grep DW_FORM_str $t1 >>$t5

diff  basehighpc1 $t5
if [ $? -ne 0 ]
then
    echo FAIL diff basehighpc1 $t5 object gen is $ty
    echo FAIL offsetfromlowpc/runtest.sh  incorrect list of high_pc data.
    echo "to update baseline do: mv $t5 basehighpc1"
    exit 1
fi

$dd -i -M $tx  >$t2 2> /dev/null
if [ $? -ne 0 ]
then
  echo "FAIL F run $dd -i -M $tx "
  exit 1
fi

grep high_pc $t2  >$t6 2>/dev/null

diff   basehighpc2 $t6
if [ $? -ne 0 ]
then
    echo "did: $gen  -h -t obj -c 0 -o $tx $objf  >$t4 "
    echo "did: $dd -i -M $tx > $t6"
    echo "did: diff   basehighpc2 $t6"
    echo FAIL diff basehighpc2 $t6
    echo "to update baseline do: mv $t6 basehighpc2"
    echo FAIL offsetfromlowpc/runtest.sh  incorrect transformed high_pc offset
    exit 1
fi

$sim --check $tx >$t3  2>/dev/null
if [ $? -ne 0 ]
then
  echo "FAIL G run $sim --check $tx "
  exit 1
fi

diff basehighpc3 $t3
if [ $? -ne 0 ]
then
    echo FAIL offsetfromlowpc/runtest.sh  mismatch transformation to offset
    echo "to update baseline do: mv $t3 basehighpc3"
    exit 1
fi

$sim --check $ty >$t7  2>/dev/null
if [ $? -ne 0 ]
then
  echo "FAIL H run $sim --check $tx "
  exit 1
fi
diff basehighpc4 $t7
if [ $? -ne 0 ]
then
    echo FAIL offsetfromlowpc/runtest.sh  mismatch non-transformation to offset
    echo "to update baseline do: mv $t7 basehipc4"
    exit 1
fi

$gen --add-frame-advance-loc -p 8 -f 4 -v 4  --high-pc-as-const -t obj -c 0 -o junk.o $objf2 >$tg1
if [ $? -ne 0 ]
then
  echo "FAIL K run $gen --add-frame-advance-loc ...  -h -t obj -c 0 -o junk.o $objf"
  exit 1
fi
$dd -vvv -f junk.o > $tg3     2>/dev/null
diff baseadvlocvf $tg3
if [ $? -ne 0 ]
then
    echo FAIL dwarfdump -vvv -f  junk.o offsetfromlowpc advloc err
    echo "to update baseline do: mv $tg3 baseadvlocvf"
    exit 1
fi

$dd -f junk.o  > $tg2      2>/dev/null
diff baseadvlocf $tg2
if [ $? -ne 0 ]
then
    echo FAIL dwarfdump -f junk.o  offsetfromlowpc advloc err
    echo "to update baseline do: mv $tg2 baseadvlocf"
    exit 1
fi

echo PASS offsetfromlowpc/runtest.sh
exit 0
