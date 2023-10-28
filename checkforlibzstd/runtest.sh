#!/bin/bash
. ../BASEFILES.sh
# This does a trivial compile/link to see if libzstd.h and -lzstd
# exist for some test directories.

cc  $testsrc/checkforlibzstd/tzlstd.c   -lzstd >junkstdout 2>junkstderr
if [ $? -eq 0 ]
then
  echo "FOUND: Found libzstd in standard locations"
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
  echo "TRY compile "
  cc $H $testsrc/checkforlibzstd/tzlstd.c $L -lzstd >junkstdout 2>junkstderr
  if [ $? -eq 0 ]
  then
    echo "FOUND: Found libzstd in /opt/local"
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
  echo "TRY compile "
  cc $H $testsrc/checkforlibzstd/tzlstd.c $L -lzstd >junkstdout 2>junkstderr
  if [ $? -eq 0 ]
  then
    echo "FOUND: Found libzstd in /usr/local"
    exit 1
  fi
fi
echo "NOT FOUND: libzstd"
exit 3
