#!/bin/sh
libdw=$1
if [ x$NLIZE = 'xy' ]
then 
  opt="-fsanitize=address -fsanitize=leak -fsanitize=undefined"
else
  opt=
fi
if [ -f /usr/include/zlib.h ]
then
  cc -g $opt  -I $libdw/libdwarf -L $libdw/libdwarf alloc_test.c -ldwarf -lelf -lz -o alloc_test
else
  cc -g $opt  -I $libdw/libdwarf -L $libdw/libdwarf alloc_test.c -ldwarf -lelf -o alloc_test
fi

if [ $? -ne 0 ]
then
    echo FAIL building err_allocate/alloc_test .c
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
      echo FAIL RUNNNG err_allocate/alloc_test NLIZE=y .c
      exit 1
    fi
  else
    echo FAIL RUNNNG err_allocate/alloc_test .c
    exit 1
  fi
fi
diff alloc_test.base junk_alloc_test_out  >diffs
if [ $? -ne 0 ]
then
    echo "FAIL err_allocate test.  got diffs in output."
    cat diffs
    echo "To update baseline  do mv junk_alloc_test_out alloc_test.base"
    exit 1
fi
echo PASS err_allocate 
rm -f junk_alloc_test_out
rm -f alloc_test
rm -f diffs
exit 0
