#!/bin/bash
if [ $# -ne 1 ]
then
  echo "FAIL cannot find testsrc in checkforlibz/runtest.sh"
  exit 1
fi
. ../BASEFILES.sh
tsrc=$1
# This does a trivial compile/link to see if zlib.h and -lz
# exist for some test directories.
cc $tsrc/checkforlibz/tzl.c -lz >junkstdout 2>junkstderr
if [ $? -eq 0 ]
then
  echo "FOUND: Found libz"
  exit 0
fi
echo "NOT FOUND: libz"
exit 1
