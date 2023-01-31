#!/bin/bash
. ../BASEFILES.sh
# This does a trivial compile/link to see if zlib.h and -lz
# exist for some test directories.
cc $testsrc/checkforlibzstd/tzlstd.c -L/usr/lib -lzstd
if [ $? -eq 0 ]
then
  echo "FOUND: Found libzstd /usr/lib"
  exit 0
fi
echo "Looking in /usr/local/lib: libzstd"
cc $testsrc/checkforlibzstd/tzlstd.c -I/usr/local/include -L/usr/local/lib -lzstd
if [ $? -eq 0 ]
then
  echo "FOUND: Found libzstd in /usr/local/lib libzstd"
  # Horrrible use of exit code. Means FOUND here.
  exit 2
fi
echo "NOT FOUND: libzstd"
exit 1
