#!/bin/sh
# execed sh runtest.sh $top_srcdir $top_builddir
# we ignore $3 arg.  On non-linux it's not so
# simple to test for zlib.h, the zlib.h test below does
# not work on such systems.
src=$1
bld=$2
withlibelf=$3
withlibz=$4
echo "entering testoffdie/runtest.sh $src $bld $withlibelf $withlibz"
h="-I$src/libdwarf"
l="-L$src/libdwarf"
libs="$bld/libdwarf/.libs/libdwarf.a"
if [ x$withlibelf = "xwithlibelf" ]
then
  libs="$libs -lelf"
fi
if [ x$withlibz = "xwithlibz" ]
then
  libs="$libs -lz"
fi
if [ x$withlibz = "x" ]
then
  echo "Improper arg withlibz!"
  echo fail testoffdie withlibz not set
  exit 1
fi
if [ x$withlibelf = "x" ]
then
  echo "Improper arg withlibelf!"
  echo fail testoffdie withlibelf not set
  exit 1
fi

if [ x$NLIZE = 'xy' ]
then
  nli="-fsanitize=address -fsanitize=leak -fsanitize=undefined"
else
  nli=
fi

opts="-I$bld -I$bld/libdwarf"
cc $h $opts  testoffdie.c $nli $l -o junkoffdie $libs
if [ $? -ne 0 ]
then
   echo fail compile testoffdie/testoffdie.c 
   exit 1
fi

./junkoffdie >junkout
r=$?
if [ $r -ne 0 ]
then
   echo fail run  testoffdie/junkoffdie 
   exit 1
fi
diff baseout junkout
if [ $? -ne 0 ]
then
  echo "fail mismatch expected from testoffdie/runtest.sh $1 $2"
  echo " To update expected result: mv junkout baseout"
  exit 1
fi
echo "PASS testoffdie/runtest.sh"
exit 0

