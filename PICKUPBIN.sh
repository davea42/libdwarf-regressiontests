#!/bin/sh
# Pick up newly built dwarfdump in two flavors.
# Pick up libdwarf in two flavors.
. ./SHALIAS.sh
# The -fsanitize=address tells gcc to use extra run-time
# code to look for code writing where it should not.
# It should be sufficiently efficient to do by default, but
# we will see.
#  The gcc option is -fsanitize=address and the like

# dwarfgen and libelf go together here, only
# dwarfgen uses libelf as of June 2021, release 0.1.0.
withlibelf="withlibelf"
libelfopt="--enable-libelf"

# configure deals with -lz and -lzstd and their headers.

withlibelf="withlibelf"
if [ $# -eq 1 ]
then
if [ $1 = "nolibelf" ]
  then
    withlibelf="nolibelf"
    echo "PICKUPBIN.sh set to nolibelf."
    libelfopt="--disable-libelf"
  else 
    if [ $1 != "withlibelf" ]
    then
      echo "Improper argument to PICKUPBIN.sh, use withlibelf or nolibelf"
      exit 1
    fi
    echo "PICKUPBIN.sh set to withlibelf."
  fi
else
  echo "PICKUPBIN set to withlibelf."
fi
if [ ! -f BASEFILES.sh ]
then
    echo "./BASEFILES.sh missing. Run configure"
    exit 1
fi
. ./BASEFILES.sh
if [ "$testsrc" = "$codedir" ]
then
  echo "testsrc and codedir are $testsrc, not allowed"
  echo "Giving up"
  exit 1
fi
if [ "$bldtest" = "$codedir" ]
then
  echo "buildtest and codedir are $codedir, dangerous"
  echo "Giving up"
  exit 1
fi

if [ x$NLIZE = 'xy' ]
then
  sanitize="--enable-sanitize"
else
  sanitize=
fi

top_build="$libbld"
targetdir="$bldtest"

if [ ! -d $libbld ]
then
  if [ -f $libbld ]
  then
    rm $libbld
    if [ $? -ne 0 ]
    then
       echo "Something very wrong with $libbld"
       echo "Not a directory, a file we cannot rm"
       exit 1
    fi
  fi
  mkdir $libbld
  if [ $? -ne 0 ]
  then
    echo "Something very wrong with $libbld"
    echo "Cannot create the directory"
    exit 1
  fi
fi

# Fix the following line to match the desired 
# libdwarf/dwarfdump source 
# directory.
if [ ! -f $codedir/Makefile.in ]
then
  echo "FAIL. $codedir/Makefile.in missing, run autogen.sh in $codedir."
  exit 1
fi

cd $top_build 
echo "PICKUPBIN.sh: $libdw/configure --disable-libelf for dwarfdumpnl"
set -x
$libdw/configure --enable-wall $sanitize  --disable-libelf 
make
if [ $? -ne 0 ]
then
  echo "PICKUPBIN.sh for dwarfdumpnl FAIL"
  exit 1
fi
set +x
cp src/bin/dwarfdump/dwarfdump $targetdir/dwarfdumpnl
set -x
rm -rf $top_build/*

rm -rf $top_build/*
if [ $withlibelf = "withlibelf" ]
then
  echo "PICKUPBIN.sh configure --enable-dwarfgen --enable-dwarfexample"
  set -x
  $libdw/configure $sanitize --enable-wall --enable-dwarfgen --enable-dwarfexample 
  make 
  if [ $? -ne 0 ]
  then
    echo "PICKUPBIN.sh for withlibelf --enable-dwarfgen --enable-dwarfexample FAIL"
    exit 1;
  fi
  set +x
else
  echo "PICKUPBIN.sh: configure --disable-libelf --enable-dwarfexample"
  set -x
  $libdw/configure $sanitize --enable-wall --disable-libelf --enable-dwarfexample 
  make 
  if [ $? -ne 0 ]
  then
    echo "PICKUPBIN.sh for nolibelf --enable-dwarfgen --enable-dwarfexample FAIL"
    exit 1;
  fi
  set +x
fi
if [ $? -ne 0 ]
then
  echo "No libdwarf.a built! giving up."
  exit 1;
fi
cp src/lib/libdwarf/.libs/libdwarf.a $targetdir/libdwarf.a
if [ $? -ne 0 ]
then
  echo "No libdwarf.a to copy! giving up."
  exit 1;
fi

cp src/bin/dwarfexample/showsectiongroups  $targetdir/showsectiongroups
if [ $? -ne 0 ]
then
  echo "No showsectiongroups copy! giving up."
  exit 1;
fi
cp src/bin/dwarfexample/findfuncbypc  $targetdir/findfuncbypc
if [ $? -ne 0 ]
then
  echo "No findfuncbypc copy! giving up."
  exit 1;
fi
cp src/bin/dwarfexample/jitreader  $targetdir/jitreader
if [ $? -ne 0 ]
then
  echo "No jitreader copy! giving up."
  exit 1;
fi
cp src/bin/dwarfdump/dwarfdump  $targetdir/dwarfdump
if [ $? -ne 0 ]
then
  echo "No dwarfdump to copy! giving up."
  exit 1;
fi
cp $codedir/src/bin/dwarfdump/dwarfdump.conf  $targetdir/dwarfdump.conf
if [ $? -ne 0 ]
then
  echo "No dwarfdump.conf to copy! giving up."
  exit 1;
fi
if [ $withlibelf = "withlibelf" ]
then
  cp src/bin/dwarfgen/dwarfgen  $targetdir/dwarfgen
  if [ $? -ne 0 ]
  then
    echo "No dwarfgen to copy! giving up."
    exit 1;
  fi
fi
cp src/bin/dwarfexample/simplereader  $targetdir/simplereader
if [ $? -ne 0 ]
then
  echo "No simplereader to copy! giving up."
  exit 1;
fi
exit 0
