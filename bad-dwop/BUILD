
cc -c -gdwarf-3 -O0 test.c  -o testd3.o
cc -c -gdwarf-5 -O0 test.c  -o testd5.o
/tmp/dwarfgen -v 5 -t obj -c 0 --add-skip-branch-ops -o badskipbranch.o testd5.o
/tmp/dwarfdump -vvv -i -M badskipbranch.o >junk

