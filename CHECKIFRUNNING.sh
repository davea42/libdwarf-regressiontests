#!/usr/bin/env sh
echo 'precheck for already running'
. ./SHALIAS.sh

. ./BASEFILES.sh
dwbb=$bldtest/dwbb

if [ -f $dwbb ]
then
  echo "Only one DWARFTEST.sh can run at a time  in a particular"
  echo "directory."
  echo "Something is wrong, DWARFTEST.sh already running, "
  ls   $dwbb
  echo "exists, so exit non-zero and stop"
  exit 1
fi
exit 0
