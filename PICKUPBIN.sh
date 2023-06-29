#!/usr/bin/env sh
. ./SHALIAS.sh
# The -fsanitize=address tells gcc to use extra run-time
# code to look for code writing where it should not.

# dwarfgen and libelf go together here, only
# dwarfgen uses libelf as of June 2021, release 0.1.0.
# configure deals with -lz and -lzstd and their headers.

sharedlib=
sharedlibsudir=
configsharedlibopt=
configsharedlibpopt=
configlibname=
configlibpname=
configwall="--enable-wall"
configstaticlib=
configdwarfgen=
configsharedlib=
configdwarfex="--enable-dwarfexample"
configsanitize=
# BASEFILES has the basic data we need to build.
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
configdwarfgen="--enable-dwarfgen"
configlibname=$filelibname
configlibpname=$fileplibname
if [ $sharedlib = "sharedlib" ]
then
  echo "WARNING: shared lib is problematic for these tests."
  configsharedlib="--enable-shared"
  configstaticlib="--disable-static"
else
  configsharedlib="--disable-shared"
  configstaticlib="--enable-static"
fi
# Checking env var.
if [ x$NLIZE = 'xy' ]
then
  configsanitize="--enable-sanitize"
fi

for i in $*
do
  case $i in
  --sanitize) configsanitize="--enable-sanitize"
    echo "PICKUPBIN.sh set to use -fsanitize."
    shift;;
  --sharedlib) 
    sharedlib="sharedlib"
    configlibname=$configsharedlibopt
    buildlibsubdir=".libs/"
    buildbinsubdir=".libs/"
    configsharedlib="--enable-shared"
    configstaticlib="--disable-static"
    shift;;
  *)
    echo "Improper argument $i to PICKUPBIN.sh"
    exit 1 ;;
  esac
done

if [ "$bldtest" = "$codedir" ]
then
  echo "buildtest and codedir are $codedir, dangerous"
  echo "Giving up"
  exit 1
fi


# libbld is  the build directory for libdwarf/dwarfdump etc.
top_build="$libbld"
targetdir="$bldtest"
sharedlibrpath="-Wl,-rpath=$bldtest"

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
if [ $? -ne 0 ]
then
   echo "FAIL cd $libbld failed"
   exit 1
fi
set -x
###  CONFIGURE now
echo "CONFIGURE now"
#CFLAGS="-O0 -gdwarf-5  --no-omit-frame-pointer" 
echo "$libdw/configure $configwall $configstaticlib"
echo "    $configsharedlib $configdwarfgen $configdwarfex"
echo "    $configsanitize "
$libdw/configure $configwall $configstaticlib \
  $configsharedlib $configdwarfgen $configdwarfex \
  $configsanitize 
if [ $? -ne 0 ]
then
  echo "configure failed. giving up."
  exit 1;
fi
make

set +x
#  Now copy the items built into $targetdir.
cp src/lib/libdwarf/${buildlibsubdir}$configlibname $targetdir/$configlibname
if [ $? -ne 0 ]
then
  echo "No  ${buildlibsubdir}$configlibname , $configlibname to copy! giving up."
  exit 1;
fi

# if shared, no dwarfgen or libdwarfp
echo "sharedlib     : $sharedlib"  
echo "configdwarfgen: $configdwarfgen"
echo "buildlibsubdir: $buildlibsubdir"
echo "configlibpname: $configlibpname"
echo "buildbinsubdir: $buildbinsubdir"
if [  $sharedlib = "n"  -a  x$configdwarfgen = "x--enable-dwarfgen" ]
then
  cp src/lib/libdwarfp/${buildlibsubdir}$configlibpname $targetdir/$configlibpname
  if [ $? -ne 0 ]
  then
    echo "No  ${buildlibsubdir}$configplibname , $configplibname to copy! giving up."
    exit 1;
  fi
  cp src/bin/dwarfgen/${buildbinsubdir}dwarfgen  $targetdir/dwarfgen
  if [ $? -ne 0 ]
  then
    echo "No dwarfgen to copy from bin/dwarfgen/${buildbinsubdir}dwarfgen! giving up."
    exit 1;
  fi
fi

cp src/bin/dwarfexample/${buildbinsubdir}showsectiongroups \
  $targetdir/showsectiongroups
if [ $? -ne 0 ]
then
  echo "src/bin/dwarfexample/${buildbinsubdir}showsectiongroups $targetdir/showsectiongroups"
  echo "No showsectiongroups copy! giving up."
  exit 1;
fi
cp src/bin/dwarfexample/${buildbinsubdir}findfuncbypc  $targetdir/findfuncbypc
if [ $? -ne 0 ]
then
  echo "No findfuncbypc copy! giving up."
  exit 1;
fi
cp src/bin/dwarfexample/${buildbinsubdir}jitreader  $targetdir/jitreader
if [ $? -ne 0 ]
then
  echo "No jitreader copy! giving up."
  exit 1;
fi
cp src/bin/dwarfdump/${buildbinsubdir}dwarfdump  $targetdir/dwarfdump
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
cp src/bin/dwarfexample/${buildbinsubdir}simplereader  $targetdir/simplereader
if [ $? -ne 0 ]
then
  echo "No simplereader to copy! giving up."
  exit 1;
fi
exit 0
