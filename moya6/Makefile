# Building the DWP file needs a patched version of the binutils dwp tool with
# DWARF5 support. Command line provided here as a reference.
DWP := dwp

hello: hello.c main.c
	clang -gdwarf-5 -gsplit-dwarf -o $@ $^
	$(DWP) hello.dwo main.dwo -o hello.dwp

clean:
	rm hello.dwo main.dwo hello.dwp hello

.PHONY: clean
