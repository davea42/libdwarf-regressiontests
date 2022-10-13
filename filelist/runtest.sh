#!/bin/sh
. ../BASEFILES.sh
. $testsrc/BASEFUNCS.sh
. $testsrc/RUNTIMEFILES.sh
ts=$testsrc/filelist
here=`pwd`

fz=./localfuzz_init_path
fzb=./localfuzz_init_binary

chkres () {
  if [ $1 -ne 0 ]
  then
    echo "FAIL $2"
    exit 1
  fi
}


rm -f result
touch result
while read fname
do
  echo "=====localfuzz_init_path $fname" 
  $fz $testsrc/$fname  2>>result
  r=$?
  chkres $r "Running $ts/$fz $testsrc/$fname "
done < $ts/fileliste

while read fname
do
  echo "=====localfuzz_init_binary $fname" 
  $fzb $testsrc/$fname 2>> result
  chkres $? "Running $ts/$fzb $testsrc/$fname "
done < $ts/fileliste

diff ./result $ts/baseresult
if [ $? -ne 0 ]
then
   echo "FAIL in stderr for filelist tests."
   echo "To update, mv $here/result $ts/baseresult"
   exit 1
fi
echo "PASS filelist test"
exit 0
