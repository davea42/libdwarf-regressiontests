
#cc -I /home/davea/dwarf/code/src/lib/libdwarf \
#  /home/davea/dwarf/regressiontests/dwnames_checks/build_dwnames_source.c 
# Run this in the usual directory where you actually
# run the regressiontests.
testsrc=/home/davea/dwarf/regressiontests/
codesrc=/home/davea/dwarf/code

#dwnames_checks

cc -I $codesrc/src/lib/libdwarf \
  -I . \
  -o build_dwnames_source  \
  $testsrc/dwnames_checks/build_dwnames_source.c 

./build_dwnames_source -i $codesrc/src/lib/libdwarf \
   --generate-self-test > $testsrc/dwnames_checks/dwnames_all.c

cc -I  $codesrc/src/lib/libdwarf \
  -I . \
  -I /var/tmp/dwtest \
  -I $testsrc/dwnames_checks \
   $testsrc/dwnames_checks/dwnames_all.c \
   -o dwnames_all ./libdwarf.a -lz -lzstd

./dwnames_all
