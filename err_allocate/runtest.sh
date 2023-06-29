#!/bin/sh

. ../BASEFILES

ts=$testsrc/err_allocate
tf=$bldtest/err_allocate
. $testsrc/BASEFUNCS.sh
libdw=$1
withlibz=$2
if [ x$NLIZE = 'xy' ]
then 
  opt=`checkargs -fsanitize=address -fsanitize=leak \
    -fsanitize=undefined`
else
  opt=
fi
libs=
if [ $withlibz = "withlibz"]
then
  libs="$libs -lz"
fi


cc -g $opt  -I $libdw/libdwarf -L $libdw/libdwarf $ts/alloc_test.c -ldwarf $libs -o alloc_test
fi

if [ $? -ne 0 ]
then
    echo fail building err_allocate/alloc_test .c
    echo "rerun: $ts/runtest.sh $libdw  $withlibz"
    exit 1
fi
./alloc_test >junk_alloc_test_out
er=$?
if [ $er  -ne 0 ]
then
  # One hopes that 23 is going to remain the error value with -fsanitize 
  if [ $er -eq 23 ]
  then
    if [ x$NLIZE = 'xy' ]
    then
      echo "PASS with dealloc failed, NLIZE, check output next."
    else
      echo fail RUNNNG err_allocate/alloc_test NLIZE=y .c
      echo "rerun: $ts/runtest.sh $libdw  $withlibz"
      exit 1
    fi
  else
    echo fail RUNNNG err_allocate/alloc_test .c
    echo "rerun: $ts/runtest.sh $libdw  $withlibz"
    exit 1
  fi
fi
diff $ts/alloc_test.base junk_alloc_test_out  >diffs
if [ $? -ne 0 ]
then
    echo "fail err_allocate test.  got diffs in output."
    cat diffs
    echo "To update baseline  do mv $tf/junk_alloc_test_out $ts/alloc_test.base"
    echo "rerun: $ts/runtest.sh $libdw $withlibz"
    exit 1
fi
echo "PASS err_allocate/runtest.sh" 
rm -f junk_alloc_test_out
rm -f alloc_test
rm -f diffs
exit 0
