#!/bin/sh
dd=../dwarfdump

if [ x$NLIZE = 'xy' ]
then
  nli="-fsanitize=address -fsanitize=leak -fsanitize=undefined"
else
  nli=
fi


# The suggested text emitted is /home on ubuntu
# and /usr/home on freebsd. Lets change /usr/home
# to plain home
$dd --print-gnu-debuglink crc32 >junklink
sed  'sx/usr/home/x/home/x' <junklink >junklinkx
diff baselink junklinkx 
if [ $? -ne 0 ]
then
    echo "FAIL debuglink base link wrong"
    echo "To update: mv junklinkx baselink"
    exit 1
fi

$dd --print-gnu-debuglink crc32.debug >junklinkc
sed  'sx/usr/home/x/home/x' <junklinkc >junklinkcx
diff baselinkc junklinkcx
if [ $? -ne 0 ]
then
    echo "FAIL debuglink base link wrong"
    echo "To update: mv junklinkcx baselinkc"
    exit 1
fi

cc $nli crc32.c -o junkcrc32 > junkcompilestdout 2> junkcompileoutstderr
if [ $? -ne 0 ]
then
    echo FAIL compile debuglink/junkcrc32
    exit 1
fi
./junkcrc32 crc32.debug > junkcrcout
diff basecrcout junkcrcout 
if [ $? -ne 0 ]
then
    echo "FAIL debuglink etc on crc32.debug wrong"
    echo "To update: mv junkcrcout basecrcout"
    exit 1
fi
./junkcrc32 crc32 > junkcrcoutb
diff basecrcoutb junkcrcoutb
if [ $? -ne 0 ]
then
    echo "FAIL debuglink etc crc32 out wrong"
    echo "To update: mv junkcrcoutb basecrcoutb"
    exit 1
fi
echo "PASS debuglink/runtest.sh" 
exit 0
