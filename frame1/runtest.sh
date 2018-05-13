#!/bin/sh
libdw=$1
if [ x$libdw = 'x' ]
then
    echo "FAIL frame1 runtest.sh, one argument required."
    exit 1
fi
if [ x$NLIZE = 'xy' ]
then
  opt="-fsanitize=address -fsanitize=leak -fsanitize=undefined"
else
  opt=
fi
cp $libdw/dwarfexample/frame1.c framexlocal.c
if [ -f /usr/include/zlib.h ]
then
  cc -g $opt -I $libdw/libdwarf -L $libdw/libdwarf framexlocal.c -ldwarf -lelf -lz -o frame1
else
  cc -g $opt  -I $libdw/libdwarf -L $libdw/libdwarf framexlocal.c -ldwarf -lelf -o frame1
fi
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





echo PASS frame1/runtest.sh
rm -f junk*
rm -f frame1.out
rm -f diffs
rm -f frame1
rm -f frame2018.out
rm -f selregs2018.out
rm -f framexlocal.c

exit 0
