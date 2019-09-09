#!/bin/sh
dd=../dwarfdump

$dd --print-gnu-debuglink crc32 >junklink
diff baselink junklink 
if [ $? -ne 0 ]
then
    echo "FAIL debuglink base link wrong"
    echo "To update: mv junklink baselink"
    exit 1
fi

cc crc32.c -o junkcrc32 > junkcompilestdout 2> junkcompileoutstderr
if [ $? -ne 0 ]
then
    echo FAIL compile debuglink/junkcrc32
    exit 1
fi
./junkcrc32 crc32.debug > junkcrcout
diff basecrcout junkcrcout 
if [ $? -ne 0 ]
then
    echo "FAIL debuglink crc out wrong"
    echo "To update: mv junkcrcout basecrcout"
    exit 1
fi
echo "PASS debuglink/runtest.sh" 
exit 0
