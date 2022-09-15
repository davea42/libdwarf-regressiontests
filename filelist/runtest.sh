#!/bin/sh
. ../BASEFILES.sh
. $testsrc/BASEFUNCS.sh
. $testsrc/RUNTIMEFILES.sh
ts=$testsrc/filelist
here=`pwd`

fz=localfuzz_init_path
fzb=localfuzz_init_binary

chkres () {
  if [ $1 -eq 0 ]
  then
    goodcount=`expr $goodcount + 1`
  else
    echo "FAIL $2"
    failcount=`expr $failcount + 1`
  fi
}


rm -f result
touch result
while read fname
do
  #echo "=====localfuzz_init_path $fname" 2>> result
  $ts/$fz $testsrc/$fname  2>>result
  chkres $? "localfuzz_init_path on $testsrc/$fname"
done < $ts/fileliste

while read fname
do
  echo "=====localfuzz_init_binary $fname" 2>> result
  $ts/$fzb $testsrc/$fname 2>> result
  chkres $? "localfuzz_init_binary on $testsrc/$fname"
done < $ts/fileliste

diff ./result $ts/baseresult
if [ $? -ne 0 ]
then
   echo "FAIL in stderr for filelist tests."
   echo "To update, mv $here/result $ts/baseresult"
   exit 1
fi
exit 0
