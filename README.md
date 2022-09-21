# This is libdwarf-regressiontests README.md

Updated 20 September 2022

Configure options:
--disable-libelf
  (libelf is for dwarfgen build and dwarfgen tests)

--enable-libdwarf=/path/to/libdwarf-code
  (instead of defaulting to whichever of../code ../libdwarf-code
  exists)

--enable-sharedlib
  (using libdwarf-0.so, not libdwarf.a)


## Running the 18000 tests

We recommend running the tests outside
of the regression test or libdwarf source trees.

If directory code (or libdwarf-code) with the
libdwarf code is in the
same directory as the regression test directory,
the simplest run is
 
    cd /my/emptydirectory/
    /path/to/regressiontests/configure
    make

If the code directory is /something/libdwarf-code

    cd /my/emptydirectory/
    /path/to/regressiontests/configure \
        --enable-libdwarf=/somethin/libdwarf-code
    make
   
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
