#!/bin/sh 
#for i in $*
#do
#  case $i in
#  # Makefile does not support this option but
#  # export SUPPRESSDEALLOCTREE=y
#  # works so we set that here. It's fine to
#  # ignore this option and export SUPPRESSDEALLOCTREE=y
#  # before running this script.
#  --enable-libdwarf * echo "libdwarfdir is $i"
#        srcdir =  
#        export SUPPRESSDEALLOCTREE
#        shift ;
#        shift;;
#  *)
#       echo "Improper argument $i to DWARFTEST.sh"
#       exit 1 ;;
#  esac
#done

here=`pwd`
chkres() {
if test $1 != 0
then
  echo "Test failure: $2"
  exit 2
fi
}

srcdir=$1

#srcdir is regressiontests source dir
#codedir is libdwarf code source dir
#datadir is libdwarf code source 'data'

if test ! -d $srcdir ; then
  echo "$srcdir is not a directory"
  exit 1
fi
for s in  enciso7 ossfuzz56530  ossfuzz56548 enciso9 ossfuzz56636
do
  if test ! -d $srcdir/$s ; then
    echo "FAIL: $srcdir/$s is not found" 
    echo "  $srcdir is not regressiontest source."
    exit 1
  fi
done
for s in dwdiff.py exfail.py showpct.py trimsimple.py usertime.py
do
  if test ! -f $srcdir/$s ; then
    echo "FAIL: $srcdir/$s is not found" 
    echo "  $srcdir is not regressiontest source."
    exit 1
  fi
done


codedir=
for s in code libdwarf-code
do
  if test -d  $srcdir/../$s  ; then
    codedir=$srcdir/../$s
    datadir=$srcdir/../$s
    break
  fi
done

if test  "x$codedir" = "x"  ; then
  echo "Unable to locate codedir off of $srcdir"
  exit 1
fi
echo "FOUND libdwarf source as $codedir"
  rm -f junkckpath

for s in bugxml doc src fuzz test doc
do
  if test ! -d $codedir/$s ; then
    echo "FAIL: $codedir/$s is not found"
    echo "  $codedir is not libdwarf source."
    exit 1
  fi
done


sharedlib=n
filelibname="libdwarf.a"
fileplibname="libdwarfp.a"
buildlibsubdir=".libs/"
buildbinsubdir=


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
rm -f junkf1
rm -f junkf2
abs_builddir="$here"
for i in $srcdir/*.O
do
   rm -f junkf1
   rm -f junkf2
   echo $i
   echo $i > junkf1
   grep 'dwarfdump-' < junkf1 
   r=$?
   if test $r -eq 0
   then
     ($i -i $srcdir/moshe/a.out.t |head -n 19) >junkf2    2>/dev/null
     # Remove file that should not be here, if it exists.
     rm -f *@*
     # use python to diff as we deal with windows line-ends easily.
     $srcdir/dwdiff.py $srcdir/findexecutable.base junkf2 >/tmp/INITstdout 2> /tmp/INITstderr
     t=$?
     if test $t -eq 0
     then
        echo "Found usable dwarfdump  $i"
        ddfound='y'
        ddbaselinename=$i
        rm -f dwarfdump.O
        cp $i dwarfdump.O
     else 
        cat junkf2
        echo "Unusable dwarfdump $i"
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

os=`uname`
oso=`uname -o`
if [ "$os" = "Darwin" ]
then
  platform='macos'
elif [ "$os" = "Linux" ]
then
  platform='linux'
elif [ "$os" = "FreeBSD" ]
then
  platform='freebsd'
elif [ "$oso" = "Msys" ]
then
  # Windows msys2
  platform='msys2'
else
  platform='other'
fi


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
# Using xxxx to prevent canonicalpath.py from emitting ..std.. here
pyloc="$tsa/scripts/canonicalpath.py"
ts=`$pyloc $tsa  xxxx name`
echo "testsrc=$ts" >>           BASEFILES.sh
lw=`$pyloc $codedir xxxx name`
echo "libdw=$lw" >>             BASEFILES.sh
cod=`$pyloc $codedir xxxx name`
echo "codedir=$cod" >>          BASEFILES.sh
echo "bldtest=$abs_builddir" >> BASEFILES.sh
echo "ddbaselinename=$ddbaselinename" >> BASEFILES.sh

### Now copy code source files to the test directory
if test ! -f SHALIAS.sh ; then
  cp  $srcdir/SHALIAS.sh SHALIAS.sh
  chkres $? "Fail cp  $srcdir/SHALIAS.sh SHALIAS.sh"
fi
if test ! -f exfail.py ;  then
  cp  $srcdir/exfail.py exfail.py
  chkres $? "Fail cp  $srcdir/exfail.py exfail.py"
fi
if test ! -f dwdiff.py ;  then
  cp  $srcdir/dwdiff.py dwdiff.py
  chkres $? "Fail cp  $srcdir/dwdiff.py dwdiff.py"
fi
if test ! -f dwarfdump.conf ;  then
  cp  $codedir/src/bin/dwarfdump/dwarfdump.conf dwarfdump.conf
  chkres $? "Fail cp  $codedir/src/.../dwarfdump.conf dwarfdump.conf"
fi
#libbld is libdwarf build directory.
echo "platform=$platform"    >> BASEFILES.sh
libbld=$abs_builddir/libbld
echo "libbld=$libbld"        >> BASEFILES.sh
echo "sharedlib=$sharedlib"  >> BASEFILES.sh
echo "filelibname=$filelibname"       >> BASEFILES.sh
echo "fileplibname=$fileplibname"     >> BASEFILES.sh
echo "buildlibsubdir=$buildlibsubdir" >> BASEFILES.sh
echo "buildbinsubdir=$buildbinsubdir" >> BASEFILES.sh

for d in baddie1 bigobj data16 debugfissionb debugfission debuglink \
  dwarfextract dwgena dwgenc emre2 enciso4 guilfanov \
  implicitconst moore mustacchi nolibelf offsetfromlowpc \
  sandnes2 strsize supplementary testoffdie williamson
do
  if test ! -d $abs_builddir/$d
  then
    mkdir $abs_builddir/$d
    chkres $? "Fail mkdir $abs_builddir/$d"
  fi
  if test ! -f $abs_builddir/$d/dwarfdump.conf ; then
    cp dwarfdump.conf $abs_builddir/$d/dwarfdump.conf
    chkres $? "Fail cp  dwarfdump.conf $abs_builddir/$d/dwarfdump.conf"
  fi
done

useshared=no
#echo "sharedlib = $sharedlib"
#if test $sharedlib = "sharedlib" ; then
#  useshared="yes"
#fi

echo "Configuration Options Summary:"
echo
echo " testbuilddir...........: ${abs_builddir}"
echo " libdwarf.build.dir.....: $libbld"
echo " use.libdwarf.a?........: yes"
echo " regressiontests........: $ts"
echo " code...................: $cod"
echo " baseline.dwarfdump.....: $ddbaselinename"

