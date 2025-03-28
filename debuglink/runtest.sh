#!/bin/sh
dd=../dwarfdump

if [ x$NLIZE = 'xy' ]
then
  nli=`checkargs -fsanitize=address -fsanitize=leak \
    -fsanitize=undefined`
else
  nli=
fi
if [ x$endian = "xB" ]
then
	beopt=-DBIGEND
else
	beopt=
fi

. ../BASEFILES.sh

ts=$testsrc/debuglink
tf=$bldtest/debuglink
. $testsrc/BASEFUNCS.sh


setpythondirs
if [ $? -ne 0 ]
then
  echo "FAIL debuglink cannot identify python"
  exit 1
fi
# sets mypycon (python2 or python3)  
# and mypydir (often /usr/bin/python3)

# Running this out-of-regressiontests and on
# freebsd and S390  leads to name clashes.
# So get rid of the part of path other than
# regressiontests/debuglink/crc32.debug
$dd --print-gnu-debuglink $ts/crc32 >junklink
$mypycom $testsrc/$mypydir/filterpathto.py regressiontests/debuglink/crc32.debug <junklink >junklinky
diff $diffopt $ts/baselink junklinky 
if [ $? -ne 0 ]
then
    echo "fail debuglink base link wrong"
    echo "To update: mv $tf/junklinky $ts/baselink"
    echo "rerun: $ts/runtest.sh"
    exit 1
fi

$dd --print-gnu-debuglink $ts/crc32.debug >junklinkc
sed  'sx/usr/home/x/home/x' <junklinkc >junklinkcx
sed  'sx/home/ubuntu/x/home/davea/x' <junklinkcx >junklinkcy
diff $diffopt $ts/baselinkc junklinkcy
if [ $? -ne 0 ]
then
    echo "fail debuglink base link wrong"
    echo "To update: mv $tf/junklinkcy $ts/baselinkc"
    echo "rerun: $ts/runtest.sh"
    exit 1
fi

cc $nli $beopt $ts/crc32.c -o junkcrc32 > junkcompilestdout 2> junkcompileoutstderr
if [ $? -ne 0 ]
then
    echo fail compile $tf/debuglink/junkcrc32
    echo "rerun: $ts/runtest.sh"
    exit 1
fi
./junkcrc32 $ts/crc32.debug > junkcrcout
diff $diffopt $ts/basecrcout junkcrcout 
if [ $? -ne 0 ]
then
    echo "fail debuglink etc on crc32.debug wrong"
    echo "To update: mv $tf/junkcrcout $ts/basecrcout"
    echo "rerun: $ts/runtest.sh"
    exit 1
fi
./junkcrc32 $ts/crc32 > junkcrcoutb
diff $diffopt $ts/basecrcoutb junkcrcoutb
if [ $? -ne 0 ]
then
    echo "fail debuglink etc crc32 out wrong"
    echo "To update: mv $tf/junkcrcoutb $ts/basecrcoutb"
    echo "rerun: $ts/runtest.sh"
    exit 1
fi
echo "PASS debuglink/runtest.sh" 
exit 0
