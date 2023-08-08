LIBDWARFDIR     = ../../../
LIBDWARF_LIB    =  ../../../libdwarf/libdwarf.a
LIBDWARF_INC    = ../../../include/

all : test-eh eh-frame

clean :
	rm -f test-eh eh-frame

test-eh : test-eh.c
	gcc -L$(LIBDWARF_LIB) -ldwarf -o $@ $< 

eh-frame : eh-frame.cc
	g++ -g -o $@ $^
