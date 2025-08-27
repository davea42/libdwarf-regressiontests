# libdwarf-regressiontests README.md

Updated 24 August 2025

Regressiontests build libdwarf and dwarfdump using the
meson build system so ensure meson is installed
before attempting a build.

## Basic configure and build with bash shell or equivalent

    Set up any desired env vars.
    we do, for msys2:
    unset NLIZE
    unset SUPPRESSDEALLOCTREE
    unset VALGRIND
    unset DRMEMORY
    unset SUPPRESSBIGDIFFS
    unset COMPILEONLY
    unset SKIPDECOMPRESS
    unset PRINTFFMT
    unset SKIPBIGOBJECTS
    export DWREGRESSIONTEMP=y

    # do configuration
    testsrcloc="$HOME/dwarf/regressiontests"
    x="$testsrcloc/INITIALSETUP.sh $testsrcloc
    echo $x
    $x

    # then run the tests
    $testsrcloc/RUNALL.sh

The exporting DWREGRESSIONTEMP is not unique to msys2,
all regressiontest builds should export DWREGRESSIONTEMP=y .

## Getting all tests to pass

The test results expect $HOME/dwarf/code (for libdwarf-code)
and $HOME/dwarf/regressiontests
(for libdwarf-regressiontests) to be the
project directories.
To run these tests with
success we recommend you put the
source into the expected places.
The test builds normally run in directories
under /var/tmp and those /var/tmp names don't appear
in test results.

Many tests print paths beginning with a string matching
$HOME.  dwarfdump (itself) and the regression tests script
DWARFTEST.sh change such path strings to use $HOME by
replacing (for example) /home/davea with $HOME  .
This works fine on MacOS and Linux variants.
It does not suffice on Windows Msys2

In Msys2, there is now code in $HOME/dwarf/code/src/bin/dwarfdump/dd_sanitized.c
to do a better job of showing $HOME

## Windows Msys2 path issues

If your setup does not exactly) match the maintainers
tests can fail. Large numbers of them.
See just below for the places you might have to
change names to get them to pass.

We run all tests in Windows Msys2 as user 'admin'.

Sometimes test actions get data from the system (around 30 percent of 
the 20000 tests) and that shows C: based name, not /home/admin..

An example failure is

    < No DWARF information present in $HOME/dwarf/regressiontests/Celik/crash_elfio

    ---

    > No DWARF information present in C:/msys64/davea/home/admin/dwarf/regressiontests/Celik/crash_elfio

The 'davea' is because C:/msys64/davea (or C:\msys64\davea  in normal
use in Windows) is the directory we had Msys2 (mingw64) installed in.
For this we attempt to replace 'C:/msys64/davea/home/admin' with '$HOME'

Msys2 or Windows seems to transform filenames that are full paths like
/home/admin  (passed
in from a shell script) to prefix with C:/msys64/davea always.
That is awkward.  

In libdwarf-code/src/bin/dwarfdump/dwarfdump.c see homeify().
See libdwarf-code/src/bin/dwarfdump/dd_sanitized.c
In libdwarf-code/test/canonicalpath.py and
libdwarf-code/test/test_transformpath.py
we address this sort of issue.
The meson option -Dregressiontesting is important.

We eliminate another set of mismatches (run time
failures) by compiling
the fuzz/*.c files (in the regression test build)
with -DDWREGRESSIONTEMP

In the regressiontests dwarfdump build we look for the environment
variable DWREGRESSIONTEMP and if present and with value 'y'
we arrange that dwarfdump calls itself './dwarfdump' and ignores
argv[0] .


## valgrind note

Valgrind uses  such as

    valgrind --leak-check=full --show-leak-kinds=all

have been found to be essential at times.
See below for more remarks on valgrind.

## Historical note

Before July 2023 libelf was used in these tests.  libelf is
no longer used anywhere.

In the sourceforge.net days the libdwarf source itself
was in a directory named

    code

Since the move to github the libdwarf source is in a
directory named

    libdwarf-code

on github. which is also the source project name. As some
scripts here may look for code rather than libdwarf-code
it is probably best to do a link (or symlink) so that both
code and libdwarf-code are valid.

The regressiontesting project is named

    libdwarf-regressiontests

on github.

    We name it regressiontests for test purposes, not
    libdwarf-regressiontests . 

The tests assume that code and regressiontests
are in the same directory.

## Testing overview hints

Never run the tests in a regressiontests or libdwarf-regressiontests
directory, there is no way to automatically
and fully clean up the test directories.

Instead, run tests in an empty directory
you create for
regression testing.

For repeated runs it is convenient to create an empty
test directory, cd to that test directory, and add
a short script that starts by removing every file or
directory present in test directory except, of course,
the script itself.  And then continues on to run the tests
with appropriate environment variables set (see below).

There are a number (unspecified) of points where the
locations of the tests and source matter in comparing
the output of a test run with the expected result.  In a
Linux, Freebsd, or modern MacOS environment the tests
arrange slight modifications to paths in dwarfdump output
so all the tests pass (see below).  None of the tests
are guaranteed to work if any files or directories have
spaces in their name.  On Msys2 (Windows 10) or Microsoft
Visual Studio Those adjustments do not work and these
tests are useless.

The tests are run using shell and python3
scripts.
Meson is used to build libdwarf/dwarfdump.


You must have both zlib (-lz) and libzstd (-lzstd) installed
as a few tests involve compressed Elf sections.

If there are no FAILs the end of a test run prints PASS
along with the counts of tests, SKIPs, and FAILs and a
detailed list of tests is recorded in ALLdd.  Before June
2024 some things which worked correctly (passed) but
were test-harness setup (as opposed to formal tests)
counted in the PASS category  -- now these are, instead,
counted in the BUILDSOK count at the end of the output.
All fails (test-harness or not) are counted as FAIL and
reported as such).  To extract failed tests (if any) from
ALLdd the scripts install a useful python program in the
test directory so do

    ./exfail.py >fails

to split out the FAILs (exfail.py reads ALLdd).

All the tests assume the executables are statically
linked with libdwarf.  There is no support for executables
(dwarfdump) run by the tests built with a shared-library
libdwarf.so.

##  What is dwarfdump-x86_64-ubuntu.O?

Some of the tests involve dwarfdump emitting gigabytes
of text.  Keeping a text file with the expected dwarfdump
output is impractical.  Instead we run most tests with
the dwarfdump built in the testing and with a baseline
dwarfdump-*.O and compare the results.

dwarfdump-x86_64-ubuntu.O is dwarfdump built on Ubuntu
Linux (currently 22.04 LTS)
linked with a static library (libdwarf.a)
that produces correct (expected) output.

Other environments also need such: the
test scripts choose the most useful *.O
to run.

When a change to libdwarf or dwarfdump
changes output we update the relevant *dwarfdump.O .

## Testing command options

There are no real options, but there are environment variables
you may set but do not need to use:

See NLIZE SUPPRESSDEALLOCTREE VALGRIND (and more) below.

Configure options:

## Running the 20000 tests

We recommend running the tests outside of the regression
test and libdwarf source trees.  The default is to build a
static libdwarf.a and use it everywhere in the builds here.
Use of a shared libdwarf.so is not supported or expected
to work.

Lets assume  /path/to/libdwarf-regressiontests is the
regression test source directory (or you might have
/path/to/regressiontests)

INITIALSETUP.sh assumes the libdwarf source code is
alongside the regressiontests directory, and the source
code base directory is named libdwarf-code or code .
It checks directories it identifies as having content
to be sure the content looks appropriate.  In case of
error the scripts exit with a small non-zero error code,
typically one(1).

    cd /my/emptydirectory/
    lrt=/path/to/libdwarf-regressiontests
    $lrt/INITIALSETUP.sh $lrt
    $lrt/RUNALL.sh

The dwarfdump/libdwarf build will be in libbld which the
build creates.  /my/emptydirectory/libbld in this example.

## Environment Variables

when running a test, Unset the mentioned variables make
a standard test run.  With all unset on an example 3GHz
machine a test run takes about 24 to 30 minutes.

    unset NLIZE
    unset SUPPRESSDEALLOCTREE
    unset VALGRIND

    # the following default properly and can be ignored.
    unset SKIPBIGOBJECTS
    unset SUPPRESSBIGDIFFS
    unset SKIPDECOMPRESS

### NLIZE

This adds -fsanitize to all compiles under libdwarf and
compiles in the tests.  Any problems found are reported
as FAIL.

Usually takes twice as long to run as a standard test
run, at this time on a 3GHz Linux machine it takes around
60 minutes.

    NLIZE=y
    export NLIZE

There is no guarantee this does anything unless gcc is
the compiler in use.  This is a grave defect given the
importance of some other compilers.

### SUPPRESSDEALLOCTREE

This tells dwarfdump to suppress libdwarf's normal
tracking of allocations and automatic dealloc (free) of
its tracked allocations.  Used to verify dwarfdump does
every appropriate dealloc and there is no memory leak when
libdwarf's alloc tracking is turned off.

This speeds up the test run a few percent, though the real
purpose is to allow libdwarf itself to be faster.

Combine with NLIZE for thorough checking.

    SUPPRESSDEALLOCTREE=y
    export SUPPRESSDEALLOCTREE

### VALGRIND

This runs dwarfdump under valgrind(1) and any problems
found by valgrind are reported as FAIL.

This takes roughly twenty times as long to run as a
standard run, and on smaller memory or slower machines
valgrind can take many hours.

    VALGRIND=y
    export VALGRIND

### SKIPBIGOBJECTS

    SKIPBIGOBJECTS=y
    export SKIPBIGOBJECTS

A few objects dwarfdump is run on are quite large. On
smaller and slower machines the tests run too slowly to
be usable.  This option is rarely used.

### SUPPRESSBIGDIFFS

    SUPPRESSBIGDIFFS=y
    export SUPPRESSBIGDIFFS

If an output of dwarfdump is more than about thirty
megabytes in size then the tests will use a byte-compare
program (cmp(1)) rather than diff(1) to look for changes.
On smaller machines doing a diff with inputs of gigabyte
size is not going to complete in a reasonable time,
especially if there are lots of small differences.

Unless you are changing dwarfdump yourself there will be no
differences so this option is probably not useful for you.

### SKIPDECOMPRESS

    SKIPDECOMPRESS=y
    exportSKIPDECOMPRESS

This tells the tests not to run dwarfdump on tests with
compressed sections.

Conceptually useful if libz or libzstd is absent.
However the baseline dwarfdump-*.O executables assume
these libraries exist (and they must be shared libraries)
so the tests won't actually work unless these libraries
are present.

### LCOV

Not supported. To run lcov usefully requires a completely
different build setup.

## Important Build Files

### RUNALL.sh

This does the builds and runs all the tests. It uses the
scripts named below to do its work.

### DWARFTEST.sh

Runs the tests and compiles a few things and runs the
test code.

### BASEFILES.sh.in

Used to help generate BASEFILES.sh.  The generation is done
by the INITIALSETUP.sh command.  BASEFILES.sh is sourced
(with the dot (.) shell command) in all *.sh scripts
involved in the testing.

### BASEFUNCS.sh

Contains shell functions for DWARFTEST.sh

### CHECKIFRUNNING.sh

Used to try to avoid accidentally running the tests twice
simultaneously in a test directory.

### PICKUPBIN.sh

Uses meson to compile the libdwarf/dwarfdump source tree
in the directory libbld in the testing directory.

### CLEANUP.sh

Removes generated files in the directory where it is run.
We recommend running tests in a directory set up for
testing, so cleanup.sh becomes pointless.  cleanup.sh is
safe to run in the regressiontests source directory.

If you are running tests in a clean directory it is
not guaranteed to remove all generated-by-test files.
This shell script is unnecessary, just clean out any
files and directories you see in the clean directory
before rerunning.

Testing never creates files with
a leading period (.).
