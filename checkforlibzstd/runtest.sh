#!/bin/bash
if [ $# -ne 1 ]
then
  echo "FAIL cannot find testsrc in checkforlibz/runtest.sh"
  exit 1
fi
tsrc=$1
# This does a trivial compile/link to see if zlib.h and -lz
# exist for some test directories.
cc $tsrc/checkforlibzstd/tzlstd.c -lzstd 
if [ $? -eq 0 ]
then
  echo "FOUND: Found libzstd"
  exit 0
fi
echo "NOT FOUND: libzstd"
exit 1
