#!/bin/sh
libdw=$1
bld=$2
dwlib=$3
withlibelf=$4
withlibz=$5
if [ x$withlibz = "x" ]
then
   echo "FAIL frame1 runtest.sh does not have all 5 args: withlibz missing"
   exit 1
fi
if [ x$withlibelf = "x" ]
then
    echo "FAIL frame1 runtest.sh, does not have all 5 args: withlibelf missing"
    exit 1
fi
if [ x$NLIZE = 'xy' ]
then
  opt="-fsanitize=address -fsanitize=leak -fsanitize=undefined"
else
  opt=
fi
libs=
if [ $withlibelf = "withlibelf" ]
then
  libs="-lelf"
fi
if [ $withlibz = "withlibz" ]
then
  libs="$libs -lz"
fi

cp $libdw/dwarfexample/frame1.c framexlocal.c
echo "cc -g $opt -I$libdw/libdwarf -I$bld -I$bld/libdwarf framexlocal.c $dwlib $libs -o frame1"
cc -g $opt -I$libdw/libdwarf -I$bld -I$bld/libdwarf framexlocal.c $dwlib $libs -o frame1

if [ $? -ne 0 ]
then
    echo FAIL building framexlocal.c
    exit 1
fi
./frame1 frame1.orig >frame1.out
if [ $? -ne 0 ]
then
    echo FAIL running framexlocal.c
    exit 1
fi
diff frame1.base frame1.out >diffs
if [ $? -ne 0 ]
then
    echo "FAIL frame1 test.  got diffs in output."
    cat diffs
    echo "To update do: cp frame1.out frame1.base"
    exit 1
fi

./frame1 --just-print-selected-regs frame1.exe.2018-05-11 >selregs2018.out
if [ $? -ne 0 ]
then
    echo FAIL running framexlocal.c selected regs
    exit 1
fi
diff selregs2018.base  selregs2018.out >diffs
if [ $? -ne 0 ]
then
    echo "FAIL selregs2018 test.  got diffs in output."
    echo "To update do: cp selregs2018.out selregs2018.base"
    exit 1
fi


./frame1 frame1.exe.2018-05-11 >frame2018.out
if [ $? -ne 0 ]
then
    echo FAIL running framexlocal.c frame2018
    exit 1
fi
diff frame2018.base  frame2018.out >diffs
if [ $? -ne 0 ]
then
    echo "FAIL frame2018 test.  got diffs in output."
    echo "To update do: cp frame2018.out frame2018.base"
    exit 1
fi
echo "PASS frame1/runtest.sh"
rm -f junk*
rm -f frame1.out
rm -f diffs
rm -f frame1
rm -f frame2018.out
rm -f selregs2018.out
rm -f framexlocal.c
exit 0
