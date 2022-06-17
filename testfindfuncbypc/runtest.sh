
. ../BASEFILES.sh
ts=$testsrc/findfuncbypc
tf=$bldtest/findfuncbypc

sh $ts/runall.sh >& junkbypcresults

cmp $ts/junkbypc.base junkbypcresults
if [ $? -eq 0 ]
then
  echo "PASS findfuncbypc"
  exit 0
fi
echo "diff findfuncbypc"
cmp $ts/junkbypc.base junkbypcresults
echo "FAIL findfuncbypc"
echo "To update, mv $tf/junkbypcresults $ts/junkbypc.base"
exit 1

