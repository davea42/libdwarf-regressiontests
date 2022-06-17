
. ../BASEFILES.sh
ts=$testsrc/testfindfuncbypc
tf=$bldtest/testfindfuncbypc

sh $ts/runall.sh > junkbypcresults 2>&1
base=$ts/findfuncbypc.base

cmp $base junkbypcresults
if [ $? -eq 0 ]
then
  echo "PASS testfindfuncbypc"
  exit 0
fi
echo "diff $base $tfjunkbypcresults"
diff $base junkbypcresults
echo "FAIL testfindfuncbypc"
echo "To update, mv $tf/junkbypcresults $base"
exit 1

