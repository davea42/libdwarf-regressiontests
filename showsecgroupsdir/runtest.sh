#!/bin/sh
sg=../showsectiongroups
finalexit=0

. ../BASEFILES.sh

ts=$testsrc/showsecgroupsdir
tf=$bldtest/showsecgroupsdir
. $testsrc/BASEFUNCS.sh


set -x
rm -f junk.sgtestout
rm -f junk.sgtest2out
onetest() {
   g="$1"
   f="$2"
   o="$3"
   x=`basename $f`
   echo "======== showsecgroups $g $x   ========" >> "$o"
   if [ "$g" = "n" ]
   then
     $sg $f  >> "$o"
   else
     $sg $g $f >> "$o"
   fi
}

onetest n $testsrc/debugfission/archive.o junk.sgtestout
onetest n $testsrc/debugfission/archive.dwo junk.sgtestout
onetest n $testsrc/debugfission/target.o junk.sgtestout
onetest n $testsrc/debugfission/target.dwo junk.sgtestout

echo "There is no group 1 in target.dwo so it gets NO ENTRY"  >>junk.sgtestout
onetest "-group 1" $testsrc/debugfission/target.dwo junk.sgtestout

diff $ts/sgtest.baseline junk.sgtestout
if [ $? -ne 0 ]
then
  echo "FAIL diff $ts/sgtest.baseline $tf/junk.sgtestout"
  echo "To update: mv $tf/junk.sgtestout $ts/sgtest.baseline"
  echo "rerun: $ts/runtest.sh"
  finalexit=1
fi

echo "Selecting a non-existing group > 3 results in it being chosen!" >>junk.sgtest2out
onetest "-group 4" $testsrc/debugfission/archive.o \
    junk.sgtest2out
echo "There is no group 2 in archive.o, init gets NO ENTRY" \
   >>junk.sgtest2out 
onetest "-group 2" $testsrc/debugfission/archive.o junk.sgtest2out

onetest "-group 0" $testsrc/comdatex/example.o junk.sgtest2out
onetest "-group 1" $testsrc/comdatex/example.o junk.sgtest2out
echo "There is no group 2 in example.o so it is NO ENTRY" \
  >>junk.sgtest2out
onetest "-group 2" $testsrc/comdatex/example.o >>junk.sgtest2out
onetest "-group 3" $testsrc/comdatex/example.o >>junk.sgtest2out
onetest "-group 4" $testsrc/comdatex/example.o >>junk.sgtest2out
echo "There is no group 5 in example.o but it is chosen." \
  >>junk.sgtest2out
onetest "-group 5" $testsrc/comdatex/example.o junk.sgtest2out
diff $ts/sgtest2.baseline junk.sgtest2out
if [ $? -ne 0 ]
then
    echo "FAIL diff $ts/sgtest2.baseline $tf/junk.sgtest2out"
    echo "To update: mv $tf/junk.sgtest2out $ts/sgtest2.baseline"
    echo "rerun: $ts/runtest.sh"
    finalexit=1
fi
if [ $finalexit -ne 0 ]
then
   exit $finalexit
fi
echo "PASS showsectiongroupsdir/runtest.sh"
exit 0
