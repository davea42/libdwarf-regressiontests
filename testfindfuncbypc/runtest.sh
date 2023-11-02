
. ../BASEFILES.sh
ts=$testsrc/testfindfuncbypc
tf=$bldtest/testfindfuncbypc

sh $ts/runall.sh > junkbypcresults 2>&1
base=$ts/findfuncbypc.base
# cmp cannot work on Windows
x="diff $diffopt $base $tf/junkbypcresults"
echo $x
$x
if [ $? -ne 0 ]
then
  echo "base " `wc $base`
  echo "results " `wc $tf/junkbypcresults`
  echo "FAIL testfindfuncbypc diff"
  echo "To update, mv $tf/junkbypcresults $base"
  exit 1
fi
exit 0

