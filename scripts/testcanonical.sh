#!/bin/sh

f="C:/msys64/"
fz=${f}home/admin
flin=/home/davea/dwarf/
./canonicalpath.py $flin xxxx name
./canonicalpath.py $flin /home/davea  name
./canonicalpath.py $flin /home/admin name

echo ""
./canonicalpath.py $fz xxxx name
./canonicalpath.py $fz /home/davea/dwarf/regressiontests  name
./canonicalpath.py $fz /home/admin name

echo " a /home/davea" >junkcontent
echo " b /home/admin" >>junkcontent
echo " c $fz/dwarf/code" >>junkcontent
echo " d $flin/regressiontests" >>junkcontent
echo " e C:/msys64${flin}/code" >>junkcontent

echo " "
./canonicalpath.py junkcontent $fz content
echo " "
./canonicalpath.py junkcontent $flin content

