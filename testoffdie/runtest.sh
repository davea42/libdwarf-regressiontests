#!/bin/sh
# execed sh runtest.sh $top_srcdir $top_builddir
# we ignore $3 arg.  On non-linux it's not so
# simple to test for zlib.h, the zlib.h test below does
# not work on such systems.
. ../BASEFILES.sh
ts=$testsrc/testoffdie
tf=$bldtest/testoffdie
. $testsrc/BASEFUNCS.sh

src=$testsrc/testoffdie
bld=$libbld
withlibz="$1"
withlibzstd=$2
# libzstdhdrdir and libzstdlibdir are in BASEFILES.sh.
echo "entering testoffdie/runtest.sh  $withlibz"
h="-I$testsrc/libdwarf -I$codedir/src/lib/libdwarf"
l="-L$src/libdwarf"
libs="../$filelibname"
if [ x$withlibz = "xwithlibz" ]
then
  libs="$libs -lz"
fi
if [ x$withlibzstd = "xyezstd" ]
then
  if  [ ! "x$libzstdlibdir" = "x" ]
  then
      libs="$libs $libzstdlibdir"
  fi
  libs="$libs -lzstd"
fi
if [ x$withlibz = "x" ]
then
  echo "Improper arg withlibz!"
  echo fail testoffdie withlibz not set
  echo "rerun: $ts/runtest.sh $1 $2"
  exit 1
fi
if [ x$NLIZE = 'xy' ]
then
  nli=`checkargs -fsanitize=address -fsanitize=leak \
    -fsanitize=undefined`
else
  nli=
fi

opts="-I$bld -I$bld/src/lib/libdwarf"
echo cc $h $opts $libzstdhdrdir  $ts/testoffdie.c  \
  $nli $l -o junkoffdie $libs
cc $h $opts  $libzstdhdrdir  $ts/testoffdie.c $nli $l -o junkoffdie $libs
if [ $? -ne 0 ]
then
   echo fail compile testoffdie/testoffdie.c 
  echo "rerun: $ts/runtest.sh $1 $2"
   exit 1
fi

./junkoffdie $testsrc/irixn32/dwarfdump > junkout
r=$?
if [ $r -ne 0 ]
then
   echo fail run  testoffdie/junkoffdie 
  echo "rerun: $ts/runtest.sh $1 $2"
   exit 1
fi
diff $ts/baseout junkout
if [ $? -ne 0 ]
then
  echo "fail mismatch expected from testoffdie/runtest.sh $1 $2"
  echo " To update expected result: mv $tf/junkout $ts/baseout"
  echo "rerun: $ts/runtest.sh $1 $2"
  exit 1
fi
echo "PASS testoffdie/runtest.sh"
exit 0

