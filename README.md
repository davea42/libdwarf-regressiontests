# This is libdwarf-regressiontests README.md

Updated 20 September 2022

## Historical note

In the sourceforge.net days the libdwarf source itself
was in a directory named 'code'. Since the move to
github the libdwarf source is in a directory
named libdwarf-code. 

Configure options:
--disable-libelf
  (libelf is for dwarfgen build and dwarfgen tests)

--enable-libdwarf=/path/to/libdwarf-code
  (instead of defaulting to whichever of../code ../libdwarf-code
  exists)

--enable-shared
  (using libdwarf-0.so, not libdwarf.a)


## Running the 18000 tests

We recommend running the tests outside
of the regression test or libdwarf source trees.

Lets assume  /path/to/regressiontests is the libdwarf test source
and /path/to has a 'code' or 'libdwarf-code'
directory with the libdwarf/dwarfdump source.
 
    cd /my/emptydirectory/
    /path/to/regressiontests/configure
    make

If the code directory is /some/thing/libdwarf-code

    cd /tmp/emptydirectory/
    /path/to/regressiontests/configure \
        --enable-libdwarf=/some/thing/libdwarf-code
    make

To build and test-with a shared library libdwarf-0.so:

add 
    --enable-shared
to the configure command.

When doing a shared library build/test, 
one must set LD_LIBRARY_PATH so running the
generated dwarfdump  will find the right libdwarf
DWARFTEST.sh does that for you, but to run
the build dwarfdump by hand without installing one could do

    export LD_LIBRARY_PATH="/tmp/emptydirectory:$LD_LIBRARY_PATH
    /tmp/emptydirectory/dwarfdump
   
## Important Build Files

### DWARFTEST.sh
this is the main test script, which runs the tests.

### BASEFILES.sh.in

Used to help generate BASEFILES.sh, which is in turn
used extensively in running DWARFTEST.sh

### BASEFUNCS.sh

Contains shell functions for DWARFTEST.sh

### CHECKIFRUNNING.sh

Used to try to avoid accidentaly running the tests
twice simultaneously in a test directory.

### CLEANUP

Removes unneeded files.
If you are running tests in a clean diretory
this shell script is unnecessary, just clean
out any files you see in the clean directory
before rerunning.
The test scripts never create files with
a leading period (.).

## If updating regression tests configure.ac

On changing configure.ac, run

    autoconf
