#!/bin/sh
# execute as  runtest.sh
# unpack the executable  (lots of zeroes, so it compresses well).
# zcat (gzcat on MacOS) is the same as gunzip -c  
olddd=../dwarfdump.O
newdd=../dwarfdump
# The problem here is that it is dwarf2 and elf64 yet 32bit address
# so things go wrong. We need to specify address size is 4.
# So we need a dwarfdump.conf flag here.
ourzcat=zcat
which gzcat 1>/dev/null
if [ $? -eq 0 ]
then
  # On MacOS gzcat does what zcat does on Linux.
  ourzcat=gzcat
fi
. ../BASEFILES.sh
ts=$testsrc/enciso4
tf=$bldtest/enciso4

j=junk.frame_problem.elf 
$ourzcat $ts/frame_problem.elf.gz > $j
if [ $# -ne 0 ]
then
    echo "enciso4/runtest.sh Wrong number of args, $#. Expect 0."
    echo "rerun: $ts/runtest.sh"
    exit 1
fi

commonopts="-x name=../dwarfdump.conf -x abi=ppc32bitaddress"
#   -f runs in about a minute.
$newdd -f  $commonopts $j  >junk.f.out
if [ $? -ne 0 ] 
then
    echo "fail error -f enciso4/runtest.sh junk.frame_problem.elf"
    echo "rerun: $ts/runtest.sh"
    exit 1
fi
# The  -F  version runs over 20 minutes, so we skip that.
# eh_frame is pretty big, 0x1ab0e0 bytes.
#$newdd -F  $commonopts $j >junk.F.out
#if [ $? -ne 0 ] 
#then
#    echo fail error -F enciso4/junk.frame_problem.elf
#    exit 1
#fi
echo "PASS enciso4/runtest.sh: dumped enciso4/junk.frame_problem.elf"
exit 0
