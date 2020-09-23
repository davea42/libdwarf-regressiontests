# Building the DWP file needs a patched version of the binutils dwp tool with
# DWARF5 support. Command line provided here as a reference.
DWP := dwp

all: loclists loclists.dwp

loclists loclists.dwo loclists2.dwo main.dwo: loclists.c loclists2.c main.c
	clang -gdwarf-5 -gsplit-dwarf -O3 -o $@ $^

loclists.dwp: loclists.dwo loclists2.dwo main.dwo
	$(DWP) $^ -o loclists.dwp

clean:
	rm -f *.dwo *.dwp loclists

.PHONY: clean
