#!/bin/sh
../dwarfgen -c 0 --force-empty-dnames -v5 -t obj  -o testoutput.o testinput.o >junkdgstdout 2> junkdgstderr 
if [ $? -ne 0 ] 
then
    echo "fail dwgenc  dwarfgen on testinput.o"
    exit 1
fi

#../dwarfdump --print-debug-names testoutput.o 1>junkstdout 2>junkstderr
../dwarfdump  -i -M --print-debug-names testoutput.o 1>junkstdout 2>junkstderr
if [ $? -ne 0 ] 
then
    echo "fail dwgenc  dwarfdump on testinput.o"
    exit 1
fi

diff junkstdout base.stdout
if [ $?  -ne 0 ]
then
   echo "fail dwgenc dwarfdump."
   echo "update baseline with 'mv junkstdout base.stdout'"
   exit 1
fi
diff junkstderr  base.stderr
if [ $?  -ne 0 ]
then
   echo "fail dwgenc dwarfdump."
   echo "update baseline with 'mv junkstderr  base.stderr' "
   exit 1
fi
rm -f junkstderr
rm -f junkstdout
rm -f junkdgstdout
rm -f junkdgstderr
echo "PASS dwgenc/runtest.sh"
exit 0
