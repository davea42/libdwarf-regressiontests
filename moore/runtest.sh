#!/bin/sh
# This is not really part of the test, it simply
# lets us check for the error in the current gcc.

. ../BASEFILES
ts=$testsrc/moore
tf=$bldtest/moore


gcc -c -gdwarf-2 $ts/simplec.c
dwarfdump -l simplec.o
dwarfdump -l -v -v -v simplec.o
