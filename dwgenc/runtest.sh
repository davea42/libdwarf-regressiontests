#!/bin/sh

. ../BASEFILES.sh
ts=$testsrc/dwgenc
tf=$bldtest/dwgenc

# pointer size is 8 in input, and we let it default to 4 then reading a DW_OP_addr
# will lead to an error.  So far we are not emitting DW_OP stuff (except
# for one special case for testing) OP by OP, but just as a byte stream.
# Hence adjusting address-size in dwarfgen is problematic.
# Skip forcing .debug_names March 18 2022, it is wrong and not needed
# since llvm correctly generates such sections.
# January 28, 2021
../dwarfgen -p 8 -c 0 --default-form-strp -v5 -t obj  -o testoutput.o $ts/testinput.o >junkdgstdout 2> junkdgstderr 
if [ $? -ne 0 ] 
then
    echo "fail dwgenc  dwarfgen on $ts/testinput.o"
    echo "rerun: $ts/runtest.sh"
    exit 1
fi

../dwarfdump  -i -M --print-debug-names testoutput.o 1>junkdebugnames 2>junkstderr
if [ $? -ne 0 ] 
then
    echo "fail dwgenc  dwarfdump on testinput.o"
    echo "rerun: $ts/runtest.sh"
    exit 1
fi

diff $ts/base.debugnames junkdebugnames
if [ $?  -ne 0 ]
then
   echo "fail dwgenc dwarfdump."
   echo "update baseline with 'mv $tf/junkdebugnames $ts/base.debugnames'"
   echo "rerun: $ts/runtest.sh"
   exit 1
fi
diff $ts/base.stderr junkstderr
if [ $?  -ne 0 ]
then
   echo "fail dwgenc dwarfdump."
   echo "update baseline with 'mv junkstderr  $tsbase.stderr' "
   echo "rerun: $ts/runtest.sh"
   exit 1
fi
rm -f junkstderr
rm -f junkdebugnames
rm -f junkdgstdout
rm -f junkdgstderr
echo "PASS dwgenc/runtest.sh"
exit 0
