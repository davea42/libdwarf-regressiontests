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
diff $ts/test1.base junk1
if [ $? -ne 0 ]
then
   echo "fail nolibelf test 1 diff test1.base junk1"
   echo "If junk1 is correct do: mv $tf/junk1 $ts/test1.base"
   echo "rerun: $ts/runtest.sh"
   exit 1
fi

#$dd -E test.o  >junk2 2>&1
#r=$?
#if [ $r -ne 0 ]
#then
#  echo "fail 2 nolibelf -E test.o"
#  exit 1
#fi
#diff $ts/test2.base junk2
#if [ $? -ne 0 ]
#then
#   echo "fail nolibelf test 2 diff test2.base junk2"
#   echo "If junk2 is correct do: mv $tf/junk2 $ts/test2.base"
#   echo "rerun: $ts/runtest.sh"
#   exit 1
#fi

#$dd -o test.o >junk3 2>&1
#r=$?
#if [ $r -ne 0 ]
#then
#  echo "fail 3 nolibelf -o test.o"
#  exit 1
#fi
#diff  $ts/test3.base junk3
#if [ $? -ne 0 ]
#then
#   echo "fail nolibelf test 3 diff test3.base junk3"
#   echo "If junk3 is correct do: mv $tf/junk3 $ts/test3.base"
#   echo "rerun: $ts/runtest.sh"
#   exit 1
#fi

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
