#!/bin/sh
# We expect a core file, we do not worry about that.
# Hopeless bogus executable.

t=heap_buffer_overflow.exe
a=$1

rm -f core
$a -i $t > newout
rm -f core

diff baseout newout
if [ $? -ne 0 ]
then
    echo FAIL williamson/heap_buffer_overflow.exe
    exit 1
fi
exit 0


