dnl Process this file with autoconf to produce a configure script.
dnl
dnl configure can only work sensibly run like ./configure [options]
dnl
AC_INIT
AC_CONFIG_SRCDIR([configure.ac])
AC_CONFIG_HEADERS([config.h])

AC_PROG_CC
AC_C_BIGENDIAN
AC_PROG_GCC_TRADITIONAL
AC_PROG_INSTALL
AC_CHECK_TOOL(RANLIB, ranlib, :)
AC_CHECK_TOOL(AR, ar)

AC_CANONICAL_TARGET
# i686-pc-linux-gnu

# The path to libdwarf source we want is a path to
# the directory containing the libdwarf, dwarfdump, 
# dwarfgen, and dwarfexample source directories.
here=`pwd`
# The following for generating Makefile
# not using datadir quite as autoconf expects.
echo "here: $here"
echo "srcdir: $srcdir"
if test "$srcdir" = "."
then
  # srcdir is the test source
  srcdir=$here
fi
#srcdir is regressiontests source dir
#codedir is libdwarf code source dir
#datadir is libdwarf code source 'data'
codedir=
for s in code libdwarf-code
do
  echo "Try $srcdir/../$s"
  if test -d  $srcdir/../$s  ; then
    codedir=$srcdir/../$s
    datadir=$srcdir/../$s
    #echo "FOUND codedir as $codedir"
  fi
done

if test  "x$codedir" = "x"  ; then
  echo "Unable to locate codedir off of $srcdir"
  exit 1
fi
echo "FOUND codedir as $codedir"

# ALLow user to specify the code source dir
AC_ARG_ENABLE(libdwarf,
  AS_HELP_STRING([--enable-libdwarf=sourcedirectory],[Give the full path to the libdwarf/dwarfdump source base]),
  [ ],[ ])
rm -f junkckpath
echo libdwarfval $enableval
if test x$enableval != 'x'
then
  echo $enableval |grep '^/' >junkckpath
  f=`wc -l <junkckpath`
  if test $f != 1
  then
    rm -f junkckpath
    echo "Error: The libdwarf code source path $enableval does not start with /."
    exit 2
  fi
  codedir=$enableval
  datadir=$enableval
  rm -f junkckpath
fi

# ALLow user to specify the code source dir
AC_ARG_ENABLE(shared,
  AS_HELP_STRING([--enable-shared],
    [Enable shared libdwarf, not static (default is static)
    @<:@default=no@:>@]]),
   [ AS_IF(
        [test "x${enableval}" = "xyes"],
        [enableshared=yes])
   ],
   [enableshared=no])


AC_ARG_ENABLE([libelf],
   [AS_HELP_STRING([--disable-libelf],
     [disable use of libelf (default is enable) @<:@default=yes@:>@])],
   [ AS_IF(
        [test "x${enableval}" = "xyes"],
        [dwarf_with_libelf="withlibelf"],
        [dwarf_with_libelf="nolibelf"])
   ],
   [dwarf_with_libelf="withlibelf"])

if test $dwarf_with_libelf = "withlibelf" ; then
  AC_CHECK_HEADERS(libelf.h libelf/libelf.h)

  ### if no libelf.h add no -lelf and turn off
  ### libelf recognition.
  if test "x${ac_cv_header_libelf_h}" != "xyes" -a "x${ac_cv_header_libelf_libelf_h}" != "xyes"  ;then
    dwarf_with_libelf="nolibelf"
    echo "no libelf headers, so no libelf" 
  else
    echo "Allowing use of libelf."
  fi
fi

if test $dwarf_with_libelf = "withlibelf" ; then
  enable_dwarfgen="yes"
  AC_DEFINE([DWARF_WITH_LIBELF],[1],
    [Set to 1 as we are building with libelf])
  AC_DEFINE([HAVE_DWARFGEN],[1],
    [Set to 1 as we are building dwarfgen])
else
  enable_dwarfgen="no"
fi

if test $dwarf_with_libelf = "withlibelf" ; then
  AC_SUBST(withlibelf,"withlibelf")
else
  AC_SUBST(withlibelf,"nolibelf")
fi

AC_ARG_ENABLE([shared],
   [AS_HELP_STRING([--enable-shared],
     [enable test using shared libdwarf (default is static) @<:@default=no@:>@])],
   [ AS_IF(
        [test "x${enableval}" = "xyes"],
        [sharedlib="sharedlib"])
   ],
   [sharedlib="n"])

if test $sharedlib = "sharedlib" ; then
  AC_SUBST(sharedlib,"sharedlib")
else
  AC_SUBST(sharedlib,"n")
fi


# We look for a usable dwarfdump.O 
# This finds the last usable one. Perhaps we should
# find the first?
# The Bourne Shell (sh) can do something horrible when
# attempting to deal with an executable of a sort the kernel
# cannot handle (as for 64bit on a 32bit kernel machine).
# It can create a bogus file with @ in the name. 
# An empty file.
# It is not clear why sh creates a file in that case.
ddfound='n'
dd2found='n'
rm -f junkf1
rm -f junkf2
abs_builddir="$here"
for i in $srcdir/*.O
do
   rm -f junkf1
   rm -f junkf2
   echo $i > junkf1
   grep 'dwarfdump-' < junkf1 >/dev/null 2>/dev/null
   r=$?
   if test $r -eq 0
   then
     # was ./$i, but now full path so no .
     #echo "Try $i -i $srcdir/moshe/a.out.t"
     #$i -i --show-dwarfdump-conf $srcdir/moshe/a.out.t | head -n 15
     ($i -i $srcdir/moshe/a.out.t |head -n 20) >junkf2    2>/dev/null
     # Remove file that should not be here, if it exists.
     rm -f *@*
     cmp junkf2 $srcdir/findexecutable.base  >/dev/null 2>/dev/null
     t=$?
     if test $t -eq 0
     then
        echo "Found usable dwarfdump  $i"
        ddfound='y'
        rm -f dwarfdump.O
        cp $i dwarfdump.O
     fi
     continue
   fi
done
rm -f junkf1
rm -f junkf2

if test $ddfound = 'n'
then
  echo "Unable to find a usable dwarfdump.O, giving up."
  exit 2
fi


for i in src/lib/libdwarf src/bin/dwarfdump \
  src/bin/dwarfgen  src/bin/dwarfexample
do
  if test -d $codedir/$i 
  then
    continue
  else
    echo "We did not find the $i source at $codedir"
    echo "Giving up."
    exit 2
  fi
done

### Now set up BASEFILES.sh to initialize vars for DWARFTEST.sh
cp $srcdir/BASEFILES.sh.in BASEFILES.sh
if test $? -ne 0 
then
  echo "FAIL configure cannot create BASEFILES.sh"
  exit 1
fi
if test "$srcdir" = "."
then
  tsa=$abs_builddir
else
  tsa=$srcdir
fi
pyloc="$tsa/scripts/canonicalpath.py"
ts=`$pyloc $tsa`
echo "testsrc=$ts" >>           BASEFILES.sh
lw=`$pyloc $codedir`
echo "libdw=$lw" >>             BASEFILES.sh
cod=`$pyloc $codedir`
echo "codedir=$cod" >>          BASEFILES.sh
echo "bldtest=$abs_builddir" >> BASEFILES.sh

### Now copy code source files to the test directory
if test ! -f SHALIAS.sh ; then
  cp  $srcdir/SHALIAS.sh SHALIAS.sh
fi
if test ! -f exfail.py ;  then
  cp  $srcdir/exfail.py exfail.py
fi
if test ! -f dwarfdump.conf ;  then
  cp  $codedir/src/bin/dwarfdump/dwarfdump.conf dwarfdump.conf
fi
#libbld is libdwarf build directory.
libbld=$abs_builddir/libbld
echo "libbld=$libbld" >>        BASEFILES.sh
echo "sharedlib=$sharedlib"  >> BASEFILES.sh
echo "dwarf_with_libelf=$dwarf_with_libelf"  >> BASEFILES.sh

for d in baddie1 bigobj data16 debugfissionb debugfission debuglink \
  dwarfextract dwgena dwgenc emre2 enciso4 guilfanov \
  implicitconst moore mustacchi nolibelf offsetfromlowpc \
  sandnes2 strsize supplementary testoffdie williamson
do
  if test ! -d $abs_builddir/$d
  then
    mkdir $abs_builddir/$d
  fi
  if test ! -f $abs_builddir/$d/dwarfdump.conf ; then
    cp dwarfdump.conf $abs_builddir/$d/dwarfdump.conf
  fi
done

useshared=no
echo "sharedlib = $sharedlib"
if test $sharedlib = "sharedlib" ; then
  useshared="yes"
fi

echo "Configuration Options Summary:"
echo
echo " have libelf............: ${dwarf_with_libelf}"
echo " dwarfgen...............: ${enable_dwarfgen}"
echo " testbuilddir...........: ${abs_builddir}"
echo " libdwarf.build.dir.....: $libbld"
echo " libdwarf.so............: $useshared"
echo " regressiontests........: $ts"
echo " code...................: $cod"

echo "Ready to test."
AC_CONFIG_FILES([Makefile])
AC_OUTPUT
