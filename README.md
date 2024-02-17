# This is libdwarf-regressiontests README.md

Updated 16 February 2024

## valgrind note

Valgrind uses  such as

    valgrind --leak-check=full --show-leak-kinds=all

have been found to be essential at times.

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

Never run the tests in a regressiontests or libdwarf-regressiontests
directory. Instead, run tests in a directory set up for
regression testing.

There are a number (unspecified) 
of points where the locations of the tests and source matter
in comparing the output of a test run with the expected result,
and such can result in failures.

The tests are run using shell and python3
scripts.   Meson is used to build libdwarf/dwarfdump.

The test results expect $HOME/dwarf/code (for libdwarf-code)
and $HOME/dwarf/regressiontests 
(for libdwarf-regressiontests) to be the
project directories.
To run these tests with
success we recommend you put the
source into the expected places.
The test builds and runs  occur in directories
under /var/tmp and those /var/tmp names don't appear
in test results.

Many tests print paths beginning with a string matching
$HOME.  dwarfdump (itself) and the regression tests script
DWARFTEST.sh change such path strings to use $HOME by
replacing (for example) /home/davea with $HOME  .

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

There are no real options, but there are environment variables
you may set but do not need to use:

See NLIZE SUPPRESSDEALLOCTREE VALGRIND below.

Configure options:

## Running the 20000 tests

We recommend running the tests outside
of the regression test and libdwarf source trees.
The default is to build a static libdwarf.a and
use it everywhere in the builds here.

Lets assume  /path/to/libdwarf-regressiontests is
the regression test source
directory (or you might have /path/to/regressiontests)

INITIALSETUP.sh assumes the libdwarf source code is alongside
the regressiontests directory, and the source code base directory
is named libdwarf-code or code .
It checks directories it identifies as having content
to be sure the content looks appropriate.
In case of error the scripts exit with a small non-zero error code,
typically one(1).
 
    cd /my/emptydirectory/
    lrt=/path/to/libdwarf-regressiontests
    $lrt/INITIALSETUP.sh $lrt
    $lrt/RUNALL.sh

The dwarfdump/libdwarf build will be in libbld
which the build creates.
/my/emptydirectory/libbld in this example.

## Environment Variables

when running a test, Unset the mentioned variables
make a standard test run.
With all unset on an example 3GHz machine a test run
takes about 24 minutes.

    unset NLIZE
    unset SUPPRESSDEALLOCTREE
    unset VALGRIND


### NLIZE

This adds -fsanitize to all compiles under
libdwarf and compiles in the tests.
Any problems found are reported as FAIL.

Usually takes twice as long to run as a
standard test run, at this time on a 3GHz
Linux machine it takes around 50 minutes. 

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
   
Not supported. To run lcov usefully
requires a completely different build setup.
   
## Important Build Files

### RUNALL.sh

This does the builds and runs all the tests. It uses
the scripts named below to do its work.

### DWARFTEST.sh

Runs the tests and compiles a few things and runs the test code.

### BASEFILES.sh.in

Used to help generate BASEFILES.sh. 
The generation is done by the INITIALSETUP.sh command.
BASEFILES.sh is
sourced (with the dot (.) shell command) in all *.sh scripts
involved in the testing.

### BASEFUNCS.sh

Contains shell functions for DWARFTEST.sh

### CHECKIFRUNNING.sh

Used to try to avoid accidentally running the tests
twice simultaneously in a test directory.

### PICKUPBIN.sh

Uses meson to compile the libdwarf/dwarfdump source tree
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

