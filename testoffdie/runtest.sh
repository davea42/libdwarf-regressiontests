#!/bin/sh
# execed sh runtest.sh $top_srcdir $top_builddir
src=$1
bld=$2
h="-I$src/libdwarf"
l="-L$src/libdwarf"
libs="$bld/libdwarf/.libs/libdwarf.a -lelf"
if [ x$NLIZE = 'xy' ]
then
  nli="-fsanitize=address -fsanitize=leak -fsanitize=undefined"
else
  nli=
fi

opts="-I$bld -I$bld/libdwarf"
if [ -f /usr/include/zlib.h ]
then
  cc $h $opts  testoffdie.c $nli $l -o junkoffdie $libs -lz
else
  cc $h $opts testoffdie.c $nli $l -o junkoffdie $libs
fi
if [ $? -ne 0 ]
then
   echo FAIL compile testoffdie/testoffdie.c 
fi

./junkoffdie >junkout
r=$?
if [ $r -ne 0 ]
then
   echo FAIL run  testoffdie/junkoffdie 
   exit 1
fi
diff baseout junkout
if [ $? -ne 0 ]
then
  echo "FAIL mismatch expected from testoffdie/runtest.sh $1 $2"
  echo " To update expected result: mv junkout baseout"
  exit 1
fi
echo PASS testoffdie/runtest.sh
exit 0

