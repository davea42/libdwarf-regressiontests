#!/bin/sh
. ../BASEFILES.sh
. $testsrc/BASEFUNCS.sh
. $testsrc/RUNTIMEFILES.sh
ts=$testsrc/filelist
here=`pwd`

fz=./localfuzz_init_path
fzb=./localfuzz_init_binary

rm -f result
touch result
while read fname
do
  #echo "=====localfuzz_init_path $fname" 2>> result
  $fz $testsrc/$fname  2>>result
done < $ts/fileliste

while read fname
do
  echo "=====localfuzz_init_binary $fname" 2>> result
  $fzb $testsrc/$fname 2>> result
done < $ts/fileliste

diff ./result $ts/baseresult
if [ $? -ne 0 ]
then
   echo "FAIL in stderr for filelist tests."
   echo "To update, mv $here/result $ts/baseresult"
   exit 1
fi
exit 0
