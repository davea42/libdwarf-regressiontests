
cc -c -gdwarf-3 -O0 test.c  -o testd3.o
/tmp/dwarfdump -i -v -M testd3.o >junkd3
cc -c -gdwarf-5 -O0 test.c  -o testd5.o
/tmp/dwarfdump -i -v -M testd5.o >junkd5
/tmp/dwarfgen -v 5 -t obj -c 0 --add-skip-branch-ops -o badskipbranchd5.o testd5.o
/tmp/dwarfgen -v 5 -t obj -c 0 --add-skip-branch-ops -o badskipbranchd3.o testd3.o
/tmp/dwarfdump -v -i -M badskipbranchd3.o >junkfinald3
/tmp/dwarfdump -v -i -M badskipbranchd5.o >junkfinald5

