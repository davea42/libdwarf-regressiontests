#!/bin/sh
trap "rm -f /tmp/dwxa.$$ ; rm -f /tmp/dwxb.$$ ; exit" 1 2 15
echo 'precheck for already running'
. ./SHALIAS.sh
# Do this early before doing the build since
# the build will break any DWARFTEST.sh
# that is running.
if [ -f "/tmp/dwba*" ]
then
  echo "Only one DWARFTEST.sh can run at a time on a machine"
  echo "Something is wrong, DWARFTEST.sh already running, "
  ls   /tmp/dwba*
  echo "exists, so exit non-zero and stop"
  exit 1
fi
if [ -f "/tmp/dwbb*" ]
then
  echo "Only one DWARFTEST.sh can run at a time on a machine"
  echo "Something is wrong, DWARFTEST.sh already running, "
  ls   /tmp/dwbb*
  echo "exists, so exit non-zero and stop"
  exit 1
fi
rm -f /tmp/dwbxa.$$
rm -f /tmp/dwbxb.$$
ps -eaf |grep DWARF >/tmp/dwbxa.$$
grep DWARFTEST.sh /tmp/dwbxa.$$ > /tmp/dwbxb.$$
ct=`wc -l </tmp/dwbxb.$$`
echo "Number of DWARFTEST.sh running: $ct"
if [ $ct -gt 0 ]
then
  echo "Only one DWARFTEST.sh can run at a time on a machine"
  echo "Something is wrong, DWARFTEST.sh already running: $ct"
  echo "exit non-zero and stop"
  ls /tmp/dwbx*
  rm -f /tmp/dwbxa.$$
  rm -f /tmp/dwbxb.$$
  exit 1
fi
rm -f /tmp/dwbxa.$$
rm -f /tmp/dwbxb.$$
exit 0
