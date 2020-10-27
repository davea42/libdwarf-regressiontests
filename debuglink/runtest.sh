#!/bin/sh
dd=../dwarfdump
if [ x$NLIZE = 'xy' ]
then
  nli="-fsanitize=address -fsanitize=leak -fsanitize=undefined"
else
  nli=
fi
if [ x$endian = "xB" ]
then
	beopt=-DBIGEND
else
	beopt=
fi

. ../BASEFILES

ts=$testsrc/debuglink
tf=$bldtest/debuglink
. $testsrc/BASEFUNCS

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
diff $ts/baselink junklinky 
if [ $? -ne 0 ]
then
    echo "fail debuglink base link wrong"
    echo "To update: mv $tf/junklinky $ts/baselink"
    exit 1
fi

$dd --print-gnu-debuglink $ts/crc32.debug >junklinkc
sed  'sx/usr/home/x/home/x' <junklinkc >junklinkcx
sed  'sx/home/ubuntu/x/home/davea/x' <junklinkcx >junklinkcy
diff $ts/baselinkc junklinkcy
if [ $? -ne 0 ]
then
    echo "fail debuglink base link wrong"
    echo "To update: mv $tf/junklinkcy $ts/baselinkc"
    exit 1
fi

cc $nli $beopt $ts/crc32.c -o junkcrc32 > junkcompilestdout 2> junkcompileoutstderr
if [ $? -ne 0 ]
then
    echo fail compile $tf/debuglink/junkcrc32
    exit 1
fi
./junkcrc32 $ts/crc32.debug > junkcrcout
diff $ts/basecrcout junkcrcout 
if [ $? -ne 0 ]
then
    echo "fail debuglink etc on crc32.debug wrong"
    echo "To update: mv $tf/junkcrcout $ts/basecrcout"
    exit 1
fi
./junkcrc32 $ts/crc32 > junkcrcoutb
diff $ts/basecrcoutb junkcrcoutb
if [ $? -ne 0 ]
then
    echo "fail debuglink etc crc32 out wrong"
    echo "To update: mv $tf/junkcrcoutb $ts/basecrcoutb"
    exit 1
fi
echo "PASS debuglink/runtest.sh" 
exit 0
