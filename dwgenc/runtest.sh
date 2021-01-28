#!/bin/sh

. ../BASEFILES
ts=$testsrc/dwgenc
tf=$bldtest/dwgenc

# pointer size is 8 in input, and we let it default to 4 then reading a DW_OP_addr
# will lead to an error.  So far we are not emitting DW_OP stuff (except
# for one special case for testing) OP by OP, but just as a byte stream.
# Hence adjusting address-size in dwarfgen is problematic.
# January 28, 2021
../dwarfgen -p 8 -c 0 --force-empty-dnames -v5 -t obj  -o testoutput.o $ts/testinput.o >junkdgstdout 2> junkdgstderr 
if [ $? -ne 0 ] 
then
    echo "fail dwgenc  dwarfgen on $ts/testinput.o"
    echo "rerun: $ts/runtest.sh"
    exit 1
fi

#../dwarfdump --print-debug-names testoutput.o 1>junkstdout 2>junkstderr
../dwarfdump  -i -M --print-debug-names testoutput.o 1>junkstdout 2>junkstderr
if [ $? -ne 0 ] 
then
    echo "fail dwgenc  dwarfdump on testinput.o"
    echo "rerun: $ts/runtest.sh"
    exit 1
fi

diff junkstdout $ts/base.stdout
if [ $?  -ne 0 ]
then
   echo "fail dwgenc dwarfdump."
   echo "update baseline with 'mv $tf/junkstdout $ts/base.stdout'"
   echo "rerun: $ts/runtest.sh"
   exit 1
fi
diff junkstderr  $ts/base.stderr
if [ $?  -ne 0 ]
then
   echo "fail dwgenc dwarfdump."
   echo "update baseline with 'mv junkstderr  $tsbase.stderr' "
   echo "rerun: $ts/runtest.sh"
   exit 1
fi
rm -f junkstderr
rm -f junkstdout
rm -f junkdgstdout
rm -f junkdgstderr
echo "PASS dwgenc/runtest.sh"
exit 0
