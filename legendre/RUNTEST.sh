#
gcc -I $1/libdwarf -DNEW frame_test.c ../libdwarf.a -lelf -o frame_test1
./frame_test1
if [  $? -ne 0 ]
then
  echo FAIL frame CFA reg new
  exit 1
fi

gcc -I $1/libdwarf -DOLD frame_test.c ../libdwoldframecol.a -lelf -o frame_test2
./frame_test2
if [  $? -ne 0 ]
then
  echo FAIL frame CFA reg old
  exit 1
fi
rm -f ./frame_test1
rm -f ./frame_test2
echo PASS legendre frame test
exit 0
