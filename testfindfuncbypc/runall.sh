#!/bin/sh

. ../BASEFILES.sh
ts=$testsrc/findfuncbypc
tf=$bldtest/findfuncbypc

ff=../findfuncbypc
testff=$ts/findfuncbypc.exe1
echo "Missing path"
echo "$ff --printdetails --pc=1"
$ff --printdetails --pc=1
echo "pc not found, no output"
echo "$ff --printdetails --pc=1 $testff"
$ff --printdetails --pc=1 $testff
echo "pc not found, no output"
echo "$ff --printdetails $testff
$ff --printdetails $testff
echo "pc not found, no output"
echo "$ff --printdetails --pc=10000 $testff"
$ff --printdetails --pc=10000 $testff
echo "Following tests using ranges properly"
echo "$ff --printdetails --pc=0x36a4 $testff"
$ff --printdetails --pc=0x36a4 $testff

