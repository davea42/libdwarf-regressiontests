#!/bin/sh
. ../BASEFILES
ts=$testsrc/frame1
tf=$bldtest/frame1

libdw=$codedir
bld=$bldtest
dwlib=$bldtest/libdwarf.a
withlibelf=$1
withlibz=$2
if [ x$withlibz = "x" ]
then
   echo "fail frame1 runtest.sh does not have its args: withlibz missing"
   exit 1
fi
if [ x$withlibelf = "x" ]
then
    echo "fail frame1 runtest.sh, does not have its two args: withlibelf missing"
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
    echo fail building framexlocal.c
    exit 1
fi
./frame1 $ts/frame1.orig >frame1.out
if [ $? -ne 0 ]
then
    echo fail running framexlocal.c
    exit 1
fi
diff $ts/frame1.base frame1.out >diffs
if [ $? -ne 0 ]
then
    echo "fail frame1 test.  got diffs in output."
    cat diffs
    echo "To update do: cp $tf/frame1.out $ts/frame1.base"
    exit 1
fi

./frame1 --just-print-selected-regs $ts/frame1.exe.2018-05-11 >selregs2018.out
if [ $? -ne 0 ]
then
    echo fail running framexlocal.c selected regs
    exit 1
fi
diff $ts/selregs2018.base  selregs2018.out >diffs
if [ $? -ne 0 ]
then
    echo "fail selregs2018 test.  got diffs in output."
    echo "To update do: cp $tf/selregs2018.out $ts/selregs2018.base"
    exit 1
fi


./frame1 $ts/frame1.exe.2018-05-11 >frame2018.out
if [ $? -ne 0 ]
then
    echo fail running framexlocal.c frame2018
    exit 1
fi
diff $ts/frame2018.base  frame2018.out >diffs
if [ $? -ne 0 ]
then
    echo "fail frame2018 test.  got diffs in output."
    echo "To update do: cp $tf/frame2018.out $ts/frame2018.base"
    exit 1
fi
rm -f junk*
rm -f frame1.out
rm -f diffs
rm -f frame1
rm -f frame2018.out
rm -f selregs2018.out
rm -f framexlocal.c
echo "PASS frame1/runtest.sh"
exit 0
