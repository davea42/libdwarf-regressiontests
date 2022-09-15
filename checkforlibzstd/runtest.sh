#!/bin/bash
. ../BASEFILES.sh
# This does a trivial compile/link to see if zlib.h and -lz
# exist for some test directories.
cc $testsrc/checkforlibz/tzlstd.c -lzstd >junkstdout 2>junkstderr
if [ $? -eq 0 ]
then
  exit 0
fi
exit 1
