#!/bin/sh

f="C:/msys64/davea/"
fz=${f}home/admin
flin="/home/davea/dwarf/code"

echo " a /home/davea/dwarf/regressiontests/../code/test/dummyexecutable" >junkcontent
echo " b /home/davea/dwarf/code/test/dummyexecutable" >>junkcontent

echo " "
./dirtostd.py junkcontent  $flin
echo " "
./dirtostd.py  sampledirtostd.base $flin

