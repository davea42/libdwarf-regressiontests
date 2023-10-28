#!/bin/bash
. ../BASEFILES.sh
# This does a trivial compile/link to see if zlib.h and -lz
# exist for some test directories.
cc  $testsrc/checkforlibz/tzl.c   -lz >junkstdout 2>junkstderr
if [ $? -eq 0 ]
then
  echo "FOUND: Found libz in standard locations"
  exit 0
fi

trycompile=n
H=
L=
if test -d /opt/local/include ; then
  H="-I/opt/local/include"
  if test -d /opt/local/include ; then
    L="-L/opt/local/lib"
    trycompile="y"
  fi
fi

if test $trycompile="y" ; then
  cc $H $testsrc/checkforlibz/tzl.c $L -lz >junkstdout 2>junkstderr
  if [ $? -eq 0 ]
  then
    echo "FOUND: Found libz in /opt/local"
    exit 2
  fi
fi
trycompile=n
H=
L=
if test -d /usr/local/include ; then
  H="-I/usr/local/include"
  if test -d /usr/local/include ; then
    L="-L/usr/local/lib"
    trycompile=y
  fi
fi

if test $trycompile=y ; then
  cc $H $testsrc/checkforlibz/tzl.c $L -lz >junkstdout 2>junkstderr
  if [ $? -eq 0 ]
  then
    echo "FOUND: Found libz in /opt/local"
    exit 1
  fi
fi
echo "NOT FOUND: libz"
exit 3
