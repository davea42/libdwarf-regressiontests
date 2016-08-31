
dd=../dwarfdump
gen=../dwarfgen
t1=junkstdout
t2=junkstderr
ta=junkgen.o

rm -f $t1
rm -f $t2
rm -f $ta

$gen -s -t obj  -c 0 -o $ta createirepformfrombinary.o > $t1 2> $t2 
