dnl Process this file with autoconf to produce a configure script.
dnl
dnl configure can only work sensibly run like ./configure [options]
dnl
AC_INIT()
AC_CONFIG_HEADER(config.h)

AC_PROG_CC
AC_C_BIGENDIAN
AC_GCC_TRADITIONAL
AC_PROG_INSTALL
AC_CHECK_TOOL(RANLIB, ranlib, :)
AC_CHECK_TOOL(AR, ar)

AC_CANONICAL_SYSTEM
#echo build $build
#echo host $host
#echo target $target
# i686-pc-linux-gnu

# The path to libdwarf source we want is a path to
# the directory containing the libdwarf, dwarfdump, 
# dwarfgen, and dwarfexample source directories.


here=`pwd`
fullpath=$here/../code

AC_ARG_ENABLE(libdwarf,
  AC_HELP_STRING([--enable-libdwarf=sourcedirectory],
  [Give the full path to the libdwarf/dwarfdump source base]),
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
    echo "Error: The libdwarf source path $enableval does not start with /."
    exit 2
  fi
  fullpath=$enableval
  rm -f junkckpath
fi

AC_ARG_ENABLE([libelf],
   [AS_HELP_STRING([--disable-libelf],
     [disable use of libelf (default is enable) @<:@default=yes@:>@])],
   [ AS_IF(
        [test "x${enableval}" = "xyes"],
        [dwarf_with_libelf="withlibelf"],
        [dwarf_with_libelf="nolibelf"])
   ],
   [dwarf_with_libelf="withlibelf"])

if test  $dwarf_with_libelf = "withlibelf" ; then
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


# We look for a usable dwarfdump.O 
# This finds the last usable one. Perhaps we should
# find the first?
# The Bourne Shell (sh) can do something horrible when
# attempting to deal with an executable of a sort the kernel
# cannot handle (as for 64bit on a 32bit kernel machine).
# It can create a bogus file with @ in the name. An empty file.
# It is not clear why sh creates a file in that case.
ddfound='n'
dd2found='n'
rm -f junkf1
rm -f junkf2
for i in *.O
do
   rm -f junkf1
   rm -f junkf2
   echo $i > junkf1
   grep 'dwarfdump-' < junkf1 >/dev/null 2>/dev/null
   r=$?
   if test $r = 0
   then
     (./$i -i moshe/a.out.t |head -20) >junkf2    2>/dev/null
     # Remove file that should not be here, if it exists.
     rm -f *@*
     cmp junkf2 findexecutable.base  >/dev/null 2>/dev/null
     t=$?
     if test $t -eq 0
     then
        echo "found usable dwarfdump  $i"
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


for i in libdwarf dwarfdump dwarfgen dwarfexample
do
  if test -d $fullpath/$i 
  then
    continue
  else
    echo "We did not find the $i source at $fullpath"
    echo "Giving up."
    exit 2
  fi
done

if test ! -f  BASEFILES
then
  cp BASEFILES.in BASEFILES
fi
echo "libdw=$fullpath" >> BASEFILES

echo "Configuration Options Summary:"
echo
echo " have libelf............: ${dwarf_with_libelf}"
echo " dwarfgen...............: ${enable_dwarfgen}"
echo

echo "Ready to test dwarfdump."

AC_OUTPUT(Makefile)
