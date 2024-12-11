#!/usr/bin/env sh
. ./SHALIAS.sh

# options -Dsanitize=true
#         -Dwerror=false
#         -Dlibbdwarfspecialmalloc=false
# env var $NLIZE=y
# env var $WALL=n
# env var $LIBDWARFSPECIALMALLOC=n

# NLIZE tells gcc/clang to use extra run-time
# code to look for code reading, reading or leaking 
# where it should not.
# set env var NLIZE to y or pass in --sanitize
# to build with 
# meson's support: This built in to meson as
# as -Db_sanitize=address,leak,undefined 
# (see code/meson.build)

# compiler warnings default to errors is true by default.
# Pass in --disable-wall or set env var WALL to "n"
# to turn off warning as error.
# Nothing uses libelf now, and as of October 2023
# we always build dwarfgen.
# meson deals with -lz and -lzstd and their headers.

sharedlib=
sharedlibsudir=
configsharedlibopt=
configsharedlibpopt=
configlibname=
configlibpname=
configstaticlib=
configdwarfgen=
configsharedlib=
buildsanitize=
# BASEFILES has the basic data we need to build.
if [ ! -f BASEFILES.sh ]
then
    echo "./BASEFILES.sh missing. Run regressiontests configure"
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
buildsanitize=""
# Checking env var.
if [ "x$NLIZE" = "xy" ]
then
  buildsanitize="-Dsanitize=true"
fi
if [ "x$WALL" = "xn" ]
then
  buildwall="-Dwerror=false" 
fi

if [ "x$LIBDWARFSPECIALMALLOC" = "xy" ]
then
  buildlibdwarfspecialmalloc="-Dlibdwarfspecialmalloc=true"
fi
if [ "x$WALL" = "xn" ]
then
  buildwall="-Dwerror=false" 
fi

for i in $*
do
  case $i in
  --sanitize) buildsanitize="-Dsanitize=true"
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
  --disable-wall) 
    buildwall="-Dwerror=false" 
    shift;;
  *)
    echo "Improper argument $i to PICKUPBIN.sh"
    exit 1 ;;
  esac
done
echo "buildsanitize = $buildsanitize"

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
if test ! -f $codedir/configure ; then
  echo "FAIL. $codedir/configure missing. "
  echo "      Which suggests not the right source directory"
  echo "      even though we no longer use configure here." 
  exit 1
fi
cd $top_build 
if [ $? -ne 0 ]
then
   echo "FAIL cd $libbld failed"
   exit 1
fi

###  Build now
m="meson setup --default-library static $buildsanitize  $buildwall  -Ddwarfexample=true -Ddwarfgen=true . $libdw $buildlibdwarspecialmalloc"
echo $m
$m
if [ $? -ne 0 ]
then
  echo "meson setup failed. giving up."
  exit 1;
fi
ninja

#  Now copy the items built into $targetdir.
copyobject() {
  f=$1
  s=$2
  t=$3
  if test ! -f $s/$f ; then  
     echo "FAIL source copyobject $f $s $t"
     exit 1
  fi
  if test ! -d $t ; then  
     echo "FAIL targetdir copyobject $f $s $t"
     exit 1
  fi
  cp $s/$f $t/$f
  r=$?
  if test $r -ne 0 ; then
     echo "FAIL copy in copyobject $f $s $t"
     exit 1
  fi
}


echo "sharedlib     : $sharedlib"
echo "configdwarfgen: $configdwarfgen"
echo "buildlibsubdir: $buildlibsubdir"
echo "configlibpname: $configlibpname"
echo "buildbinsubdir: $buildbinsubdir"
echo "libdwarfspecialmalloc: $buildlibdwarfspecialmalloc"
if [  $sharedlib = "n"  -a  x$configdwarfgen = "x--enable-dwarfgen" ]
then
  copyobject libdwarfp.a $libbld/src/lib/libdwarfp $targetdir 
  copyobject dwarfgen    $libbld/src/bin/dwarfgen $targetdir
fi
copyobject libdwarf.a        $libbld/src/lib/libdwarf $targetdir 
copyobject showsectiongroups $libbld/src/bin/dwarfexample $targetdir
copyobject findfuncbypc      $libbld/src/bin/dwarfexample $targetdir
copyobject jitreader         $libbld/src/bin/dwarfexample $targetdir
copyobject simplereader      $libbld/src/bin/dwarfexample $targetdir
copyobject dwarfdump      $libbld/src/bin/dwarfdump $targetdir
copyobject dwarfdump.conf $codedir/src/bin/dwarfdump $targetdir
exit 0
