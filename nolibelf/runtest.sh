dd=../dwarfdump

. ../BASEFILES.sh
ts=$testsrc/nolibelf
tf=$bldtest/nolibelf

. $testsrc/BASEFUNCS.sh

cpifmissing $ts/test.o test.o
cpifmissing $ts/test.a test.a

$dd -a test.o >junk1 2>&1
r=$?
if [ $r -ne 0 ]
then
  echo "fail 1 nolibelf -a test.o"
  exit 1
fi
diff $diffopt $ts/test1.base junk1
if [ $? -ne 0 ]
then
   echo "fail nolibelf test 1 diff test1.base junk1"
   echo "If junk1 is correct do: mv $tf/junk1 $ts/test1.base"
   echo "rerun: $ts/runtest.sh"
   exit 1
fi

$dd -i test.a  >junk4 2>&1
r=$?
if [ $r -ne 0 ]
then
  echo "fail 4 nolibelf -i test.a"
  exit 1
fi
diff  $ts/test4.base junk4
if [ $? -ne 0 ]
then
   echo "fail nolibelf test 4 diff test4.base junk4"
   echo "If junk4 is correct do: mv $tf/junk4 $ts/test4.base"
   echo "rerun: $ts/runtest.sh"
   exit 1
fi
echo PASS nolibelf/runtest.sh
