# This is libdwarf-regressiontests README.md

Updated 20 September 2022

## Historical note

In the sourceforge.net days the libdwarf source itself
was in a directory named 'code'. Since the move to
github the libdwarf source is in a directory
named libdwarf-code. 

## Testing command options

Configure options:

    --enable-libdwarf=/path/to/libdwarf-code

Use --enable-libdwarf  when the libdwarf/dwarfdump source tree is
not in parallel with the regressiontests source tree.

    --enable-shared --disable-libelf --disable-static

Use when generating and testing shared-library
libdwarf-0.so instead of the default archive library libdwarf.a.

## Running the 18000 tests

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

    --enable-shared --disable-static --disable-libelf

to the configure command.

Note that any existing date-versioned
libdwarf will be named libdwarf.so.1
and no semantic-version libdwarf will ever be
named with libdwarf.so.1 (we will skip from 
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
takes about 22 minutes.

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

This speeds up the test run a few percent.

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
   
Currently not supported, LCOV may eventually be used to
tell the build to generate code coverage statistics.

   
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

Used to compile the libdwarf/dwarfdump source tree
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
