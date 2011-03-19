

LIB=-L../../libdwarf  -ldwarf -lelf
HDR=-I../../libdwarf
all: test1 dwarfextract tests

dwarfextract: dwarfextract.c 
	$(CC) -g $(HDR)  dwarfextract.c -o dwarfextract $(LIB)

test1: test1.c test2.c test1.h
	$(CC) -g test1.c test2.c -o test1

tests:
	sh runtests.sh

clean distclean:
	-rm -f dwarfextract
	-rm -f junk
	-rm -f test1
	-rm -f test1n
