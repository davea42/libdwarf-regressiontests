# This is libdwarf-regressiontests README.md


Updated 19 October 2023

## Historical note

Before July 2023 libelf was in these tests.
libelf is no longer used anywhere.

In the sourceforge.net days the libdwarf source itself
was in a directory named 

    code

Since the move to
github the libdwarf source is in a directory
named 

    libdwarf-code

on github, which is also the
source project name. the regressiontesting project is
named 

    libdwarf-regressiontests

on github.

## Testing overview hints

In spite of the github naming there are a number (unspecified) 
of points where the locations of the tests and source matter
in comparing the output of a test run with the expected result.

The tests are run using GNU configure and shell and python3
scripts..

The tests expect $HOME/dwarf/code
and $HOME/dwarf/regressiontests to be the
project directories.  To run these tests with
success we recommend you put the
source into the expected places.
The test builds and runs  occur in directories
under /var/tmp and those /var/tmp names don't appear
in test results.

You must have both zlib (-lz) and libzstd (-lzstd) installed to
as a few tests involve compressed Elf sections.

If there are no FAILs the end of a test run
prints PASS along with the counts of tests, SKIPs,
and FAILs and a detailed list of tests is recorded
in ALLdd. To extract failed tests (if any) from ALLdd
the scripts install a useful
python program in the test directory
so do

    ./exfail.py >fails

to split out the FAILs (exfail.py reads ALLdd).

##  What is dwarfdump-x86_64-ubuntu.O?

Some of the tests involve dwarfdump emitting 
Gigabytes of text.  Keeping a text file
with the expected dwarfdump output is impractical.
Instead we run most tests with the dwarfdump built
in the testing and with a baseline *dwarfdump.O
dwarfdump and compare the results.

dwarfdump-x86_64-ubuntu.O is, on Ubuntu 22.04 LTS, a dwarfdump
linked with a static library (libdwarf.a)
that produces correct and expected output.

Other environments also need such: the
test scripts choose the most useful *.O
to run.

When a change to libdwarf or dwarfdump
changes output we update the relevant *dwarfdump.O .

## Testing command options

Configure options:

    --enable-libdwarf=/path/to/libdwarf-code

Use --enable-libdwarf  when the libdwarf/dwarfdump source tree is
not in parallel with the regressiontests source tree.

    --enable-shared --disable-static

Use when generating and testing shared-library
libdwarf.so.0 instead of the default archive library libdwarf.a.

## Running the 20000 tests

We recommend running the tests outside
of the regression test and libdwarf source trees.

Lets assume  /path/to/regressiontests is the libdwarf test source
and /path/to has a 'code' or 'libdwarf-code'
directory with the libdwarf/dwarfdump source.
 
    cd /my/emptydirectory/
    /path/to/regressiontests/configure
    make

The dwarfdump/libdwarf build will be in
/my/emptydirectory/libbld in this example.

If the code directory is /some/thing/libdwarf-code

    cd /tmp/emptydirectory/
    /path/to/regressiontests/configure \
        --enable-libdwarf=/some/thing/libdwarf-code
    make

To build and test-with a shared library libdwarf.so.0
add:

    --enable-shared --disable-static

to the configure command.

Note that any existing date-versioned
shared-library libdwarf is named libdwarf.so.1
and no semantic-version shared-library
libdwarf will ever be
named libdwarf.so.1 (we will skip from 
libdwarf.so.0 to libdwarf.so.2
at some point in the future).

When doing a shared library build/test, 
one must set LD_LIBRARY_PATH so running the
generated dwarfdump  will find the right libdwarf
DWARFTEST.sh does that for you, but to run
the test-built dwarfdump by hand without installing one could do

    export LD_LIBRARY_PATH="/tmp/emptydirectory:$LD_LIBRARY_PATH
    /tmp/emptydirectory/dwarfdump

## Environment Variables

when running a test, ensure to do the following to
make a standard test run.
With all unset on an example 3GHz machine a test run
takes about 24 minutes.

    unset NLIZE
    unset SUPPRESSDEALLOCTREE
    unset LCOV
    unset VALGRIND


### NLIZE

This adds -fsanitize to all compiles under
libdwarf and in the tests.
Any problems found are reported as FAIL.

Usually takes twice as long to run as a
standard test run. 

    NLIZE=y
    export NLIZE

### SUPPRESSDEALLOCTREE

This tells dwarfdump to suppress it's normal
tracking of allocations and automatic dealloc (free)
of its allocations.
Used to verify dwarfdump does every appropriate 
dealloc.

This speeds up the test run a few percent, though
the real purpose is to allow libdwarf itself to
be faster.

Can be combined with NLIZE.

    SUPPRESSDEALLOCTREE=y
    export SUPPRESSDEALLOCTREE

### VALGRIND

This runs dwarfdump under valgrind(1) 
and any problems found by valgrind are reported
as FAIL.

This takes roughly twenty times as long to run
as a standard run.
   
    VALGRIND=y
    export VALGRIND

### LCOV
   
Currently not supported. To run lcov usefull requires
a completely separate build setup.
   
## Important Build Files

### DWARFTEST.sh
this is the main test script, which runs the tests.

### BASEFILES.sh.in

Used to help generate BASEFILES.sh. 
The generation is done by the configure command.
BASEFILES.sh is
sourced (with the dot (.) shell command) in all *.sh scripts
involved in the testing.

### BASEFUNCS.sh

Contains shell functions for DWARFTEST.sh

### CHECKIFRUNNING.sh

Used to try to avoid accidentally running the tests
twice simultaneously in a test directory.

### PICKUPBIN.sh

Uses configure  to compile the libdwarf/dwarfdump source tree
in the directory libbld in the testing directory.

### CLEANUP.sh

Removes generated files in the directory where 
it is run.
Safe to run in the regressiontests source directory.
If you are running tests in a clean directory
this shell script is unnecessary, just clean
out any files you see in the clean directory
before rerunning.
Testing never creates files with
a leading period (.).

## If updating regression tests configure.ac

On changing configure.ac, run autoconf with no options
to create a new configure script.

    autoconf
