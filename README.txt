Latest update: 7 November 2019

NEWS November 2019: 
The regression tests have now been run in full with no errors
on Linux little endian (Ubuntu 18.04 32 and 64bit), FreeBSD
little endian (32 and 64 bit), s390 big endian (Ubuntu 18.04),
and MacOS Catalina little endian (64 bit,using the Apple
Command Line Tools).
In some environments a few tests must be skipped and
those report 'SKIP' in the test output.

This directory (regressiontests) is the base which is used for
regression testing of libdwarf.    It will probably only be
usable on a POSIX compliant system (for example Unix, Linux, FreeBSD,
or MacOS).

Summary of overall regressiontests options:
   ./configure [--disable-libelf]
   make

The tests require (in some cases) that dwarfdump.conf
reside in one's home directory.

See code/README for the overall scripts/run-all-tests.sh
script.

The Makefiles here do assume gnu make (gmake) as of the
August 2018 change to using full autoconf/automake.  For Linux
that is not a problem 'make' is gmake.  For non-linux doing
'gmake' to start the testing does not suffice as there are
shell scripts invoked and the Makefiles may generate errors.
For that case modify ./SHALIAS.sh to create an alias for make
referencing gmake (see the comments in SHALIAS.sh).

Here are some tests that relate to specific features
of groups:
  groups split dw:
  camp/empty.o

  COMDAT:
  comdatex/example.o
  emre/input.o

  all dwo:
  emre6/class_64_opt_fpo_split.dwp
  liu/NULLdereference0519.elf
  liu/OOB_read4.elf
  emre3/a.out.dwp
  debugfissionb/ld-new.dwp
  debugfission/... test 2

A primary problem is insufficient testing of the
dwarf-generation routines.  The libdwarf consumer functions
are nearly all tested here.

The basic approach is simple: run each test with a
newly-compiled dwarfdump and with the previous known-good
version.  Compare the resulting text outputs and evaluate
the differences.

That comparison is only meaningful if one actually has
confidence that the previous version of dwarfdump
present and working correctly, but in spite of
this deficiency these tests seem adequate.

For a few tests that comparison simply does not work.  In a few
cases a special build of libdwarf is needed to test specific
functionality (the test setups do that for you).

The test will not work unless the full libdwarf/dwarfdump
source distribution is visible to the regression tests.
In addition to the packages needed to build dwarfdump etc,
the GNU binutils-dev or equivalent must be installed to get
bfd.h in a visible standard header location (the 'dwarfextract'
test will fail without GNU binutils-dev).

One of the tests assumes a segmentation violation (or
the like) will cause a corefile to be created in
the local directory.  So the test system's ulimit
and other core-creation settings must be consistent
with that.  On linux 
    ulimit -a
shows the limits.
    ulimit -c unlimited
sets the core size you want during the test run.

A source of variation in output is libelf, since 
libelf traditionally does a poor job of noticing
invalid Elf and some versions are
better than others.  Libelf 0.8.13 does a little better
but is still pretty weak. For example it adds
offset to size before checking for a value >
the size of the entire file so an overflow in the
add would result in letting the read proceed.
Freebsd libelf is a bit better than Ubuntu
libelf in testing for legitimate Elf.
Note that libdwarf no longer requires libelf
exist and libdwarf's elf reader code is
careful to validate Elf object contents
for reasonableness.

To run a full test:
	./configure
	make

If you are using a system with no pre-existing dwarfdump[2].O
to work with you must build the current dwarfdump[2].O
and hope that is a decent test.  It seems advisable to
move to keeping a baseline-output for at least some tests.
Many of the tests involve large amounts of dwarfdump output,
so keeping a baseline good result of text for those would
make the regression test repository much much larger. So when
choosing what to switch to 'baseline testing' with known-good
dwarfdump output will involve some careful consideration.

To clean up:
       make clean
To clean out the configure cache etc, getting back to
a clean distribution:
       make distclean

If the dwarf/libdwarf etc code is not in
../code/dwarf then an example suggests how to
tell the tests where the source is:
      configure --enable-libdwarf=/a/b/code/dwarf

If you want to use addressing correctness checks (gcc -fsanitize=address)
where some checks may be skipped, do:
      ./configure
      export NLIZE=y
      make
With -fsanitize=address no corefile can be created
(analyze software catches the segv etc) so
coredump-related tests cannot work.


======================================================================
PASS 36141
FAIL 3 (the differences due to trivial dwarfdump changes since the
last baseline update.)

Normally all will pass (FAIL will show 0).
The CPUs/cores in use are all in the general area of 2 to 3 GHz.

As of 17 April 2018, test runtimes in minutes:
Ubuntu 16.04 64:   24  3GHz cpu, fastest.
Ubuntu 16.04 32:   44  Slowest, smallest memory.
FreeBSD 32bitVM:   40 
FreeBSD 64bitVM:   40


     
      
   


======================================================================
What follows is some background detail.

The key scripts are PICKUPBIN RUNALL.sh DWARFTEST.sh CLEANUP

PICKUPBIN [withlibelf|nolibelf]:  this builds libdwarf and dwarfdump
and stores the result in the regressiontests directory.
The script assumes the source directory tree 
is named in the BASEFILES file sourced
from PICKUPBIN. 

For example, on one machine BASEFILES
contains the sh(bash) statement naming
the base source directory
   libdw=/home/davea/dwarf/regressiontests/../code

Here are the main directories in 'code', the base source
code directory on a test machine.
   libdwarf
   dwarfgen
   dwarfdump
   dwarfexample
That is, just the normal libdwarf/dwarfdump source distribution.

README.txt:  This file.

DWARFTEST.sh [withlibelf|nolibelf]:  Runs a specific test set.
   This relies on having dwarfdump alter the program_name
   it gets from argv[0] so that /dwarfdump.O becomes
   /dwarfdump  Doing this avoids sed commands (see
   function unifyddname() in DWARFTEST.sh) and
   reduces DWARFTEST.sh runtime by 70% compared
   to using sed. It's not that sed is slow, it is simply
   that some of the test output files are very large.

RUNALL.sh [withlibelf|nolibelf]:  Runs RUNALL.sh once.
   Comparing dwarfdump.O output vs the new dwarfdump.

CLEANUP:  Cleans up all the temporary results from tests.
   Does not clean out files created by configure.
   Use 'make distclean' to clean out those files.

The 'zero' directory holds a utility application that
enables scrubbing sections of object files to all-zero-bytes.
This is not used for testing.  This application exists so
seemingly proprietary objects can be added to the test without
revealing any of the compiler-generated actual instructions.

One emails a contributor the zero.cc source and
lets the contributor remove instruction bytes from the object
(readelf -S is a convenient way to get the lists of object
offsets and lengths of sections).  Then the contributor
provides the modified object to the libdwarf project and
we add test code using it to DWARFTEST.sh Since libdwarf
never pays any attention to sections other than those named
.eh_frame or .debug_* one can use 'zero' to set those other
section contents to all-zero and preserve proprietary code
generation information.  Thus making it easier for people to
contribute object files.

David Anderson

