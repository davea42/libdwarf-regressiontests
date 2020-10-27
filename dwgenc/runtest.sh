#!/bin/sh

. ../BASEFILES
ts=$testsrc/dwgenc
tf=$bldtest/dwgenc

../dwarfgen -c 0 --force-empty-dnames -v5 -t obj  -o testoutput.o $ts/testinput.o >junkdgstdout 2> junkdgstderr 
if [ $? -ne 0 ] 
then
    echo "fail dwgenc  dwarfgen on $ts/testinput.o"
    exit 1
fi

#../dwarfdump --print-debug-names testoutput.o 1>junkstdout 2>junkstderr
../dwarfdump  -i -M --print-debug-names testoutput.o 1>junkstdout 2>junkstderr
if [ $? -ne 0 ] 
then
    echo "fail dwgenc  dwarfdump on testinput.o"
    exit 1
fi

diff junkstdout $ts/base.stdout
if [ $?  -ne 0 ]
then
   echo "fail dwgenc dwarfdump."
   echo "update baseline with 'mv $tf/junkstdout $ts/base.stdout'"
   exit 1
fi
diff junkstderr  $ts/base.stderr
if [ $?  -ne 0 ]
then
   echo "fail dwgenc dwarfdump."
   echo "update baseline with 'mv junkstderr  $tsbase.stderr' "
   exit 1
fi
rm -f junkstderr
rm -f junkstdout
rm -f junkdgstdout
rm -f junkdgstderr
echo "PASS dwgenc/runtest.sh"
exit 0
