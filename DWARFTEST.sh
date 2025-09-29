#!/usr/bin/env sh
trap "echo Exit testing - signal ; rm -f $dwbb ; exit 1 " 2
#
echo "Env vars that affect the tests:"
echo "  If you wish do one or more of these before running the tests."
echo "  Add sanity...................: export NLIZE=y"
echo "  Suppress de_alloc_tree.......: export SUPPRESSDEALLOCTREE=y"
echo "  Use valgrind.................: export VALGRIND=y"
echo "  Revert to normal test........: unset SUPPRESSDEALLOCTREE"
echo "  Revert to normal test........: unset NLIZE"
echo "  Revert to normal test........: unset VALGRIND"
echo "  Revert to normal test........: unset COMPILEONLY"
echo "  Revert to all tests  ........: unset SINGLEONLY"
echo "  Revert to default printf ....: unset PRINTFFMT"
echo "  Skip tests needing zlib zstd : unset SKIPDECOMPRESS"
echo "  printf_sanitize..............: export PRINTFFMT=DEFAULT"
echo "  printf_sanitize..............: export PRINTFFMT=NOSANITY"
echo "  printf_sanitize..............: export PRINTFFMT=ASCII"
echo "  SkipBigObjects...............: export SKIPBIGOBJECTS=y"
# On certain VMs if too much change, we get
# stuck at 1% done forever (and after 10 hours
# far from done with the tests).
# suppress those tests via:
# export SUPPRESSBIGDIFFS=y
# It is not test runtime that is the problem.
# If the actual result difference is substantial
# the shell time doing diff etc takes too long.
# 28 August 2020. Completely revamped the way
# tests are counted and the way $suppressbigdiffs is implemented.

#At this time no tests involve zstd.
#The following tests involve zlib:
#regressiontests/debugso20230811.debug
#regressiontests/compressed-be/testprog-be-dw4
#regressiontests/moya2/filecheck.dwo
#regressiontests/liu/NULLderefer0505_01.elf
#regressiontests/klingler2/compresseddebug.amd64
#regressiontests/navarro/compressed_aranges_test
#regressiontests/klingler/dwarfgen-zdebug
#regressiontests/klingler/test-with-zdebug
#regressiontests/dwarf4/ddg4.5dwarf-4

#set -x
echo 'Starting regressiontests: DWARFTEST.sh' \
   `date "+%Y-%m-%d %H:%M:%S"`

# Affects running dwarfdump in runtest with
# dwarfdump printf options.

compileonly=n
if [ x$COMPILEONLY = "xy" ]
then
  compileonly=y
fi
singleonly=n
if [ x$SINGLEONLY = "xy" ]
then
  singleonly=y
fi
# currently defaults to utf8
asciionly=n
nosanity=n
fsu=
# refering to dwarfdump printf
if [ x$PRINTFFMT = "xASCII" ]
then
  fsu="--format-suppress-utf8"
  asciionly=y
fi
skipbigobjects=n
if [ "x$SKIPBIGOBJECTS" = "xy" ]
then
   skipbigobjects=y
fi
# refering to dwarfdump printf
nosanity=n
if [ x$PRINTFFMT = "xNOSANITY" ]
then
  nosanity=y
  fsu="--format-suppress-sanitize"
fi
echo "  dwarfdump printf option......: $fsu"

skipdecompress=n
if [ "x$SKIPDECOMPRESS" = "xy" ]
then
  skipdecompress=y
fi
echo "  skipdecompress..............: $skipdecompress"
echo "  skipbigobjects..............: $skipbigobjects"

s=SHALIAS.sh
if [ ! -f ./$s ]
then
  echo "./$s cannot be found in " `pwd`
  echo "do configure before running the tests"
  exit 1
fi
. ./$s

# BASEFILES.sh created by INITIALSETUP.sh
b=BASEFILES.sh
if [ ! -f ./$b ]
then
  echo "./$b cannot be found in " `pwd`
  echo "do configure before running the tests"
  exit 1
fi
cat ./$b
. ./$b

. $testsrc/BASEFUNCS.sh

warn="-Wall"
dwarfgenok=y
if [ $platform = "macos" ]
then
  dwarfgenok=n
fi
if [ $platform = "msys2" ]
then
  warn=
fi

stsecs=`date '+%s'`
dwbb=$bldtest/dwbb

suppresstree=
#next line is the dwarfdump option to suppress de alloc tree
#suppresstree="--suppress-de-alloc-tree"
#suppresstree="--suppress-de-alloc-tree --print-alloc-sums"
#Now with env var.
if [ x$SUPPRESSDEALLOCTREE = "xy" ]
then
   suppresstree="--suppress-de-alloc-tree"
fi
okcd() {
   s=$1
   if [ $s -ne 0 ]
   then
      echo " FAILED cd to $2"
      exit 1
   fi
}

mklocal() {
  d=$1
  if [ ! -d $d ]
  then
     rm -f $d
     mkdir $d
     if [ $? -ne 0 ]
     then
       echo "Unable to create local dir %d"
       exit 1
     fi
  fi
  cd $d
  okcd $? $d
}

for i in $*
do
  case $i in
  # Makefile does not support this option but
  # export SUPPRESSDEALLOCTREE=y
  # works so we set that here. It's fine to
  # ignore this option and export SUPPRESSDEALLOCTREE=y
  # before running this script.
  --suppress-de-alloc-tree) echo "DWARFTESTS.sh arg is $i"
        echo "Suppressing de_alloc_tree"
        suppresstree=$i
        SUPPRESSDEALLOCTREE=y
        export SUPPRESSDEALLOCTREE
        shift;;
  *)
       echo "Improper argument $i to DWARFTEST.sh"
       exit 1 ;;
  esac
done

if [ ! -f ./dwarfdump ]
then
  echo " ./dwarfdump needed."
  echo "Redo the tests and check for build problems"
  exit 1
fi

withlibz=no
libzlink=
libzlib=
libzhdr=
# For test purposes, withlibz is set to 'withlibz'
# only when both libz and libzstd are available
# and in that case 
#  libzhdr is set to zero or more -I
# and 
#  libzlib is set to zero or more -L
# and 
#  libzlink is set to -lz -lzstd

mklocal checkforlibz
  # exit code will be 0 if libz in std locations 
  # exit code will be 1 if libz in /usr/local
  # exit code will be 2 if libz in /opt/local
  # exit code will be 3 if libz not found
  # Otherwise is an error, give up.
  sh $testsrc/checkforlibz/runtest.sh $testsrc
  rz=$?
  if test $rz -eq 0 ; then
    withlibz=withlibz
    libzlink="$libzlink -lz"
    echo "FOUND zlib standard location"
  elif test $rz -eq 1 ; then
    withlibz=withlibz
    libzlink="$libzlink -lz"
    libzhdr="$libzhdr -I/usr/local/include"
    libzlib="$libzlib -L/usr/local/lib"
    echo "FOUND zlib /usr/local"
  elif test $rz -eq 2 ; then
    withlibz=withlibz
    libzlink="$libzlink -lz"
    libzhdr="$libzhdr -I/opt/local/include"
    libzlib="$libzlib -L/opt/local/lib"
    echo "FOUND zlib /opt/local"
  elif test $rz -eq 3 ; then
    echo "NOT FOUND Missing zlib"
    withlibz=no
  else
    echo "Something went wrong in looking for libz. "
    echo "Fix the tests and rerun"
    exit 1
  fi
cd ..

if test "$withlibz" = "withlibz" ; then
  mklocal checkforlibzstd
    # exit code will be 0 if libz in std locations
    # exit code will be 1 if libz in /usr/local
    # exit code will be 2 if libz in /opt/local
    # exit code will be 3 if libz not found
    # Otherwise is an error, give up.
    sh $testsrc/checkforlibzstd/runtest.sh $testsrc
    rz=$?
    if test $rz -eq 0 ; then
      # still withlibz.
      withlibz=withlibz
      libzlink="$libzlink -lzstd"
      echo "FOUND libzstd standard location"
    elif test $rz -eq 1 ; then
      #withlibz=withlibz
      libzlink="$libzlink -lzstd"
      libzhdr="$libzhdr -I/usr/local/include"
      libzlib="$libzlib -L/usr/local/lib"
      echo "FOUND libzstd /usr/local"
    elif test $rz -eq 2 ; then
      #withlibz=withlibz
      libzlink="$libzlink -lzstd"
      libzhdr="$libzhdr -I/opt/local/include"
      libzlib="$libzlib -L/opt/local/lib"
      echo "FOUND libzstd /opt/local"
    elif test $rz -eq 3 ; then
      echo "NOT FOUND Missing libzstd, so turn off zlib too"
      withlibz=no
    else
      echo "Something went wrong in looking for libz. "
      echo "Fix the tests and rerun"
      cd ..
      exit 1
    fi
  cd ..
fi

if test "$withlibz" = "no" ; then
  echo "Do not have both zlib and libzstd. Ignore both"
  # Either handle both or neither.
  libzlink=""
  libzlib=""
  libzhdr=""
fi

#  Update these vars and BASEFILES.sh 
echo "withlibz=\"$withlibz\"" >>BASEFILES.sh
echo "libzlink=\"$libzlink\"" >>BASEFILES.sh
echo "libzhdr=\"$libzhdr\"" >>BASEFILES.sh
echo "libzlib=\"$libzlib\"" >>BASEFILES.sh

echo "Lock file.................: $dwbb"
if [ -f $dwbb ]
then
  echo "Lock file exists with content:"
  cat $dwbb
  echo "DWARFTEST.sh exits. Take no other action"
  exit 1
fi

wl="no"
if [ $withlibz = "withlibz" ]
then
  wl="yes"
fi
echo "test source...............: $testsrc"
echo "library source............: $codedir"
echo "test build................: $bldtest"
echo "library build.............: $libbld"
echo "build with libz-libzstd...: $wl"
echo "libzlib...................: $libzlib"
echo "libzhdr...................: $libzhdr"
echo "libzlink..................: $libzlink"

echo "DWARFTEST lock set at.....: " `date "+%Y-%m-%d %H:%M:%S"` >$dwbb
echo "Lock file content follows.:"
cat $dwbb

endian=L
CC=cc
which $CC >/dev/null
if [ $? -ne 0 ]
then
  # No native cc. Try gcc.
  CC=gcc
fi
$CC $testsrc/testendian.c -o testendian
if [ $? -eq 0 ]
then
  endian=`./testendian`
  if [ $? -ne 0 ]
  then
    echo "FAIL test host endianness.: Assume littleendian(L)"
    endian=L
  fi
else
  echo "FAIL compile endianness....: Assume littleendian(L)"
fi
export endian
echo "Host Endianness...........: $endian"

# In FreeBSD python2 &3 in /usr/local/bin, not /usr/bin
# shell func from BASEFUNCS.sh
setpythondirs
if [ $? -ne 0 ]
then
  echo "FAIL DWARFTEST.sh cannot find python? to use."
  echo "Giving up."
  exit 1
fi
echo "Python....................: $mypycom"
echo "Python dir in tests.......: $mypydir"

# Do the following two for address-sanitization.
# Not all tests will be run in that case.
# Some of the tests involve compilation and linking,
# so we need this here.
nlize=n
if [ x$NLIZE != 'xy' ]
then
  export NLIZE
  ASAN_OPTIONS=
  export ASAN_OPTIONS
  nlizeopt=
  echo "Using -fsanitize .........: no"
else
  ASAN_OPTIONS="allocator_may_return_null=1"
  nlize=y
  export ASAN_OPTIONS
  # Ensure we can use the opts.
  nlizeopt=`checkargs -fsanitize=address -fsanitize=leak  \
    -fsanitize-address-use-after-scope   \
    -fsanitize=undefined -fno-omit-frame-pointer`
  echo "Using -fsanitize..........: $nlizeopt"
fi
if [ "x$suppresstree" = "x--suppress-de-alloc-tree" ]
then
  echo "Suppress de_alloc_tree....: yes"
else
  echo "Suppress de_alloc_tree....: no"
  suppresstree=
fi
nonsharedopt=""
if [ $sharedlib = "sharedlib" ]
then
  # Ensure we get the test libdwarf.so.0 .
  #set -x
  export LD_LIBRARY_PATH="$bldtest:$LD_LIBRARY_PATH"
  #set +x
elif [ $sharedlib = "n" ]
then
  nonsharedopt="-DLIBDWARF_STATIC"
fi
# Only suppress anything if we find the diffs are so
# big that some machines or VMs will not complete
# handling the really big diffs in a sensible time.
suppressbigdiffs=n
if [ x$SUPPRESSBIGDIFFS = "xy" ]
then
  suppressbigdiffs=y
  echo "suppress big diffs........: yes"
else
  echo "suppress big diffs........: no"
fi
#for filediff() when suppressbigdiffs=y
#31457280 = 30MiB = 30*1024*1024
maxdiffile=31457280

# Speeds up diff on big files with small differences.
echo a >$bldtest/junkadwtests
echo a >$bldtest/junkbdwtests
diffopt=""
diff --speed-large-files $bldtest/junkadwtests $bldtest/junkbdwtests 2>/dev/null
if [ $? -ne 0 ]
then
  #  --speed-large-files is not supported.
  echo "speed up big diffs........: no"
else
  diffopt="--speed-large-files $diffopt"
  echo "speed up big diffs........: yes"
fi
# To run on Windows we must deal with the <cr> ending of lines
diff --strip-trailing-cr $bldtest/junkadwtests $bldtest/junkbdwtests 2>/dev/null
if [ $? -ne 0 ]
then
  #  --strip-trailing-cr is not supported.
  echo "strip trailing cr.........: no"
else
  diffopt="--strip-trailing-cr $diffopt"
  echo "strip trailing cr.........: yes"
  echo "diffopt=\"$diffopt\"" >> BASEFILES.sh
fi
  echo "dd printf checks?.........: $PRINTFFMT"

if [ "x$VALGRIND" = "xy" ]
then
  echo "valgrind?.................: $VALGRIND"
else
  echo "valgrind?.................: (no)"
fi

rm $bldtest/junkadwtests $bldtest/junkbdwtests

myhost=`hostname`
echo   "hostname..................: $myhost"
goodcount=0
failcount=0
skipcount=0
valgrindcount=0
valgrinderrcount=0
bldgoodcount=0

top_builddir=$bldtest
echo   "test code source..........: $testsrc"
d1=./dwarfdump.O
d2=./dwarfdump
echo   "old is....................: $d1"
echo   "new is....................: $d2"
if [ x$sharedlib = "xsharedlib" ]
then
  dwlib=$bldtest/libdwarf.so.0
else
  dwlib=$bldtest/libdwarf.a
fi
dwinc=$codedir/libdwarf

baseopts='-b -f -F -i -l -ls -m  -p -r -s -ta -tf -tv -y -w  -N '
kopts="-ka -kb -kc -ke -kf -kF -kg  -kl -km -kM -kn -kr -kR -ks -kS -kt -kx -ky -kxe -kD -kG -ku -kw "

# These accumulate times so we can print actual dwarfdump
# user, sys, clock times at the end (see usertime.py).
. $testsrc/RUNTIMEFILES.sh
if [ x$wrtimeo != "x" ]
then
  echo "/usr/bin/time timing......: yes"
else
  echo "/usr/bin/time timing......: no"
fi
rm -f $otimeout
rm -f $ntimeout
chkresbld () {
  if [ $1 -eq 0 ]
  then
    bldgoodcount=`expr $bldgoodcount + 1`
  else
    echo "FAIL $2"
    failcount=`expr $failcount + 1`
  fi
}
chkres () {
  if [ $1 -eq 0 ]
  then
    goodcount=`expr $goodcount + 1`
  else
    echo "FAIL $2"
    failcount=`expr $failcount + 1`
  fi
}
chkresn () {
  if [ $1 -eq 0 ]
  then
    goodcount=`expr $goodcount + $3`
  else
    echo "FAIL  $2"
    failcount=`expr $failcount + $3`
  fi
}

#ia32/libpt_linux_x86_r.so.1  -f -F runs too long.

filepaths='moshe/hello
polar/hello.o
kernel/test.ko
jborg/simple
diederen/hello
google1/crash-c7e04f405a39f3e92edb56c28180531b9b8211bd
google1/crash-d8d1ea593642a46c57d50e6923bc02c1bbbec54d
ckdev/modulewithdwarf.ko
sleicasper/bufferoverflow
gilmore/a.out
enciso8/test-clang-dw5.o
enciso8/test-clang-wpieb-dw5.o
sarubbo-7/4.crashes.bin
sarubbo-5/1.crashes.bin
jacobs/test.o
diederen2/pc_dwarf_bad_attributes.elf
diederen2/pc_dwarf_bad_sibling2.elf
diederen2/pc_dwarf_bad_reloc_empty_debug_info.elf
diederen2/pc_dwarf_bad_sibling.elf
diederen2/pc_dwarf_bad_reloc_section_link.elf
diederen2/pc_dwarf_bad_string_offset.elf
diederen3/pc_dwarf_bad_name3.elf
diederen4/mips_dwarf_bad_interr_30368.elf
diederen5/id-000004-sig-06-src-000503-001305-op-splice-rep-2
diederen5/id-000010-sig-06-src-000503-001305-op-splice-rep-2
diederen5/id-000017-sig-06-src-000034-op-havoc-rep-8
diederen5/id-000075-sig-06-src-000517-op-havoc-rep-16
diederen5/id-000256-sig-06-src-001757-001290-op-splice-rep-16
diederen5/id-000347-sig-06-src-001923-op-havoc-rep-2
diederen5/id-000468-sig-06-src-002858-op-havoc-rep-16
diederen6/implicit_const_example.so
moya-loc/loclists
moya-loc/loclists.dwo
moya-loc/loclists2.dwo
moya-loc/loclists.dwp
moya-loc/main.dwo
emre3/a.out.dwp
emre3/foo.dwo
emre3/main.dwo
emre3/foo.o
emre3/main.o
hughes/libkrb5support.so.0.1.debug
shopov1/main.exe
shopov2/clang-9.0.0-test-dwarf5.elf
shopov3/decltest-dw4.o
shopov3/decltest-dw5.o
k10m/main_knc.o
pasztory/a.out64
relocerr64/tls32.o
relocerr64/tls64.o
relocerr64/armv5tel-32-tls.o
relocerr64/ia64-64-tls.o
relocerr64/mips-32-tls.o
relocerr64/ppc64-32-tls.o
relocerr64/ppc64-64-tls.o
relocerr64/s390x-32-tls.o
relocerr64/s390x-64-tls.o
relocerr64/sh4a-32-tls.o
relocerr64/sparc64-32-tls.o
relocerr64/sparc64-64-tls.o
enciso6/ranges.o
moshe/a.out.t
marinescu/stream.o.test
simonian/test-gcc-4.3.0
simonian/test-gcc-4.5.1
enciso3/test.o
x86/dwarfdumpv4.3
allen1/todd-allen-gcc-4.4.4-bin.exe
wynn/unoptimised.axf
shihhuangti/tcombined.o
kartashev/combined.o
macinfo/a.out3.4
macinfo/a.out4.3
arm/armcc-test-dwarf2
arm/armcc-test-dwarf3
sun/sunelf1
val_expr/libpthread-2.5.so
ia64/hxdump.ia64
ia64/mytry.ia64
ia32/mytry.ia32
ia32/libc.so.6
testcase/testcase
test-eh/eh-frame.386
test-eh/test-eh.386
mutatee/test1.mutatee_gcc.exe
cristi2/libpthread-2.4.so
ia32/preloadable_libintl.so
ia32/libpfm.so.3
modula2/write-fixed
liu/divisionbyzero02.elf
liu/divisionbyzero.elf
liu/free_invalid_address.elf
liu/heapoverflow01b.elf
liu/heapoverflow01.elf
liu/HeapOverflow0513.elf
liu/infinitloop.elf
liu/null01.elf
liu/null02.elf
liu/NULLdereference0522.elf
liu/OOB0505_01.elf
liu/OOB0505_02_02.elf
liu/OOB0505_02.elf
liu/OOB0517_01.elf
liu/OOB0517_03.elf
liu/OOB_read3_02.elf
liu/OOB_read3.elf
liu/OOB_READ0519.elf
liu/outofbound01.elf
liu/outofboundread2.elf
liu/outofboundread.elf
irix64/libc.so
irixn32/libc.so
irixn32/dwarfdump
dwgenb/dwarfgen
dwarf4/dd2g4.5dwarf-4
'
echo "Checkwithlibz      : $withlibz"
echo "Checkskipdecompress: $skipdecompress"
if [ "x$withlibz" = "xno" -o "x$skipdecompress" = "xy" ]
then
     echo "=====SKIP klingler navarro liu skip count 770 compression"
     skipcount=`expr $skipcount +  770` 
else
     echo "=====DO klinkler navarro liu libz tests"
     filepaths="klingler/dwarfgen-zdebug klingler/test-with-zdebug $filepaths"
     filepaths="navarro/compressed_aranges_test $filepaths"
     filepaths="liu/NULLderefer0505_01.elf $filepaths"
     filepaths="dwarf4/ddg4.5dwarf-4 $filepaths"
fi

#echo "=====SKIP sarubbo-6/1.crashes.bin and sarubbo-4/libresolv.a because archives not handled"

stripx() {
    #x=`echo $* | sed -e 's/-g//'`
    x=`echo $*`
    echo $x
}
# Avoid spurious differences because of the names of the
# various dwarfdump versions being tested.
# dwarfdump.c fixes the dwarfdump.O to be dwarfdump now.
# Running sed on all the files took 50 minutes
# so getting rid of the sed is very worthwhile.
unifyddname () {
  touch $1
  mv $1 $2
  if [ $? -ne 0 ]
  then
    echo "mv $1 $2  FAIL in unifyddname"
  fi
}
# For stderr we need to fix the name due to getopt.c
unifyddnameb () {
  nstart=$1
  nend=$2
  touch $nstart
  sed -e 'sx.\/dwarfdump.Ox.\/dwarfdumpx' < $nstart > $nend
}

# Some files to be diff'd can be 5+GB.
# Files which are too big will often take hours before
# finishing diff.
# At least on the freebsd VMs where I test.
# With the native host OS it is usually not necessary to
# set suppressbigdiffs=y  .

filediff() {
t1=$1
t2=$2
shift ; shift
if [ "$suppressbigdiffs" = "y" ]
then
  if [ ! -f $t2 -a ! -f $t1 ]
  then
    echo "PASS no file $t1 , no file $t2"
    return 0
  fi
  if [ ! -f $t2 -o ! -f $t1 ]
  then
    if [ ! -f $t1 ]
    then
      echo "Filediff $t1 $t2 no file $t1"
      cat $t2
    else
      echo "Filediff $t1 $t2 no file $t2"
      cat $t1
    fi
    return 1
  fi
  # An exit code of 1 means a big diff. Exit of 0 means reasonable size.
  $mypycom $testsrc/$mypydir/checksize.py $maxdiffile $t1  $t2
  
  # on msys2 it's good to see the real diff.
  if [ $? -eq 0 -o "$platform" = "msys2"  ]
  then
    # on msys2 we must diff: cmp will fail .
    x="diff $diffopt $t1 $t2"
    echo "$x"
    $x
    if [ $? -eq 0 ]
    then
      #echo "pass diff Identical "  $*
      return 0
    else
      echo "size" `wc $t1`
      echo "size" `wc $t2`
      echo "fail diff Differ "  $*
      return 1
    fi
  else
    # too big to diff
    echo "TOOBIGDIFF. do cmp"
    cmp $t1 $t2
    if [ $? -eq 0 ]
    then
      #echo "pass cmp Identical "  $*
      return 0
    else
      echo "fail cmp Differ "  $*
      return 1
    fi
  fi
else
  diff $diffopt $t1 $t2
  if [ $? -eq 0 ]
  then
    #echo "pass diff Identical "  $*
    return 0
  else
    echo "fail diff Differ $t1 $t2 "  $*
    diff $t1 $t2
    return 1
  fi
fi
echo "FAIL: filediff() shell function impossible error"
return 0
}

# $suppresstree value added here .
# Added a sed command transforming source path
# to ..std.. so
# path differences do not cause irrelevant fails.
# If the letter : (see the sed command)
# Also do sed to remove /home/davea/dwarf/code built in
# to DWARF data
# is in the path the sed will fail utterly.
runsingle () {
  base=$1
  exe=$2
  shift
  shift
  args=$*
  based=baselines
  rm -f tmp2erra
  touch tmp2erra
  rm -f junksingle.$base junksingle2.$base junksingle3.$base
  touch junksingle.$base junksingle2.$base junksingle3.$base
  totalct=`expr $goodcount + $failcount + $skipcount + 1`
  pctstring=`$mypycom $testsrc/$mypydir/showpct.py $totalct`
  if [ "$args" = "" ]
  then
    echo  "=====STARTsingle Pct $pctstring $base $exe good=$goodcount skip=$skipcount fail=$failcount"
  else
    echo  "=====STARTsingle Pct $pctstring $base $exe $args good=$goodcount skip=$skipcount fail=$failcount"
  fi
  echo  "=====STATSsingle Pct $pctstring ct: $totalct"
  echo "new start " `date "+%Y-%m-%d %H:%M:%S"`
  if [ "x$VALGRIND" = "xy" ]
  then
    echo "valgrind .vgopts. $exe $suppresstree $args"
    valgrind -q --leak-check=full --show-leak-kinds=all\
       --error-exitcode=7 $exe $suppresstree \
       $args 1>junksingle.$base 2>tmp2erra
    cat tmp2erra >> junksingle.$base
    if [ $? -eq 7 ]
    then
      echo "valgrind exit code 7, valgrinderrcount:$valgrinderrcount"
      echo "Doing valgrind $* $args"
    fi
    valgrindcount=`expr $valgrindcount + 1`
  else
    rsrun="$exe $suppresstree $args"
    echo "run: $rsrun"
    if [ x$wrtimeo != "x" ]
    then
      $wrtimeo $rsrun  1> junksingle.$base 2>tmp2erra
    else
      $rsrun 1> junksingle.$base 2>tmp2erra
    fi
    cat tmp2erra >> junksingle.$base
  fi
  modpath=n
  # Fix up names to eliminate owner in path.
  # Checking return code from sed is not productive.
  if [ "x$exe" = "x./dwdebuglink" -o "x$exe" = "x./dwdebuglink.exe" ]
  then
     modpath=y
  fi
  if [ "x$exe" = "x./findfuncbypc" -o "x$exe" = "x./findfuncbypc.exe" ]
  then
     modpath=y
  fi
  if [ $modpath = "y" ]
  then
    canp=$testsrc/scripts/dirtostd.py
    # This is local transform, actual $HOME
    xstd="$HOME/dwarf/code"
    #echo "debug:==== baseline base $testsrc/baselines/$base" 
    #cat $testsrc/baselines/$base
    #echo "debug:==== output of app junksingle.$base "
    #cat junksingle.$base
    $canp junksingle.$base $xstd >junksingle3a.$base
    r=$?
    # This is transform base on original compile of object.
    chkresbld $r "FAIL $canp a"
    xstd="/home/davea/dwarf/code"
    #echo "debug:==== output of first transform junksingle3a.$base $xstd  "
    #cat junksingle3a.$base
    $canp junksingle3a.$base $xstd >junksingle3.$base
    r=$?
    #echo "debug:==== final output new junksingle3.$base $xstd " 
    #cat junksingle3.$base
    chkresbld $r "FAIL $canp b"
  else
    echo "debug: skip canonicalpath.py"
    cp junksingle.$base junksingle3.$base
    chkresbld $? "FAIL cp junksingle.$base to junksingle3"
  fi
  allgood=y
  if [ ! -f $testsrc/baselines/$base ]
  then
    # first time setup.
    echo junk > $testsrc/baselines/$base
    echo "First time setup $base"
    allgood=n
  fi
  filediff $testsrc/baselines/$base junksingle3.$base $exe $args
  r=$?
  if [ $r -ne 0 ]
  then
    #echo "FAIL diff $base junksingle3.$base"
    wc $testsrc/baselines/$base
    wc junksingle3.$base
    allgood=n
    echo "To update mv $bldtest/junksingle3.$base $testsrc/baselines/$base"
  fi
  if [ $allgood = "y" ]
  then
    goodcount=`expr $goodcount + 1`
  else
    echo "FAIL  $exe $args"
    failcount=`expr $failcount + 1`
  fi
  echo "new done " `date "+%Y-%m-%d %H:%M:%S"`
}

runversiontest () {
    dw=$1
    shift
    arg=$*
    rm -f junk.versiontest
    totalct=`expr $goodcount + $failcount + $skipcount + 1`
    pctstring=`$mypycom $testsrc/$mypydir/showpct.py $totalct`
    echo  "=====START Pct $pctstring $arg good=$goodcount skip=$skipcount fail=$failcount"
    echo  "=====STATS Pct $pctstring ct: $totalct"
    echo "new start " `date "+%Y-%m-%d %H:%M:%S"`
    $dw $arg >junk.versiontest
    l=`wc -l < junk.versiontest`
    if [ $l -ne 1 ]
    then
      echo "FAIL output version test should be one line: $dw $* "
      failcount=`expr $failcount + 1`
      echo "new done " `date "+%Y-%m-%d %H:%M:%S"`
      return
    else
      grep libdwarf junk.versiontest
      if [ $? -ne 0 ]
      then
        echo "FAIL output version test content "
        failcount=`expr $failcount + 1`
        echo "new done " `date "+%Y-%m-%d %H:%M:%S"`
        return
      fi
      grep dwarfdump < junk.versiontest >/dev/null
      if [ $? -ne 0 ]
      then
        echo "FAIL output version test content "
        failcount=`expr $failcount + 1`
        echo "new done " `date "+%Y-%m-%d %H:%M:%S"`
        return
      fi
      grep '\[' junk.versiontest >/dev/null
      if [ $? -ne 0 ]
      then
        echo "FAIL output version test content "
        failcount=`expr $failcount + 1`
        echo "new done " `date "+%Y-%m-%d %H:%M:%S"`
        return
      fi
      grep '\]' junk.versiontest >/dev/null
      if [ $? -ne 0 ]
      then
        echo "FAIL output version test content "
        failcount=`expr $failcount + 1`
        echo "new done " `date "+%Y-%m-%d %H:%M:%S"`
        return
      fi
    fi
    echo "new done " `date "+%Y-%m-%d %H:%M:%S"`
    echo "PASS output version test content "
    goodcount=`expr $goodcount + 1`
}



runtest () {
    olddw=$1
    newdw=$2
    targ=$testsrc/$3
    shift
    shift
    shift
    allgood="y"
    if [ $singleonly = "y" ]
    then
        return
    fi
    #  Add 1 to show our summary number. We have not yet
    #  counted it as a good or a fail.
    totalct=`expr $goodcount + $failcount + $skipcount + 1`
    pctstring=`$mypycom $testsrc/$mypydir/showpct.py $totalct`
    echo  "=====START Pct $pctstring $* $targ good=$goodcount skip=$skipcount fail=$failcount"
    echo  "=====STATS Pct $pctstring ct: $totalct"
    rm -f core
    rm -f tmp1o tmp2n tmp3
    rm -f tmp1err tmp2err tmp3err
    rm -f tmp1erra  tmp2erra
    rm -f tmp1errb tmp1errc
    rm -f tmp1berr tmp2berr
    # testOfile OFn OF* are targets of dwarfdump -O file=testOfile
    rm -f testOfile OFn  OFo1 OFn1
    rm -f OFo2 OFn2
    rm -f OFo3 OFn3

    #=======old
    echo "old start " `date "+%Y-%m-%d %H:%M:%S"`
    tmplist="$*"
    echo "======" $tmplist $targ >> $otimeout
    if [ x$wrtimeo != "x" ]
    then
          $wrtimeo $olddw $fsu $tmplist  $targ 1>tmp1a 2>tmp1erra
    else
          $olddw $fsu $tmplist  $targ 1>tmp1a 2>tmp1erra
    fi
    unifyddname tmp1a tmp1o
    unifyddnameb tmp1erra tmp1err
    grep -v Usage   tmp1err >>tmp1o
    if [ -f core ]
    then
           echo "corefile in  $olddw '(old dwarfdump)'"
           rm core
    fi
    echo "old done " `date "+%Y-%m-%d %H:%M:%S"`
    #=======old end
    # =======  Run -O file-path
    # To deal with the -O file=path naming dwarfdump output.
    if [ -f testOfile ]
    then
      echo "Test(old)  -O file=testOfile" `date "+%Y-%m-%d %H:%M:%S"`
      unifyddname testOfile OFo1
      grep -v Usage   OFo1 >OFo2
      # Delete date on first line
      sed '1d' OFo2 >OFo3
    fi
    # We will now build the other file=testOfile if such is involved
    rm -f testOfile
    # =======  END -O file-path
    #=======new
    if [ -f testOfile ]
    then
      echo "new start " `date "+%Y-%m-%d %H:%M:%S"`
    fi
    echo "======" $tmplist $targ >> $ntimeout
    if [ x$VALGRIND = "xy" ]
    then
        #echo "valgrind -q --leak-check=full $newdw $suppresstree $* $targ"
        valgrind -q --leak-check=full --show-leak-kinds=all --error-exitcode=7 $newdw $fsu $suppresstree $* $targ 1>tmp2a 2>tmp2erra
        if [ $? -eq 7 ]
        then
          echo "valgrind exit code 7, valgrinderrcount:$valgrinderrcount"
          echo "Doing valgrind $* $targ"
          valgrinderrcount=`expr $valgrinderrcount + 1`
        fi
        valgrindcount=`expr $valgrindcount + 1`
    else
      if [ "x$wrtimen" != "x" ]
      then
        $wrtimen $newdw $suppresstree $fsu $* $targ 1>tmp2a 2>tmp2erra
      else
        $newdw $suppresstree $fsu $* $targ 1>tmp2a 2>tmp2erra
      fi
    fi
    tesb=tmp2aesb
    grep ESBERR tmp2a >$tesb
    if [ $? -eq 0 ]
    then
      #This will record any ESBERR instances.
      cat $tesb >>tmp2a
    fi
    #echo "new done " `date "+%Y-%m-%d %H:%M:%S"`
    # No need to unify for new dd name.
    unifyddname tmp2a tmp3
    unifyddnameb tmp2erra tmp2err
    grep -v Usage  tmp2err >>tmp3
    if [ -f core ]
    then
      echo corefile in  $newdw
      exit 1
    fi
    #=======new done
    #=======Now test -O file=path
    #echo "counts in tmp3"
    if [ -f testOfile ]
    then
      # testing -O file=path
      echo "Test(new)  -O file=testOfile"
      unifyddname testOfile OFn1
      grep -v Usage OFn1 >OFn2
      # Delete date on first line
      sed '1d' OFn2 >OFn3
    fi
    if [ -f OFn3 -o -f OFo3 ]
    then
      echo "Test -O file=testOfile"
      # testing -O file=path
      touch OFn3 OFo3
      filediff OFo3  OFn3 $*  $targ
      if [ $? -ne 0 ]
      then
        allgood=n
        wc OFo3
        wc OFn3
        echo "FAIL -O file=testOfile"  $* $targ
      fi
    fi
    # ===========Now do final diff
    #echo "counts in tmp1o (old) tmp3 (new)"
    filediff tmp1o tmp3 $* $targ
    if [ $? -ne 0 ]
    then
      echo 'Filediff tmp1o tmp2 (final diff)'
      wc tmp1o
      wc tmp3
      allgood=n
    fi
    if [ $allgood = "y" ]
    then
      goodcount=`expr $goodcount + 1`
    else
      echo "FAIL  $* $targ"
      failcount=`expr $failcount + 1`
    fi
    echo "new done " `date "+%Y-%m-%d %H:%M:%S"`
    rm -f core
    rm -f tmp1o tmp2n tmp3
    rm -f tmp1erra  tmp2aesb  tmp2erra
    rm -f tmp1err tmp2err tmp3err
    rm -f tmp1errb tmp1errc
    rm -f tmp1berr tmp2berr
    rm -f testOfile OFn  OFo1 OFn1
    rm -f OFo2 OFn2
    rm -f OFo3 OFn3
}
# end 'runtest'

echo "=============BEGIN THE TESTS==============="
echo  "=====BLOCK individual tests and runtest.sh tests"
# simple BUILDS
simpleexe='
test_harmless
test_language_version
test_simple_libfuncs
test_sectionnames'

for f in $simpleexe
do
  echo "====BUILD $f"
  x="$CC -I$codedir/src/lib/libdwarf $libzhdr -I$libbld \
     -I$libbld/libdwarf $nonsharedopt\
     -gdwarf $nlizeopt $testsrc/${f}.c \
     -o $f  $dwlib $libzlib $libzlink"
  echo "$x"
  $x
  r=$?
  chkresbld $r "compile of ${f}.c failed" 
done


# BUILDS
fuzzexe='
fuzz_aranges
fuzz_crc
fuzz_crc_32
fuzz_debug_addr_access
fuzz_debuglink
fuzz_debug_str
fuzz_die_cu
fuzz_die_cu_attrs
fuzz_die_cu_attrs_loclist
fuzz_die_cu_e
fuzz_die_cu_e_print
fuzz_die_cu_info1
fuzz_die_cu_offset
fuzz_die_cu_print
fuzz_dnames
fuzz_findfuncbypc
fuzz_gdbindex
fuzz_globals
fuzz_gnu_index
fuzz_init_b
fuzz_init_binary
fuzz_init_path
fuzz_macro_dwarf4
fuzz_macro_dwarf5
fuzz_rng
fuzz_set_frame_all
fuzz_showsectgrp
fuzz_simplereader_tu
fuzz_srcfiles
fuzz_stack_frame_access
fuzz_str_offsets
fuzz_tie
fuzz_xuindex'

# Do not do -Wall here ever.
for f in $fuzzexe
do
  echo "====BUILD $f"
  # always force simple executable path report with -DDWREGRESSIONTEMP
  x="$CC -DDWREGRESSIONTEMP -I$codedir/src/lib/libdwarf -I$libbld \
     -I$libbld/libdwarf $libzhdr $nonsharedopt \
     -gdwarf $nlizeopt $testsrc/testbuildfuzz.c \
     $codedir/fuzz/${f}.c \
     -o $f  $dwlib $libzlib $libzlink"
  echo "$x"
  $x
  r=$?
  chkresbld $r "compile of ${f}.c failed"
done

echo "=====BUILD  dwnames_checks/dwnames_all.c into dwnames_all"
   x="$CC -DDWREGRESSIONTEMP $warn -I$codedir/src/lib/libdwarf $libzhdr -I$libbld \
     -I$libbld/libdwarf $nonsharedopt \
     -gdwarf $nlizeopt $testsrc/dwnames_checks/dwnames_all.c \
     -o dwnames_all $dwlib $libzlib $libzlink"
   echo "$x"
   $x
   r=$?
   chkresbld $r 'check dwnames_all-error compile dwnames_all.c failed'

# frame1 is a directory name, hence the build -o frame1/frame1
echo "=====BUILD  dwarfexample/frame1.c into frame1/frame1 "
  mklocal frame1
  x="$CC $warn -I$codedir/src/lib/libdwarf $libzhdr -I$libbld \
    -I$libbld/libdwarf  $nonsharedopt \
    -gdwarf $nlizeopt \
    $codedir/src/bin/dwarfexample/frame1.c \
    -o frame1 $dwlib $libzlib $libzlink"
  echo "$x"
  $x
  r=$?
  chkresbld $r 'check frame1-error compile dwarfexample/frame1.c failed'
  cd ..

echo "=====BUILD  dwarfexample/jitreader.c "
  x="$CC $warn -I$codedir/src/lib/libdwarf $libzhdr -I$libbld \
     -I$libbld/libdwarf  $nonsharedopt \
     -gdwarf $nlizeopt $codedir/src/bin/dwarfexample/jitreader.c \
     -o jitreader $dwlib $libzlib $libzlink"
  echo "$x"
  $x
  r=$?
  chkresbld $r 'check jitreader compile dwarfexample/jitreader.c failed'

echo "=====BUILD  $testsrc/examplechecks/test_ranges.c "
  x="$CC $warn -I$codedir/src/lib/libdwarf -I$testsrc/examplechecks \
     $libzhdr -I$libbld \
     -I$libbld/libdwarf  $nonsharedopt \
     -gdwarf $nlizeopt $testsrc/examplechecks/test_ranges.c \
     $codedir/doc/checkexamples.c \
     -o test_ranges  $dwlib $libzlib $libzlink"
  echo "$x"
  $x
  r=$?
  chkresbld $r 'check examplechecs/test_ranges.c compile failed'

echo "=====BUILD  dwarfexample/dwdebuglink.c "
  x="$CC $warn -I$codedir/src/lib/libdwarf $libzhdr -I$libbld \
     -I$libbld/libdwarf  $nonsharedopt \
     -gdwarf $nlizeopt $codedir/src/bin/dwarfexample/dwdebuglink.c \
     -o dwdebuglink $dwlib $libzlib $libzlink"
  echo "$x"
  $x
  r=$?
  chkresbld $r 'check dwdebuglink compile dwarfexample/dwdebuglink.c failed'

echo "=====START  $testsrc/testfindfuncbypc/ tests good=$goodcount skip=$skipcount fail=$failcount"
  mklocal testfindfuncbypc
    sh $testsrc/testfindfuncbypc/runtest.sh
    chkres $? 'check  of testfindfuncbypc failed'
  cd ..
# the special (badly written) testcases here
# return 0 even if there is a DWARF ERROR reported
# (but if the required arg omitted, return 1).
echo "=====BUILD  $testsrc/filelist/localfuzz_init_path"
  mklocal filelist
  x="$CC $warn -I$codedir/src/lib/libdwarf -I$libbld \
     -I$libbld/libdwarf $libzhdr $nonsharedopt \
     -gdwarf $nlizeopt $testsrc/filelist/localfuzz_init_path.c \
     -o localfuzz_init_path $dwlib $libzlib $libzlink"
  echo "$x"
  $x
  chkresbld $? "check -error compiling $testsrc/filelist/localfuzz_init_path.c failed"
echo "=====BUILD  $testsrc/filelist/localfuzz_init_binary"
  x="$CC $warn -I$codedir/src/lib/libdwarf $libzhdr -I$libbld \
     -I$libbld/libdwarf $lihbzstdhdrdir $nonsharedopt \
     -gdwarf  $nlizeopt $testsrc/filelist/localfuzz_init_binary.c \
     -o localfuzz_init_binary $dwlib $libzlib $libzlink"
  echo "$x"
  $x
  chkresbld $? "check error compiled $testsrc/filelist/localfuzz_init_binary.c failed"
  cd ..
if [ "x$endian" = "xB" ]
then
  echo "====SKIP ossfuzz69641 BEendian message says error 332, not 331 (1)"
  skipcount=`expr $skipcount +  1 `
else
  runsingle ossfuzz69641.base ./fuzz_die_cu_attrs_loclist  --testobj=$testsrc/ossfuzz69641/fuzz_die_cu_attrs_loclist-6271271030030336
fi

runsingle ossfuzz447805105.base ./fuzz_showsectgrp --suppress-de-alloc-tree --testobj=$testsrc/ossfuzz447805105/fuzz_showsectgrp-5078066159484928 

runsingle ossfuzz447421051.base ./fuzz_crc_32 --suppress-de-alloc-tree --testobj=$testsrc/ossfuzz447421051/fuzz_crc_32-6747299494821888

runsingle ossfuzz447586815.base ./fuzz_die_cu_e --suppress-de-alloc-tree --testobj=$testsrc/ossfuzz447586815/fuzz_die_cu_e-6725653933391872

runsingle ossfuzz447600209.base ./fuzz_debug_str --suppress-de-alloc-tree --testobj=$testsrc/ossfuzz447600209/fuzz_debug_str-6405288967340032

runsingle ossfuzz447797928.base ./fuzz_init_b --suppress-de-alloc-tree --testobj=$testsrc/ossfuzz447797928/fuzz_init_b-6276293315592

runsingle ossfuzz447719692.base ./fuzz_showsectgrp --suppress-de-alloc-tree --testobj=$testsrc/ossfuzz447719692/fuzz_die_cu_info1-5983735611981824
runsingle ossfuzz447686887.base ./fuzz_showsectgrp --suppress-de-alloc-tree --testobj=$testsrc/ossfuzz447686887/fuzz_dnames-5657680116252672

#447805105       
#fuzz_showsectgrp-5078066159484928
runsingle ossfuzz447805105.base ./fuzz_showsectgrp --suppress-de-alloc-tree --testobj=$testsrc/ossfuzz447805105/fuzz_showsectgrp-5078066159484928


runsingle ossfuzz447702256.base ./fuzz_init_binary --suppress-de-alloc-tree --testobj=$testsrc/ossfuzz447702256/fuzz_init_binary-4759449983320064

runsingle ossfuzz447629673.base ./fuzz_die_cu_print --suppress-de-alloc-tree --testobj=$testsrc/ossfuzz447629673/fuzz_die_cu_print-4591618901737472

runsingle ossfuzz447580449.base ./fuzz_debuglink --suppress-de-alloc-tree --testobj=$testsrc/ossfuzz447580449/fuzz_debuglink-469140951407001

runsingle ossfuzz447580450.base ./fuzz_globals --suppress-de-alloc-tree --testobj=$testsrc/ossfuzz447580450/fuzz_globals-4845056734593024

runsingle ossfuzz447396726.base ./fuzz_xuindex --suppress-de-alloc-tree --testobj=$testsrc/ossfuzz447396726/fuzz_xuindex-4824455521304576

runsingle ossfuzz447421051.base ./fuzz_crc_32 --suppress-de-alloc-tree --testobj=$testsrc/ossfuzz447421051/fuzz_crc_32-6747299494821888

runsingle ossfuzz447445674.base ./fuzz_str_offsets --suppress-de-alloc-tree --testobj=$testsrc/ossfuzz447445674/fuzz_str_offsets-4859796391264256

runsingle ossfuzz447457197.base ./fuzz_tie  --suppress-de-alloc-tree --testobj=$testsrc/ossfuzz447457197/fuzz_tie-4785079261134848

# see macho-kagstrom/README
runsingle macho-kagstrom.base ./dwarfdump -a -M $testsrc/macho-kagstrom/a

runsingle ossfuzz446831123.base ./fuzz_rng --suppress-de-alloc-tree --testobj=$testsrc/ossfuzz446831123/fuzz_rng-6527551318327296
runsingle ossfuzz446735540.base ./fuzz_dnames --suppress-de-alloc-tree --testobj=$testsrc/ossfuzz446735540/fuzz_dnames-5931269398790144 
runsingle ossfuzz446856589.base ./fuzz_tie --suppress-de-alloc-tree --testobj=$testsrc/ossfuzz446856589/fuzz_tie-5831785406857216
runsingle ossfuzz446746574.base ./fuzz_aranges --suppress-de-alloc-tree --testobj=$testsrc/ossfuzz446746574/fuzz_aranges-4698786724380672
runsingle ossfuzz446781574.base ./fuzz_gdbindex --suppress-de-alloc-tree --testobj=$testsrc/ossfuzz446781574/fuzz_gdbindex-4712655307997184
runsingle ossfuzz446726228.base ./fuzz_debuglink --suppress-de-alloc-tree --testobj=$testsrc/ossfuzz446726228/fuzz_debuglink-4854619680604160
runsingle ossfuzz446726229.base ./fuzz_globals --suppress-de-alloc-tree --testobj=$testsrc/ossfuzz446726229/fuzz_globals-5387186766938112

# A macos segment with no sections was handled inappropriately, hence
# complaints from -fscanitize , but now we just avoid doing 
# anything for an empty section list.
runsingle ossfuzz446356422.base ./fuzz_crc_32 --suppress-de-alloc-tree --testobj=$testsrc/ossfuzz446356422/fuzz_crc_32-4931308642172928

# Uses DWARF5 DW_FORM_line_strp which was not handled correctly, nor was FORM strx
# in the line table handled correctly.
runsingle macho-kagstrom-l.base ./dwarfdump -l -vvv $testsrc/macho-kagstrom/a

runsingle macho-kagstrom-srcfiles.base ./dwarfdump --print-all-srcfiles $testsrc/macho-kagstrom/a

runsingle frame1regs-2025-09-06.base frame1/frame1 --stop-at-fde-n=8 $testsrc/gsplitdwarf/frame1

runsingle frame1riskv-2025-09-06.base frame1/frame1 --stop-at-fde-n=8 $testsrc/frameriskv/fft

# Tests with dwarfgen --add-language-version (new July 2025)
#  --add-implicit-const --add-sun-func-offsets
# same test run later.  Drop this one
#echo "=====START   $testsrc/implicitconst sh runtest.sh good=$goodcount skip=$skipcount fail=$failcount"
#  mklocal implicitconst
#    sh $testsrc/implicitconst/runtest.sh
#    chkres $?  $testsrc/implicitconst/runtest.sh
#  cd ..

runsingle  ossfuzz437060549.base ./fuzz_globals  --testobj=$testsrc/ossfuzz437060549/fuzz_globals-4771320878661632

runsingle  ossfuzz394644267.base ./fuzz_macro_dwarf5  --testobj=$testsrc/ossfuzz394644267/fuzz_macro_dwarf5-5504709091983360

# Problematic as the testcase is really full of tailored junk. Nothing is running away, even though
# the test app is quite odd in some ways. Runs in around 7 seconds on my desktop, sanitized.
# Has no leaks. ossfuzz has not assigned a number to this as of Jan 14 2025.
runsingle  findfunc202501.base ./fuzz_findfuncbypc --testobj=$testsrc/findfunc202501/fuzz_findfuncbypc-5658339610001408

runsingle DW202412-011.base ./fuzz_die_cu_attrs --testobj=$testsrc/DW202412-011/fuzz_die_cu_attrs-5424995441901568

runsingle ossfuzz38574212.base ./fuzz_die_cu_print --testobj=$testsrc/ossfuzz385742125/fuzz_die_cu_print-5500979604160512

runsingle DW202412-009.base ./fuzz_die_cu_offset --testobj=$testsrc/DW202412-009/fuzz_init_path-5854698061496320

runsingle ossfuzz385466100.base ./fuzz_die_cu_offset --testobj=$testsrc/ossfuzz385466100/fuzz_die_cu_offset-6604029974609920 

runsingle ossfuzz42536144.base ./fuzz_die_cu_attrs_loclist --testobj=$testsrc/ossfuzz42536144/fuzz_die_cu_attrs_loclist-5906068650655744

runsingle ossfuzz383170474.base ./fuzz_globals --testobj=$testsrc/ossfuzz383170474/fuzz_globals-4515360770228224.fuzz

runsingle ossfuzz380108595.base ./fuzz_aranges --testobj=$testsrc/ossfuzz380108595/fuzz_aranges-5572243180027904

runsingle ossfuzz379159140.base ./fuzz_die_cu_print --testobj=$testsrc/ossfuzz379159140/fuzz_die_cu_print-5335984847257600

runsingle ossfuzz372754161.base ./fuzz_globals --testobj=$testsrc/ossfuzz372754161/fuzz_globals-6058837938864128

runsingle ossfuzz371659894.base ./fuzz_die_cu_attrs --testobj=$testsrc/ossfuzz371659894/fuzz_die_cu_attrs-6661686947282944

runsingle ossfuzz371721677.base ./fuzz_die_cu_e_print --testobj=$testsrc/ossfuzz371721677/fuzz_die_cu_e_print-4913953320271872

runsingle ossfuzz_42536144.base ./fuzz_die_cu_attrs_loclist --testobj=$testsrc/ossfuzz42536144/fuzz_die_cu_attrs_loclist-5906068650655744

runsingle ossfuzz_42538203.base ./fuzz_findfuncbypc  --testobj=$testsrc/ossfuzz42538203/fuzz_findfuncbypc-5117956621664256

# See github issue 266 and corexp/README
runsingle corexpdbg-crash ./dwarfdump --check-loc $testsrc/corexp/elf.dbg

runsingle ossfuzz70753.base   ./fuzz_die_cu_offset --testobj=$testsrc/ossfuzz70753/fuzz_die_cu_offset-6598270743281664
 
runsingle ossfuzz70763.base   ./fuzz_macro_dwarf5 --testobj=$testsrc/ossfuzz70763/fuzz_macro_dwarf5-5161075908083712

runsingle ossfuzz70721.base   ./fuzz_macro_dwarf5 --testobj=$testsrc/ossfuzz70721/fuzz_macro_dwarf5-4907954017468416

runsingle examplev-ranges-a.base   ./test_ranges --testobj=$testsrc/macuniv/demo

runsingle examplev-ranges-c.base   ./test_ranges --format-universalnumber=1 --testobj=$testsrc/macuniv/demo

runsingle examplev-ranges-b.base   ./test_ranges --testobj=$testsrc/emre4/test19_64_dbg

runsingle ossfuzz70277.base ./fuzz_die_cu_info1 --testobj=$testsrc/ossfuzz70277/fuzz_die_cu_info1-5380280051892224
runsingle ossfuzz70278.base ./fuzz_stack_frame_access --testobj=$testsrc/ossfuzz70278/fuzz_stack_frame_access-5419136084148224

runsingle ossfuzz70282.base ./fuzz_gnu_index --testobj=$testsrc/ossfuzz70282/fuzz_gnu_index-5974064515055616
runsingle ossfuzz70287.base ./fuzz_die_cu_e --testobj=$testsrc/ossfuzz70287/fuzz_die_cu_e-6493908297646080

runsingle ossfuzz70266.base ./fuzz_findfuncbypc --testobj=$testsrc/ossfuzz70266/fuzz_findfuncbypc-6093996460408832
runsingle ossfuzz70263.base ./fuzz_die_cu --testobj=$testsrc/ossfuzz70263/fuzz_die_cu-4960441042796544
runsingle ossfuzz70256.base ./fuzz_rng --testobj=$testsrc/ossfuzz70256/fuzz_rng-4838222916550656

runsingle ossfuzz70244.base ./fuzz_die_cu_attrs_loclist  --testobj=$testsrc/ossfuzz70244/fuzz_die_cu_attrs_loclist-4958134427254784

runsingle ossfuzz70246.base ./fuzz_macro_dwarf5  --testobj=$testsrc/ossfuzz70246/fuzz_macro_dwarf5-5128935898152960

runsingle ossfuzz69639.base ./fuzz_die_cu_offset  --testobj=$testsrc/ossfuzz69639/fuzz_die_cu_offset-6001910176350208

runsingle abudev-a.base ./dwarfdump --format-limit=10 --print-eh-frame --print-frame --print-info -v $testsrc/abudev/abudev_test.poc
runsingle ossfuzz67490.base ./fuzz_srcfiles  --testobj=$testsrc/ossfuzz67490/fuzz_srcfiles-5195296927711232


runsingle CelikCrash.base ./dwarfdump -a $testsrc/Celik/crash_elfio

runsingle hongg2024-02-18-m.base ./dwarfdump -a $testsrc/hongg2024-02-18/SIGSEGV-m.fuzz

runsingle hongg2024-02-16-a.base ./dwarfdump -a $testsrc/hongg2024-02-16/SIGABRT-a.fuzz
runsingle hongg2024-02-16-b.base ./dwarfdump -a $testsrc/hongg2024-02-16/SIGABRT-b.fuzz
runsingle hongg2024-02-16-c.base ./dwarfdump -a $testsrc/hongg2024-02-16/SIGABRT-c.fuzz
runsingle hongg2024-02-16-d.base ./dwarfdump -a $testsrc/hongg2024-02-16/SIGSEGV-d.fuzz
runsingle hongg2024-02-16-e.base ./dwarfdump -a $testsrc/hongg2024-02-16/SIGSEGV-e.fuzz

runsingle hongg2024-02-16-g.base ./dwarfdump -a $testsrc/hongg2024-02-16/SIGSEGV-g.fuzz
runsingle hongg2024-02-16-h.base ./dwarfdump -a $testsrc/hongg2024-02-16/SIGSEGV-h.fuzz
runsingle hongg2024-02-16-i.base ./dwarfdump -a $testsrc/hongg2024-02-16/SIGSEGV-i.fuzz
runsingle hongg2024-02-16-k.base ./dwarfdump -a $testsrc/hongg2024-02-16/SIGSEGV-k.fuzz

runsingle ossfuzz66646.base ./fuzz_findfuncbypc  --testobj=$testsrc/ossfuzz66646/fuzz_findfuncbypc-5178544143532032

runsingle marini_testcase.base ./fuzz_debug_str  --testobj=$testsrc/marini/testcase

# Elf e_shoff is zero, validate DW_DLV_NO_ENTRY returned.
runsingle zero-e_shoff.base ./dwarfdump -a $testsrc/helloz/zero-e_shoff.o
runsingle zero-e_shoff-i386.base ./dwarfdump -a $testsrc/helloz/zero-e_shoff-i386.o

# MacOS universalbinary
runsingle machinearchunivbin.base ./dwarfdump --print-machine-arch $testsrc/macuniv/demo 
runsingle machinearchunivbinun1.base ./dwarfdump --format-universalnumber=1 --print-machine-arch $testsrc/macuniv/demo 
runsingle machinearchunivbinv.base ./dwarfdump -v --print-machine-arch $testsrc/macuniv/demo 
#macos simple binary
runsingle machinearcmacho.base ./dwarfdump --print-machine-arch $testsrc/macho-kask/dwarfdump_32
runsingle machinearcmachov.base ./dwarfdump -v --print-machine-arch $testsrc/macho-kask/dwarfdump_32
# elf object
# skip debuglink on msys2
if [  $platform = "msys2" ]
then
  echo "====SKIP debuglink on msys2"
  skipcount=`expr $skipcount +  2 `
else
  runsingle machinearchi386.base ./dwarfdump --print-machine-arch $testsrc/debuglink/crc32
  runsingle machinearchi386v.base ./dwarfdump -v --print-machine-arch $testsrc/debuglink/crc32
fi
# PE object
runsingle machinearchpe.base ./dwarfdump --print-machine-arch $testsrc/pe1/kask-dwarfdump_64.exe
runsingle machinearchpev.base ./dwarfdump -v --print-machine-arch $testsrc/pe1/kask-dwarfdump_64.exe

if [  $platform = "msys2" ]
then
  echo "====SKIP debuglink on msys2"
  skipcount=`expr $skipcount +  2 `
else
  runsingle ossfuzz64496.base  ./fuzz_debuglink --testobj=$testsrc/ossfuzz64496/fuzz_debuglink-6154376638234624
  runsingle ossfuzz56452.base  ./fuzz_debuglink --testobj=$testsrc/ossfuzz56452/fuzz_debuglink-cs4231a-5927365017731072
fi

runsingle ossfuzz63024.base  ./fuzz_macro_dwarf4 --testobj=$testsrc/ossfuzz63024/fuzz_macro_dwarf4-4887579306360832

runsingle ossfuzz62943.base  ./fuzz_init_path --testobj=$testsrc/ossfuzz62943/fuzz_init_path-5486726493372416

runsingle ossfuzz62833.base  ./fuzz_set_frame_all --testobj=$testsrc/ossfuzz62833/fuzz_set_frame_all-4521858130903040
runsingle ossfuzz62834.base  ./fuzz_init_path --testobj=$testsrc/ossfuzz62834/fuzz_init_path-4573857635500032

runsingle ossfuzz62842.base  ./fuzz_findfuncbypc --testobj=$testsrc/ossfuzz62842/fuzz_findfuncbypc-4964619766333440.fuzz

# Testing Mach-O Universal Binary access
runsingle macuniv.base  ./dwarfdump -i -vvv $testsrc/macuniv/demo
runsingle macuniv0.base  ./dwarfdump -vvv --format-universalnumber=0 -i -vvv  $testsrc/macuniv/demo
runsingle macuniv1.base  ./dwarfdump -vvv --format-universalnumber=1 -i -vvv $testsrc/macuniv/demo

runsingle ossfuzz62547.base  ./fuzz_stack_frame_access --testobj=$testsrc/ossfuzz62547/fuzz_stack_frame_access-5263709637050368

runsingle ossfuzz59576.base  ./fuzz_set_frame_all --testobj=$testsrc/ossfuzz59576/fuzz_set_frame_all-5867083595120640

runsingle ossfuzz60506.base  ./fuzz_srcfiles --testobj=$testsrc/ossfuzz60506/fuzz_srcfiles-6494439909228544.fuzz

runsingle ossfuzz60090.base  ./fuzz_set_frame_all --testobj=$testsrc/ossfuzz60090/fuzz_set_frame_all-5757752673435648

runsingle ossfuzz59950.base  ./fuzz_set_frame_all --testobj=$testsrc/ossfuzz59950/fuzz_set_frame_all-6613067367317504

runsingle ossfuzz59775.base  ./fuzz_die_cu_attrs_loclist --testobj=$testsrc/ossfuzz59775/fuzz_die_cu_attrs_loclist-4504718844755968

runsingle ossfuzz59699.base  ./fuzz_stack_frame_access --testobj=$testsrc/ossfuzz59699/fuzz_stack_frame_access-6523659305746432

runsingle ossfuzz59602.base  ./fuzz_die_cu_attrs_loclist --testobj=$testsrc/ossfuzz59602/fuzz_die_cu_attrs_loclist-6737086749999104

runsingle ossfuzz59595.base  ./fuzz_set_frame_all --testobj=$testsrc/ossfuzz59595/fuzz_set_frame_all-5319697747542016

runsingle ossfuzz59519.base  ./fuzz_set_frame_all --testobj=$testsrc/ossfuzz59519/fuzz_set_frame_all-4670829255065600

runsingle ossfuzz59517.base  ./fuzz_set_frame_all --testobj=$testsrc/ossfuzz59517/fuzz_set_frame_all-5741671019839488

runsingle ossfuzz59478.base  ./fuzz_set_frame_all --testobj=$testsrc/ossfuzz59478/fuzz_set_frame_all-5300774457180160

runsingle ossfuzz56451.base  ./fuzz_dnames --testobj=$testsrc/ossfuzz56451/fuzz_dnames-4986494365597696

runsingle ossfuzz56443.base  ./fuzz_crc_32 --testobj=$testsrc/ossfuzz56443/fuzz_crc_32-4750941179215872
runsingle ossfuzz_crc.base  ./fuzz_crc --testobj=$testsrc/ossfuzz56443/fuzz_crc_testcase

runsingle ossfuzz56492.base  ./fuzz_macro_dwarf5 --testobj=$testsrc/ossfuzz56492/fuzz_macro_dwarf5-6497277180248064

runsingle ossfuzz56462.base  ./fuzz_set_frame_all --testobj=$testsrc/ossfuzz56462/fuzz_set_frame_all-5424385441005568

runsingle ossfuzz56474.base  ./fuzz_die_cu_attrs_loclist --testobj=$testsrc/ossfuzz56474/fuzz_die_cu_attrs_loclist-4719938125561856

runsingle ossfuzz56472.base  ./fuzz_simplereader_tu --testobj=$testsrc/ossfuzz56472/fuzz_simplereader_tu-6614412934119424

runsingle ossfuzz56446.base  ./fuzz_dnames --testobj=$testsrc/ossfuzz56446/fuzz_dnames-4784811358420992

runsingle ossfuzz59091.base  ./fuzz_macro_dwarf5 --testobj=$testsrc/ossfuzz59091/fuzz_macro_dwarf5-5135813562990592

runsingle ossfuzz58797.base  ./fuzz_macro_dwarf5 --testobj=$testsrc/ossfuzz58797/fuzz_macro_dwarf5-4872686367801344

runsingle ossfuzz58769.base  ./fuzz_macro_dwarf5 --testobj=$testsrc/ossfuzz58769/fuzz_macro_dwarf5-5460713058205696

runsingle ossfuzz58026.base  ./fuzz_set_frame_all --testobj=$testsrc/ossfuzz58026/fuzz_set_frame_all-4582976972521472.fuzz

runsingle ossfuzz57887.base  ./fuzz_die_cu --testobj=$testsrc/ossfuzz57887/fuzz_die_cu-4866423964172288

runsingle dwnames_all.base ./dwnames_all
runsingle ossfuzz57766.base  ./fuzz_die_cu_print --testobj=$testsrc/ossfuzz57766/fuzz_die_cu_print-5295062170075136

runsingle ossfuzz57711.base  ./fuzz_srcfiles --testobj=$testsrc/ossfuzz57711/fuzz_srcfiles-4695324781576192

runsingle ossfuzz57562.base  ./fuzz_findfuncbypc --testobj=$testsrc/ossfuzz57562/fuzz_findfuncbypc-6681114772373504

runsingle ossfuzz57527.base  ./fuzz_srcfiles --testobj=$testsrc/ossfuzz57527/fuzz_srcfiles-4599045397282816

runsingle ossfuzz57516.base  ./fuzz_die_cu_attrs --testobj=$testsrc/ossfuzz57516/fuzz_die_cu_attrs-6171488289161216
runsingle ossfuzz57485.base  ./fuzz_die_cu_attrs --testobj=$testsrc/ossfuzz57485/fuzz_die_cu_attrs-6025735319191552
runsingle ossfuzz57463.base  ./fuzz_die_cu_attrs --testobj=$testsrc/ossfuzz57463/fuzz_die_cu_attrs-5158380196200448

runsingle ossfuzz57443.base  ./fuzz_srcfiles --testobj=$testsrc/ossfuzz57443/fuzz_srcfiles-6015429578719232

runsingle ossfuzz57442.base  ./fuzz_rng --testobj=$testsrc/ossfuzz57442/fuzz_rng-5974595378479104
runsingle ossfuzz57437.base  ./fuzz_srcfiles --testobj=$testsrc/ossfuzz57437/fuzz_srcfiles-5281689109921792
runsingle ossfuzz57429.base  ./fuzz_die_cu_attrs --testobj=$testsrc/ossfuzz57429/fuzz_die_cu_attrs-4845537731149824

runsingle ossfuzz57335.base  ./fuzz_die_cu_attrs --testobj=$testsrc/ossfuzz57335/fuzz_die_cu_attrs-6235345560928256.fuzz

runsingle ossfuzz57300.base  ./fuzz_die_cu --testobj=$testsrc/ossfuzz57300/fuzz_die_cu-4752724662288384

runsingle ossfuzz57292.base  ./fuzz_die_cu_print --testobj=$testsrc/ossfuzz57292/fuzz_die_cu_print-5412313393135616

runsingle ossfuzz57149.base  ./fuzz_srcfiles --testobj=$testsrc/ossfuzz57149/fuzz_srcfiles-6213793811398656

runsingle ossfuzz57193.base  ./fuzz_die_cu_offset --testobj=$testsrc/ossfuzz57193/fuzz_die_cu_offset-5215024489824256

runsingle ossfuzz56958.base  ./fuzz_stack_frame_access --testobj=$testsrc/ossfuzz56958/fuzz_stack_frame_access-6097292873826304

#Runs the intended op
runsingle ossfuzz56895mac.base  ./fuzz_macro_dwarf5 --testobj=$testsrc/ossfuzz56895/fuzz_macro_dwarf5-5080340952907776
# This one runs the wrong app.
runsingle ossfuzz56895.base  ./fuzz_die_cu_attrs_loclist --testobj=$testsrc/ossfuzz56895/fuzz_macro_dwarf5-5080340952907776

# Here running correct app for the test
runsingle ossfuzz56480dcp.base  ./fuzz_die_cu_print --testobj=$testsrc/ossfuzz56480/fuzz_die_cu_print-5264022485467136
# Here running the wrong app for the testcase.
runsingle ossfuzz56480.base  ./fuzz_die_cu_attrs_loclist --testobj=$testsrc/ossfuzz56480/fuzz_die_cu_print-5264022485467136

runsingle ossfuzz56807.base  ./fuzz_srcfiles --testobj=$testsrc/ossfuzz56807/fuzz_srcfiles-4626047380619264
#running wrong app
runsingle ossfuzz56487w.base  ./fuzz_die_cu_attrs_loclist --testobj=$testsrc/ossfuzz56487/clusterfuzz-testcase-fuzz_rng-6655451078197248
# running correct app
runsingle ossfuzz56487.base  ./fuzz_rng --testobj=$testsrc/ossfuzz56487/clusterfuzz-testcase-fuzz_rng-6655451078197248
runsingle ossfuzz57107.base  ./fuzz_die_cu_attrs_loclist --testobj=$testsrc/ossfuzz57107/fuzz_die_cu_attrs_loclist-4991396240293888

runsingle ossfuzz57048.base  ./fuzz_findfuncbypc --testobj=$testsrc/ossfuzz57048/fuzz_findfuncbypc-4647942385696768
runsingle ossfuzz56454.base  ./fuzz_die_cu_offset --testobj=$testsrc/ossfuzz56454/fuzz_die_cu_offset-5171954224332800.fuzz

runsingle ossfuzz57027.base  ./fuzz_stack_frame_access --testobj=$testsrc/ossfuzz57027/fuzz_stack_frame_access-5123569972805632

runsingle ossfuzz56993.base  ./fuzz_macro_dwarf5 --testobj=$testsrc/ossfuzz56993/fuzz_macro_dwarf5-5770464300761088

runsingle ossfuzz56906.base  ./fuzz_rng --testobj=$testsrc/ossfuzz56906/fuzz_rng-6031783801257984.fuzz

# These fail badly in many ways though early errors hide what used to be found early.
runtest $d1 $d2 liu/OOB_read4.elf -a -M 
runtest $d1 $d2 liu/OOB_read4.elf -ka -M 

runtest $d1 $d2 liu/NULLdereference0519.elf -a -M
runtest $d1 $d2 liu/NULLdereference0519.elf -ka

# New tests as of 21 June 2025, github issue 297.
runtest $d1 $d2 rifkinpe/KeyTest.exe -i -M 

# New tests as of 22 November 2024
runtest $d1 $d2 rifkin8/stacktrace.cpp.dwo -a -M --file-tied=$testsrc/rifkin8/unittest
runtest $d1 $d2 rifkin8/stacktrace.cpp.dwo -ka --file-tied=$testsrc/rifkin8/unittest
runtest $d1 $d2 rifkin8/unittest -a -M --print-raw-rnglists
runtest $d1 $d2 rifkin8/unittest -ka 
runtest $d1 $d2 rifkin8/stacktrace.cpp.dwo --print-raw-rnglists
runtest $d1 $d2 rifkin8/stacktrace.cpp.dwo -ka

# DWARF5 MacOS, and requires some additional section name translations.
runtest $d1 $d2 myzhan/lua -a -vv -M --print-raw-rnglists

# These are DWARF5, and require DW_AT_rnglists_base NOT be inherited.
# New tests as of November 2024
runtest $d1 $d2 rifkin7/unittest -a -M --print-raw-rnglists
runtest $d1 $d2 rifkin7/unittest -ka 
runtest $d1 $d2 rifkin7/stacktrace.cpp.dwo --print-raw-rnglists
runtest $d1 $d2 rifkin7/stacktrace.cpp.dwo -ka-raw-rnglists
runtest $d1 $d2 rifkin7/stacktrace.cpp.dwo -a --file-tied=$testsrc/rifkin7/unittest 
runtest $d1 $d2 rifkin7/stacktrace.cpp.dwo -ka --file-tied=$testsrc/rifkin7/unittest

runtest $d1 $d2 ossfuzz56906/fuzz_rng-6031783801257984.fuzz --print-raw-rnglists

runsingle ossfuzz56897.base  ./fuzz_rng --testobj=$testsrc/ossfuzz56897/fuzz_rng-5105415777288192

# wrong testcase
#runsingle ossfuzz56458.base  ./fuzz_die_cu_attrs --testobj=$testsrc/ossfuzz56458/fuzz_globals-5286908805906432
runsingle ossfuzz56458.base  ./fuzz_globals --testobj=$testsrc/ossfuzz56458/fuzz_globals-5286908805906432

runsingle ossfuzz56450.base  ./fuzz_die_cu_attrs --testobj=$testsrc/ossfuzz56450/fuzz_die_cu_attrs-4953133005799424

runsingle ossfuzz56676.base  ./fuzz_gdbindex --testobj=$testsrc/ossfuzz56676/fuzz_set_frame_all-5081006119190528.fuzz
runsingle ossfuzz56456.base  ./fuzz_gdbindex --testobj=$testsrc/ossfuzz56456/fuzz_gdbindex-5240324382654464

runsingle ossfuzz56735.base  ./fuzz_macro_dwarf5 --testobj=$testsrc/ossfuzz56735/fuzz_macro_dwarf5-6718585377783808
runsingle ossfuzz56453.base  ./fuzz_debug_addr_access --testobj=$testsrc/ossfuzz56453/fuzz_debug_addr_access-5069447397507072
runsingle ossfuzz56476.base  ./fuzz_rng --testobj=$testsrc/ossfuzz56476/fuzz_rng-5008229349588992
runsingle ossfuzz56478.base  ./fuzz_rng --testobj=$testsrc/ossfuzz56478/fuzz_rng-5030515398017024

runsingle ossfuzz56489.base  ./fuzz_str_offsets --testobj=$testsrc/ossfuzz56489/fuzz_srcfiles-5091530466787328
runsingle ossfuzz56460.base  ./fuzz_str_offsets --testobj=$testsrc/ossfuzz56460/fuzz_str_offsets-5376904040677376

runsingle ossfuzz56636.base  ./fuzz_debug_addr_access --testobj=$testsrc/ossfuzz56636/fuzz_debug_addr_access-4801779658522624.fuzz

runsingle ossfuzz56548.base  ./fuzz_findfuncbypc --testobj=$testsrc/ossfuzz56548/fuzz_findfuncbypc-5073632331431936

runsingle ossfuzz56530.base  ./fuzz_findfuncbypc --testobj=$testsrc/ossfuzz56530/fuzz_findfuncbypc-6272642689925120

runsingle ossfuzz56465.base  ./fuzz_die_cu_offset --testobj=$testsrc/ossfuzz56465/fuzz_die_cu_offset-5866690199289856

runsingle databitoffset.base $d2 -i -M $testsrc/databitoffset/dbotest.o

if [  $platform = "msys2" ]
then 
  echo "====SKIP test_pubsreader on msys2"
  skipcount=`expr $skipcount +  1 `
else 
  echo "=====START  $testsrc/test_pubsreader good=$goodcount skip=$skipcount fail=$failcount"
    x="$CC $warn -I$codedir/src/lib/libdwarf -I$libbld \
       $libzhdr \
       -I$libbld/libdwarf $nonsharedopt \
       -gdwarf $nlizeopt $testsrc/test_pubsreader.c \
        -o test_pubsreader $dwlib $libzlib $libzlink"
    echo $x
    $x
    r=$?
    chkresbld $r 'check pubsreader-error compile test_pubsreader.c failed'
    echo "./test_pubsreader $suppresstree $testsrc/mustacchi/m32t.o \
      $testsrc/irixn32/dwarfdump"
    echo "Results in junk_pubsreaderout"
    ./test_pubsreader $testsrc/irixn32/dwarfdump \
       $testsrc/mustacchi/m32t.o \
       >junk_pubsreaderout
    r=$?
    chkresbld $r "check pubsreader-error execution failed look at \
      junk_pubsreaderout"
    diff $testsrc/pubsreader.base $bldtest/junk_pubsreaderout
    r=$?
    chkres $r "fail comparison pubsreader.base vs junk_pubsreaderout"
    if [ $r -ne 0 ]
    then
      echo "FAIL diff $testsrc/pubsreader.base $bldtest/junk_pubsreaderout"
      echo "To update mv $bldtest/junk_pubsreaderout $testsrc/pubsreader.base"
    fi
fi

if [  $platform = "msys2" ]
then
  echo "====bitoffset/test_bitoffset SKIP on msys2"
  skipcount=`expr $skipcount +  1 `
else
  echo "=====START  $testsrc/bitoffset/test_bitoffset.c good=$goodcount skip=$skipcount fail=$failcount"
  echo "test_bitoffset:"
  x="$CC $warn -I$codedir/src/lib/libdwarf -I$libbld -I$libbld/libdwarf \
    $libzhdr $nonsharedopt \
    -gdwarf $nlizeopt $testsrc/bitoffset/test_bitoffset.c  -o \
     test_bitoffset $dwlib $libzlib $libzlink"
  echo $x
  $x
  chkresbld $? "check bitoffset-error compiling bitoffset/test_bitoffset.c\
    failed"
  echo "./test_bitoffset  \
   $testsrc/bitoffset/bitoffsetexampledw3.o \
   $testsrc/bitoffset/bitoffsetexampledw5.o "
  ./test_bitoffset  \
   $testsrc/bitoffset/bitoffsetexampledw3.o \
   $testsrc/bitoffset/bitoffsetexampledw5.o  \
   >junk_bitoffset
  chkresbld $? "check bitoffset-error execution failed look at \
    junk_bitoffset"
  diff $testsrc/bitoffset/bitoffset.base junk_bitoffset
  r=$?
  chkres $r "FAIL comparison $testsrc/bitoffset/bitoffset.base vs junk_bitoffset"
  if [ $r -ne 0 ]
  then
   echo "FAIL diff $testsrc/bitoffset.base \
     $bldtest/junk_bitoffset"
   echo "To update mv $bldtest/junk_bitoffset \
     $testsrc/bitoffset.base"
  fi
fi
echo "=====BUILD  $testsrc/test_arange"
  x="$CC $warn -I$codedir/src/lib/libdwarf -I$libbld \
     -I$libbld/libdwarf \
     $libzhdr $nonsharedopt  \
     -gdwarf $nlizeopt $testsrc/test_arange.c  -o \
      test_arange $dwlib $libzlib $libzlink"
  echo "$x"
  $x
  chkresbld $? 'check arange-error compiling test_arange.c\
     failed'
echo "=====BUILD  $testsrc/test_setframe"
  x="$CC $warn -I$codedir/src/lib/libdwarf -I$libbld \
     -I$libbld/libdwarf \
     $libzhdr $nonsharedopt \
     -gdwarf $nlizeopt $testsrc/test_setframe.c  -o \
      test_setframe $dwlib $libzlib $libzlink"
  echo "$x"
  $x
  chkresbld $? 'check setframe-error compiling test_setframe.c\
     failed'

if [ $compileonly = "y" ]
then
  if [ $failcount -ne 0 ]
  then
    echo "FAIL: STOP after failed building dwtests executables"
    rm -f dwbb
    exit 1
  fi
  echo "STOP after successfully building dwtests executables"
  rm -f dwbb
  exit 0
fi

#if [  $platform = "macos" ]
#then
#  echo "=====SKIP test_setframe test on macos (1)"
#  skipcount=`expr $skipcount +  1 `
#else
# No need to skip now we have a known-object-input.
# and a test dependent on the *current* compiler was always
# a bad idea...
runsingle test_setframe.base ./test_setframe $testsrc/test_setframe.input
#fi

runsingle test_language_version.base ./test_language_version

# Checking that we can print the .debug_sup section
echo "=====START  supplementary  $testsrc/supplementary/runtest.sh good=$goodcount skip=$skipcount fail=$failcount"
mklocal supplementary
  sh $testsrc/supplementary/runtest.sh
  chkres $? "$testsrc/supplementary/runtest.sh"
cd ..

# For these, see runsingle. This subdir is no longer relevant.
#echo "=====START  showsectiongroups  $testsrc/showsecgroupsdir/runtest.sh"
#mklocal showsecgroupsdir
#  sh $testsrc/showsecgroupsdir/runtest.sh
#  chkres $? "$testsrc/showsecgroupsdir/runtest.sh"
#cd ..

# New as of July 2025. DW_AT_language_version
runtest $d1 $d2 wjl/demo -i --print-language-version-table
# New as of August 2025. --print-all-srcfiles
runtest $d1 $d2 wjl/demo  --print-all-srcfiles 

# New as of Aug 2024.
runtest $d1 $d2 polar/cpp_test.o --print-debug-names

# New tests as of July 2024.
runtest $d1 $d2 rifkin3/stacktrace.cpp.dwo --print-ranges --file-tied=$testsrc/rifkin3/unittest -M -i -vvv -G
runtest $d1 $d2 rifkin3/stacktrace.cpp.dwo --print-ranges -M -i -vvv -G
runtest $d1 $d2 rifkin3/unittest  --print-ranges -M -i -vvv -G

# New tests as of 12 June 2024.
runtest $d1 $d2 rifkindwo/demo -a -M -vvv 
runtest $d1 $d2 rifkindwo/demo --print-raw-rnglists --print-raw-loclists 
runtest $d1 $d2 rifkindwo/demo.cpp.dwo  -a -M -vvv
runtest $d1 $d2 rifkindwo/demo.cpp.dwo --print-raw-rnglists --print-raw-loclists 
runtest $d1 $d2 rifkindwo/demo.cpp.dwo --file-tied=$testsrc/rifkindwo/demo -a -M -vvv

runtest $d1 $d2 rifkindwo/libcpptrace.so.0.6.0 -a -M -vvv 
runtest $d1 $d2 rifkindwo/libcpptrace.so.0.6.0  --print-raw-rnglists --print-raw-loclists 
runtest $d1 $d2 rifkindwo/cpptrace.cpp.dwo  -a -M -vvv
runtest $d1 $d2 rifkindwo/cpptrace.cpp.dwo --print-raw-rnglists --print-raw-loclists 
runtest $d1 $d2 rifkindwo/cpptrace.cpp.dwo --file-tied=$testsrc/rifkindwo/libcpptrace.so.0.6.0 -a -M -vvv
runtest $d1 $d2 rifkin5/demo.cpp.dwo --file-tied=$testsrc/rifkin5/demo -a -M  -vvv

runversiontest $d2 -V

echo "=====START  guilfanov  $testsrc/guilfanov/runtest.sh good=$goodcount skip=$skipcount fail=$failcount"
mklocal guilfanov
  sh $testsrc/guilfanov/runtest.sh
  # A fuzzed object which can crash libdwarf due to a bug.
  # hangs libdwarf/dwarfdump.
  chkres $? "$testsrc/guilfanov/runtest.sh"
cd ..
echo "=====START  guilfanov2  $testsrc/guilfanov2/runtest.sh good=$goodcount skip=$skipcount fail=$failcount"
mklocal guilfanov2
  sh $testsrc/guilfanov2/runtest.sh
  # A fuzzed object which can encounter a double-free
  # but most likely not in libdwarf 0.1.2 or later.
  chkres $? "$testsrc/guilfanov2/runtest.sh"
cd ..

echo "=====START utf8 test   good=$goodcount skip=$skipcount fail=$failcount"
# contains local variables spelled with utf-8 and non-ASCII bytes
if  [  "x$asciionly" = "xn" ]
then
  runtest $d1 $d2 utf8/test -i
  chkres $? " running utf8 non ascii"
else
  echo "=====SKIP running utft/test as we are restricting to ASCII. (1)"
  skipcount=`expr $skipcount +  1`
fi
echo "=====START utf8 test b   good=$goodcount skip=$skipcount fail=$failcount"
runtest $d1 $d2 utf8/test --format-suppress-utf8 -i
chkres $? "utf8 check, ascii only "


#  Fails in 0.5.0, 0.6.0, fixed in 0.7.0
echo "=====START shinibufa fuzzed   good=$goodcount skip=$skipcount fail=$failcount"
runtest $d1 $d2 shinibufa/fuzzed_input_file

# Test of DWARF5 line table includes from
# an unknown shared library.debug (nothing executable
# here). This had erroneous output (duplicated include path)
# from recent builds of dwarfdump 11 Aug 2023
if [ "x$skipdecompress" = "xn" ]
then
  if [ "x$skipbigobjects" = "xy" ]
  then
    echo "=====SKIP running this big object with big .debug_loclists, rnglists(1)"
    skipcount=`expr $skipcount +  1`
  else
    runtest $d1 $d2 debugso20230811.debug -i -vvv
  fi
else
  echo "=====SKIP .debugso20230811.debug as it has compression(1)"
  skipcount=`expr $skipcount +  1`
fi

# Early test of -h.
runtest $d1 $d2 foo.o -h

# Testing that the elf extension of using sh_size and sh_link
# as values of e_shnum and e_shstrndx in the Elf header.
# So at least 32 bit values instead of the Elf header 16bit.
# The next two examples were wrong, but
# an error is returned so all is well.
runtest $d1 $d2 elfextend/testobj.extend -i
runtest $d1 $d2 elfextend/testobj64.extend -i
# of the Elf gabi+ section numbering extension.
runtest $d1 $d2 elfextend/testobjgnu.extend -i
runtest $d1 $d2 elfextend/testobj64gnu.extend -i

# The testcase is empty file. Ensure it behaves ok.
runtest $d1 $d2 ossfuzz51183/ossfuzz54358-emptyfile -i

# Testcase uses DW_FORM_strx3.
# Similar problem exists with DW_FORM_addrx3.
# Neither handled properly until 24 January 2023 v0.6.0
runtest $d1 $d2 kaufmann2/ct-bad.o -a -M -vv

runtest $d1 $d2 data16/data16.bin               -a -M
runtest $d1 $d2 implicitconst/implicitconst.bin -a -M
runtest $d1 $d2 offsetfromlowpc/offsetfromlowpc.bin -a -M
runtest $d1 $d2 dwgenc/dwgenc.bin -a -M

# So lcov sees this option used.
runtest $d1 $d2 supplementary/dwarfstringsup.o --print-debug-sup
runtest $d1 $d2 supplementary/dwarfstringsup.o -i -cs
runtest $d1 $d2 supplementary/dwarfstringsup.o -i -cg

# November 4, 2022. Realized we could not print .debug_addr
# on its own. Implemented new libdwarf functions and
# added --print-debug-addr to dwarfdump.

runtest $d1 $d2 pubnames/bothpubs.exe               -i --check-functions
runtest $d1 $d2 shopov2/clang-9.0.0-test-dwarf5.elf -i -M --print-debug-addr
runtest $d1 $d2 pubnames/bothpubs.exe               -i -M --print-debug-addr
runtest $d1 $d2 pubnames/dw5_names.o                -i -M --print-debug-addr

# October 11, 2022. Problem, DW5 default file number and gcc 11.2.0
runtest $d1 $d2  issue137gh/main -l
runtest $d1 $d2  issue137gh/main -l -v
runtest $d1 $d2  issue137gh/main -l -vv
runtest $d1 $d2  issue137gh/mainclang14 -l
runtest $d1 $d2  issue137gh/mainclang14 -l -v
runtest $d1 $d2  issue137gh/mainclang14 -l -vv

# October 4, 2022. .debug_pubnames with two CUs.
runtest $d1 $d2  pubnames/tests.exe --print-pubnames --print-type

# September 2022.  ossfuzz detected memory leak.
runtest $d1 $d2 ossfuzz51183/clusterfuzz-51183-6011554641870848 -a

#27 August 2022  DW202208-001
runtest $d1 $d2 hanzheng/fuzzedobject -vv -a

#1 May 2022 ossfuzz 47150  DW202207-001
runtest $d1 $d2 ossfuzz47150/clusterfuzz-testcase-minimized-fuzz_init_path-6727387238236160.fuzz

#15 June 2022 DW202206-001
runtest $d1 $d2 sleicasper2/buffer-overflow-form-sig8 -a -v

#  May 19 2022 Accomodate Apple use of DW_AT_entry_pc as base address.
runtest $d1 $d2 diederen7/pc_dwarf_aircrack_ng.macho -a -vv -M

# March 24, 2022, fuzzed object
runtest $d1 $d2 moqigod/buffer-overflow-example-2022

if [  $platform = "msys2" ]
then
  echo "====SKIP debuglink on msys2"
  skipcount=`expr $skipcount +  12 `
else
# May 6, 2022. debuglink tests exploring related options
  runtest $d1 $d2 debuglinkb/testid -P -i
  runtest $d1 $d2 debuglinkb/testid.debug -P -i
  runtest $d1 $d2 debuglinkb/testnoid -P -i
  runtest $d1 $d2 debuglinkb/testnoid.debug -P -i

  runtest $d1 $d2 debuglinkb/testid -P -i --no-follow-debuglink
  runtest $d1 $d2 debuglinkb/testid.debug -P -i --no-follow-debuglink
  runtest $d1 $d2 debuglinkb/testnoid -P -i --no-follow-debuglink
  runtest $d1 $d2 debuglinkb/testnoid.debug -P -i --no-follow-debuglink

  runtest $d1 $d2 debuglinkb/testid -P -i --suppress-debuglink-crc
  runtest $d1 $d2 debuglinkb/testid.debug -P -i --suppress-debuglink-crc
  runtest $d1 $d2 debuglinkb/testnoid -P -i --suppress-debuglink-crc
  runtest $d1 $d2 debuglinkb/testnoid.debug -P -i --suppress-debuglink-crc
fi

# February 16, 2022, with clang-generated .debug_names
# The ones with -v are ok, but not as nice looking.
runtest $d1 $d2 debugnames/jitreader    --print-pubnames
runtest $d1 $d2 debugnames/jitreader    -i -G --print-debug-names
runtest $d1 $d2 debugnames/jitreader    -i -G --print-debug-names -v
runtest $d1 $d2 debugnames/jitreader    -i -G --print-debug-names -vv
runtest $d1 $d2 debugnames/dwarfdump    -i -G --print-debug-names -vv
# Comment out for sanitize run.
if [ "$nlize" = "n" ]
then
  if [ "$skipbigobjects" = "n" ]
  then
    runtest $d1 $d2 debugnames/dwarfdumpone -i -G --print-pubnames
    runtest $d1 $d2 debugnames/dwarfdumpone -i -G --print-debug-names -vv
  else
    echo "=====SKIP bigobjects of dwarfdumpone, skipcount+2: very slow"
    skipcount=`expr $skipcount +  2 `
  fi
else
  echo "=====SKIP NLIZE of dwarfdumpone, skipcount+2: very slow"
  skipcount=`expr $skipcount +  2 `
fi

#  A fuzzed object which hit a poorly written sanity
#  offset test. Test received 10 october 2020.
#  libdwarf vulnerability DW202010-001
runtest $d1 $d2 c-sun/poc -vv -a
# ensure we catch the corruption without -vv
runtest $d1 $d2 c-sun/poc -a

#  Checking for correct printing of negative DW_OP_skip or branch.
#  And that the checking catches the skip/br that give
#  an invalid target offset.
runtest $d1 $d2 bad-dwop/badskipbranch.o -i -v -M

#Corrupted objects from oss-fuzz
#Anyone running actual oss-fuzzing would see some
#messages from libdwarf. See
#ossfuzz40802/test40802.c for an explanation.
#The runtest examples of ossfuzz will never generate
#those messages. The hughes2 testcase below does though.
runtest $d1 $d2 \
  ossfuzz40627/clusterfuzz-testcase-fuzz_init_path-5186858573758464

runtest $d1 $d2 \
  ossfuzz40627/clusterfuzz-testcase-minimized-fuzz_init_path-5186858573758464 -a

runtest $d1 $d2 \
  ossfuzz40663/clusterfuzz-testcase-minimized-fuzz_init_path-6122542432124928 -a

runtest $d1 $d2 \
  ossfuzz40669/clusterfuzz-testcase-minimized-fuzz_init_path-5399726397194240 -a

runtest $d1 $d2 \
  ossfuzz40669/clusterfuzz-testcase-fuzz_init_path-5399726397194240 -a

runtest $d1 $d2 \
  ossfuzz40671/clusterfuzz-testcase-fuzz_init_path-5455557297831936 -a

runtest $d1 $d2 \
  ossfuzz40671/clusterfuzz-testcase-minimized-fuzz_init_path-5455557297831936 -a

runtest $d1 $d2 \
  ossfuzz40673/clusterfuzz-testcase-minimized-fuzz_init_path-6240961391362048.fuzz -a

runtest $d1 $d2 \
  ossfuzz40674/clusterfuzz-testcase-minimized-fuzz_init_path-6557751518560256 -a

runtest $d1 $d2 \
  ossfuzz40729/clusterfuzz-testcase-minimized-fuzz_init_binary-4791627277795328 -a

runtest $d1 $d2 \
  ossfuzz40731/clusterfuzz-testcase-fuzz_init_binary-5983147574034432 -a

runtest $d1 $d2 \
  ossfuzz40731/clusterfuzz-testcase-minimized-fuzz_init_binary-5983147574034432 -a

runtest $d1 $d2 \
  ossfuzz40799/clusterfuzz-testcase-fuzz_init_path-5245778948390912 -a
runtest $d1 $d2 \
  ossfuzz40799/clusterfuzz-testcase-minimized-fuzz_init_path-5245778948390912 -a

runtest $d1 $d2 \
  ossfuzz40801/clusterfuzz-testcase-fuzz_init_path-5443517279764480 -a
runtest $d1 $d2 \
  ossfuzz40801/clusterfuzz-testcase-minimized-fuzz_init_path-5443517279764480 -a

runtest $d1 $d2 \
 ossfuzz40802/clusterfuzz-testcase-fuzz_init_binary-5538015955517440.fuzz -a -F -f

runtest $d1 $d2 \
 ossfuzz40802/clusterfuzz-testcase-fuzz_init_binary-5538015955517440.fuzz -a -F -f

runtest $d1 $d2 \
  ossfuzz40895/clusterfuzz-testcase-fuzz_init_binary-4805508242997248 -a
runtest $d1 $d2 \
  ossfuzz40895/clusterfuzz-testcase-minimized-fuzz_init_binary-4805508242997248 -a

runtest $d1 $d2 \
  ossfuzz40896/clusterfuzz-testcase-fuzz_init_path-5337872492789760 -a
runtest $d1 $d2 \
  ossfuzz40896/clusterfuzz-testcase-minimized-fuzz_init_path-5337872492789760 -a

runtest $d1 $d2 \
  ossfuzz41240/clusterfuzz-testcase-minimized-fuzz_init_path-5929343686148096 -a
if [  $platform = "msys2" ]
then
  echo "====SKIP debuglink on msys2"
  skipcount=`expr $skipcount +  1 `
else
  runtest $d1 $d2 \
  ossfuzz41240/clusterfuzz-testcase-minimized-fuzz_init_path-5929343686148096 --print-gnu-debuglink
fi

#These two were a libelf bug. Lets see how libdwarf elf reading
#deals with it.
runtest $d1 $d2 \
  sarubbo-a/00031-elfutils-memalloc-__libelf_set_rawdata_wrlock

runtest $d1 $d2 \
  sarubbo-b/00011-elfutils-memalloc-allocate_elf

# SHF_COMPRESSED testcases.
if [ "x$withlibz" = "xno" ]
then
  echo "=====SKIP COMPRESSED tests, skipcount+6 no libz available(6)"
  skipcount=`expr $skipcount +  6 `
else
  if [ "x$skipdecompress" = "xn" ]
  then
    runtest $d1 $d2 compressed-be/testprog-be-dw4 -b -v
    runtest $d1 $d2 compressed-be/testprog-be-dw4 -a -vvvv
    runtest $d1 $d2 compressed-be/testprog-be-dw4 -ka
    runtest $d1 $d2 compressed-le/testprog-le-dw4 -b -v
    runtest $d1 $d2 compressed-le/testprog-le-dw4 -a -vvvv
    runtest $d1 $d2 compressed-le/testprog-le-dw4 -ka
  else 
    echo "=====SKIP compressed-be/testprog-be-dw4 (6) "
    skipcount=`expr $skipcount +  6`
  fi
fi

# See bug DW202010-002
runtest $d1 $d2 c-sun2/globaloverflow -vv -a
# See bug DW202010-003
runtest $d1 $d2 c-sun2/nullpointer -vv -a

# Doc used to be wrong about the spelling
# of the long form
runtest $d1 $d2 kaletta2/minimal_fdebug_types_section.o \
 "-i -vv -x groupnumber=3"
runtest $d1 $d2 kaletta2/minimal_fdebug_types_section.o \
 -i -vv --format-group-number=3

# These files are Arm and the compiler
# is generating section groups but without
# any use of the Elf GROUP flag.
# No documentation I can find explains how it
# is supposed to work with these people's linker.
runtest $d1 $d2  kaletta/test.armlink.elf -i -vv
runtest $d1 $d2  kaletta/test.o  -i -vv

# example of command mistakes. Too many object names
# or no object names. Neither reads any object file.
runtest $d1 $d2 moya/simple.o moya3/ranges_base.dwo

# Examples of turning off sanitized() calls.
# Unsafe for your terminal/window to use these
# on corrupted object files or objects with unusual
# string encodings.
runtest $d1 $d2  moya3/ranges_base.dwo --format-suppress-sanitize
runtest $d1 $d2  moya3/ranges_base.dwo -x nosanitizestrings

# This set of moya4/hello is because -kuf and -C do not stand
# alone. They are meaningful as modifiers only.
# Suppresses summary tag-tree entries of zero.
runtest $d1 $d2  moya4/hello -ku
#This next summarizes tag_tree entries including those with zero use.
runtest $d1 $d2  moya4/hello -ku -kuf
# details and summary tag-tree
runtest $d1 $d2  moya4/hello -kr
# details show extensions as error
runtest $d1 $d2  moya4/hello -kr -C
#This next summary and error detail tag_tree entries including those with zero use.
runtest $d1 $d2  moya4/hello -kr -kuf
#This next summary and error detail tag_tree entries including those with zero use.
# here calling extension errors.
runtest $d1 $d2  moya4/hello -kr -kuf -C

# printing .debug_gnu_pubnames and .debug_gnu_pubtypes
runtest $d1 $d2 debugfission/archive.o --print-debug-gnu
runtest $d1 $d2 debugfission/target.o  --print-debug-gnu
runtest $d1 $d2 gsplitdwarf/frame1     --print-debug-gnu
if [  $platform = "msys2" ]
then
  echo "=====SKIP debuglink runtest.sh on msys2"
  skipcount=`expr $skipcount +  1 `
else
  runtest $d1 $d2 gsplitdwarf/getdebuglink --print-debug-gnu
fi
runtest $d1 $d2 moya/simple.o          --print-debug-gnu
runtest $d1 $d2 moya/with-types.o      --print-debug-gnu
runtest $d1 $d2 moya3/ranges_base.o    -a -G -M -v
runtest $d1 $d2 moya3/ranges_base.dwo  -a -G -M -v
runtest $d1 $d2 moya3/ranges_base.dwo  -a -G -M -v --file-tied=$testsrc/moya3/ranges_base.o

# This deliberately has a duplicate id of a section
# in two different groups.  Created by binary edit of
# archive.o Before May 2023 this
# would get an error even though the section involved
# is of no interest to libdwarf.
runtest $d1 $d2 debugfission/mungegroup.o -i
 
#Has duplicate attrs.
runtest $d1 $d2 duplicateattr.o -i
runtest $d1 $d2 duplicateattr.o -i --no-dup-attr-check

# New September 11, 2019.
echo "=====START  $testsrc/testoffdie runtest.sh good=$goodcount skip=$skipcount   fail=$failcount"
  mklocal testoffdie
    sh $testsrc/testoffdie/runtest.sh  
    chkres $? "$testsrc/testoffdie/runtest.sh"
  cd ..

# .gnu_debuglink and .note.gnu.build-id  section tests.
if [ "x$endian" = "xB" -o "x$platform" = "xmsys2" ]
then
  echo "=====SKIP debuglink runtest.sh as bigendian will fail (1) good=$goodcount skip=$skipcount"
  skipcount=`expr $skipcount + 1`
else
  echo "=====START  $testsrc/debuglink runtest.sh good=$goodcount skip=$skipcount fail=$failcount"
  mklocal debuglink
    sh $testsrc/debuglink/runtest.sh
    chkres $? "$testsrc/debuglink/runtest.sh"
  cd ..
fi

#gcc using -gsplit-dwarf option
# debuglink via DWARF4. frame one via DWARF5
if [  $platform = "msys2" ]
then
  echo "=====SKIP debuglink on msys2"
  skipcount=`expr $skipcount +  4 `
else
  runtest $d1 $d2 gsplitdwarf/getdebuglink --print-debug-gnu
  runtest $d1 $d2 gsplitdwarf/getdebuglink     --print-fission -a
  runtest $d1 $d2 gsplitdwarf/getdebuglink.dwo --print-fission -a
  runtest $d1 $d2 gsplitdwarf/getdebuglink.dwo --file-tied=$testsrc/gsplitdwarf/getdebuglink --print-fission -a
fi

runtest $d1 $d2 gsplitdwarf/frame1.dwo       -a --print-fission
runtest $d1 $d2 gsplitdwarf/frame1.dwo --file-tied=$testsrc/gsplitdwarf/frame1 -a --print-fission
runtest $d1 $d2 gsplitdwarf/frame1 -a --print-fission
# Same but now with -vv
if [  $platform = "msys2" ]
then
  echo "=====SKIP debuglink on msys2"
  skipcount=`expr $skipcount +  3 `
else
  runtest $d1 $d2 gsplitdwarf/getdebuglink -a -vv --print-fission
  runtest $d1 $d2 gsplitdwarf/getdebuglink.dwo -a -vv --print-fission
  runtest $d1 $d2 gsplitdwarf/getdebuglink.dwo --file-tied=$testsrc/gsplitdwarf/getdebuglink -a -vv --print-fission
fi
runtest $d1 $d2 gsplitdwarf/frame1.dwo -a -vv --print-fission
runtest $d1 $d2 gsplitdwarf/frame1.dwo --file-tied=$testsrc/gsplitdwarf/frame1 -a -vv --print-fission
runtest $d1 $d2 gsplitdwarf/frame1 -a --print-fission -vv

# tiny and severly damaged 'object' file.
runtest $d1 $d2 kapus/bad.obj -a

#DWARF5 with .debug_rnglists and .debug_loclists
runtest $d1 $d2 moya4/hello -ka -v
runtest $d1 $d2 moya4/hello -a -v -M
if [ "x$skipdecompress" = "xn" ]
then
  runtest $d1 $d2 moya2/filecheck.dwo -i -vv --print-raw-loclists --print-raw-rnglists
  runtest $d1 $d2 moya2/filecheck.dwo -ka
else
  echo "=====SKIP moya2/filecheck.dwo as it has compression(2)"
  skipcount=`expr $skipcount +  2`
fi

# Checking .debug_str_offsets used properly
runtest $d1 $d2 moya5/hello.dwo -a -M -v --print-str-offsets

runtest $d1 $d2 moya5/hello.dwo --file-tied=$testsrc/moya5/hello -a -M -v --print-str-offsets --print-strings
runtest $d1 $d2 moya5/hello -a -M -v --print-str-offsets --print-strings
runtest $d1 $d2 moya6/hello.dwp -a -M -v --print-str-offsets --print-strings
runtest $d1 $d2 moya6/hello.dwp --file-tied=$testsrc/moya6/hello -a -M -v --print-str-offsets --print-strings
runtest $d1 $d2 moya7/read-line-table-program-leak-test -a -M -v
runtest $d1 $d2 moya-loc/loclists.dwp --file-tied=$testsrc/moya-loc/loclists -a -M -v
runtest $d1 $d2 moya-loc/loclists.dwp --file-tied=$testsrc/moya-loc/loclists -ka

runtest $d1 $d2 moya8/index-out-of-bounds-test  -a -M -v
runtest $d1 $d2 moya9/oob-repro -a -M -v --print-str-offsets --print-strings
runtest $d1 $d2 moya-rb/ranges3.dwp -a -M -v -a -v --file-tied=$testsrc/moya-rb/ranges3
runtest $d1 $d2 moya-rb/ranges3 -a -M -v

runtest $d1 $d2 rnglists/readelfobj -vv  --print-raw-loclists --print-raw-rnglists
runtest $d1 $d2 rnglists/readelfobj -ka
runtest $d1 $d2 rnglists/linelen.o  -v --print-raw-loclists --print-raw-rnglists
runtest $d1 $d2 rnglists/linelen.o  -ka
runtest $d1 $d2 rnglists/extractdba.o -v --print-raw-loclists --print-raw-rnglists
runtest $d1 $d2 rnglists/extractdba.o -v  -ka
runtest $d1 $d2 rnglists/pe_map.o -v --print-raw-loclists --print-raw-rnglists
runtest $d1 $d2 rnglists/pe_map.o  --print-raw-loclists --print-raw-rnglists

runtest $d1 $d2 shopov2/clang-9.0.0-test-dwarf5.elf -a
runtest $d1 $d2 shopov2/clang-9.0.0-test-dwarf5.elf -ka

# FILES with .gdb_index
# -I is the same as --print-fission
runtest $d1 $d2 debugfissionb/ld-new                    --print-fission
runtest $d1 $d2 debugfissionb/ld-new               -vvv --print-fission
runtest $d1 $d2 dwarf4/ddg4.5dwarf-4-gdb-index          --print-fission
runtest $d1 $d2 dwarf4/ddg4.5dwarf-4-gdb-index     -vvv --print-fission
runtest $d1 $d2 emre2/emre.ex                           --print-fission
runtest $d1 $d2 emre2/emre.ex                      -vvv --print-fission
runtest $d1 $d2 emre4/test19_64_dbg                     --print-fission
runtest $d1 $d2 emre4/test19_64_dbg                -vvv --print-fission
runtest $d1 $d2 emre5/test33_64_opt_fpo_split           --print-fission
runtest $d1 $d2 emre5/test33_64_opt_fpo_split      -vvv --print-fission
runtest $d1 $d2 emre6/class_64_opt_fpo_split            --print-fission
runtest $d1 $d2 emre6/class_64_opt_fpo_split       -vvv --print-fission
runtest $d1 $d2 hughes/krb5-1.11.3-38.fc20.x86_64       --print-fission
runtest $d1 $d2 hughes/krb5-1.11.3-38.fc20.x86_64  -vvv --print-fission
runtest $d1 $d2 hughes/libkrb5support.so.0.1.debug      --print-fission
runtest $d1 $d2 hughes/libkrb5support.so.0.1.debug -vvv --print-fission
runtest $d1 $d2 libc6fedora18/libc-2.16.so.debug        --print-fission
runtest $d1 $d2 libc6fedora18/libc-2.16.so.debug   -vvv  --print-fission
# the following has several expression loopcounts!
runtest $d1 $d2 libc6fedora18/libc-2.16.so.debug    -v -i
runtest $d1 $d2 liu/OOB0505_02.elf                     --print-fission
runtest $d1 $d2 liu/OOB0505_02.elf                 -vvv --print-fission
runtest $d1 $d2 liu/heapoverflow01b.elf                 --print-fission
runtest $d1 $d2 liu/heapoverflow01b.elf            -vvv --print-fission
# FILES with .debug_cu__index and .debug_tu_index
runtest $d1 $d2 debugfissionb/ld-new.dwp                --print-fission
runtest $d1 $d2 debugfissionb/ld-new.dwp           -vvv --print-fission
runtest $d1 $d2 emre3/a.out.dwp                         --print-fission
runtest $d1 $d2 emre3/a.out.dwp                    -vvv --print-fission
runtest $d1 $d2 emre5/test33_64_opt_fpo_split.dwp       --print-fission
runtest $d1 $d2 emre5/test33_64_opt_fpo_split.dwp  -vvv --print-fission
runtest $d1 $d2 emre6/class_64_opt_fpo_split.dwp        --print-fission
runtest $d1 $d2 emre6/class_64_opt_fpo_split.dwp   -vvv --print-fission
runtest $d1 $d2 liu/NULLdereference0519.elf             --print-fission
runtest $d1 $d2 liu/NULLdereference0519.elf        -vvv --print-fission
runtest $d1 $d2 liu/OOB0517_02.elf                      --print-fission
runtest $d1 $d2 liu/OOB0517_02.elf                 -vvv --print-fission
runtest $d1 $d2 liu/OOB_read4.elf                       --print-fission
runtest $d1 $d2 liu/OOB_read4.elf                  -vvv --print-fission

# See mustacchi/README.
# Clang generates a slightly unusual relocation set for -m32.
# As of Jan 2020 for the m32 case dwarfdump prints the wrong stuff.
if [  $platform = "msys2" ]
then
  echo "=====SKIP mustacchi runtest.sh on msys2"
  skipcount=`expr $skipcount +  3 `
else 
  echo "=====START  $testsrc/mustacchi runtest.sh nolibelf good=$goodcount skip=$skipcount fail=$failcount"
  mklocal mustacchi
    sh $testsrc/mustacchi/runtestnolibelf.sh
    chkres $? "$testsrc/mustacchi/runtestnolibelf.sh"
  cd ..
fi

if [  $platform = "msys2" ]
then
  echo "=====SKIP debuglink on msys2"
  skipcount=`expr $skipcount +  1 `
else
  runtest $d1 $d2 val_expr/libpthread-2.5.so --print-gnu-debuglink
fi

if [ -f /lib/x86_64-linux-gnu/libc-2.27.so ]
then
  runtest $d1 $d2 /lib/x86_64-linux-gnu/libc-2.27.so --print-gnu-debuglink
else
  echo "=====SKIP  --print-gnu-debuglink /lib/x86_64-linux-gnu/libc-2.27.so(1)"
  skipcount=`expr $skipcount + 1`
fi

# Test ensuring R_386_GOTPC relocation understood. June 202
runtest $d1 $d2 mustacchi/relgotpc.o -a -M
if [ "x$withlibz" = "xno"  -o "x$skipdecompress" = "xy" ]
then
  echo "=====SKIP moya2/filecheck.dwo, count 2, compression(2)"
  skipcount=`expr $skipcount +  2`
else
  # DWARF5 test, new 17 June 2020.
  runtest $d1 $d2 moya2/filecheck.dwo -a -M
  runtest $d1 $d2 moya2/filecheck.dwo -a -vvv -M
fi

# sample object with DW_AT_containing type in a use
# which is standard
runtest $d1 $d2 encisoa/DW_AT_containing_type.o --check-tag-attr
runtest $d1 $d2 encisoa/DW_AT_containing_type.o --check-tag-attr --format-extensions

# PE basic tests.
runtest $d1 $d2 pe1/libexamine-0.dll --print-all
runtest $d1 $d2 pe1/libexamine-0.dll --print-info --format-attr-name --format-global-offsets
runtest $d1 $d2 pe1/libexamine-0.dll --print-info --format-attr-name -vvv
runtest $d1 $d2 pe1/libexamine-0.dll --print-strings

runtest $d1 $d2 pe1/kask-dwarfdump_64.exe --print-all
runtest $d1 $d2 pe1/kask-dwarfdump_64.exe --print-info --format-attr-name -vvv
runtest $d1 $d2 pe1/kask-dwarfdump_64.exe --no-follow-debuglink --print-all
runtest $d1 $d2 pe1/kask-dwarfdump_64.exe  --no-follow-debuglink --print-info --format-attr-name -vvv

# mach-o basic tests.
runtest $d1 $d2 macho-kask/simplereaderi386   -a
runtest $d1 $d2 macho-kask/simplereaderi386   -b
runtest $d1 $d2 macho-kask/simplereaderi386   -a -vvv
runtest $d1 $d2 macho-kask/simplereaderx86_64 -a
runtest $d1 $d2 macho-kask/simplereaderx86_64 -b
runtest $d1 $d2 macho-kask/simplereaderx86_64 -a -vvv
# The following 2 should give the same output as the first,
# in spite of naming a simple text placeholder.
# now the mach-o-object32/63 placeholders are useless.
#runtest $d1 $d2 macho-kask/mach-o-object32    -a
#runtest $d1 $d2 macho-kask/mach-o-object32    -a  -vvv
#runtest $d1 $d2 macho-kask/mach-o-object64    -a
#runtest $d1 $d2 macho-kask/mach-o-object64    -a  -vvv
# This is G4 big-endian with dSYM
runtest $d1 $d2 macho-kask/dwarfdump_G4    -a  -vvv

# the following have a DWARF section the last
# section. _64 failed. Now fixed in libdwarf.
runtest $d1 $d2  macho-kask/dwarfdump_32 -a
#This finds no dwarf, as instructed
runtest $d1 $d2  macho-kask/dwarfdump_32 -a --no-follow-debuglink
runtest $d1 $d2  macho-kask/dwarfdump_64 -a
#This finds no dwarf, as instructed
runtest $d1 $d2  macho-kask/dwarfdump_64 -a --no-follow-debuglink

# Vulnerability CVE-2017-9998 in libdwarf
runtest $d1 $d2   wolff/POC1 -a
runtest $d1 $d2   wolff/POC1 -b

#Show the usage options list
runtest $d1 $d2 foo.o -h
runtest $d1 $d2 foo.o --help
# Some errors in options list use, which
# should not show the options list
runtest $d1 $d2 foo.o  -j
runtest $d1 $d2 foo.o -x unknown
runtest $d1 $d2 foo.o --unknown-longopt
runtest $d1 $d2 foo.o -M  -M

# This has right idea in .debug_str_offsets, but wrong table length.
runtest $d1 $d2 enciso8/test-clang-dw5.o -s --print-str-offsets
# This has a correct table (new clang, soon will be available).
runtest $d1 $d2 enciso8/test-clang-wpieb-dw5.o -s --print-str-offsets

# These have .debug_str_offsets sections, but they are empty
# or bogus (created from a draft, not final, DWARF5, I think)
# so do not expect much output.
runtest $d1 $d2 emre3/a.out.dwp --print-str-offsets
runtest $d1 $d2 emre3/foo.dwo --print-str-offsets
runtest $d1 $d2 emre3/main.dwo --print-str-offsets
runtest $d1 $d2 emre5/test33_64_opt_fpo_split.dwp
runtest $d1 $d2 emre6/class_64_opt_fpo_split.dwp
if [  $platform = "msys2" ]
then
  echo "=====SKIP debuglink on msys2"
  skipcount=`expr $skipcount +  3 `
else
  runtest $d1 $d2 emre6/class_64_opt_fpo_split --print-gnu-debuglink
fi

runtest $d1 $d2  sarubbo-3/1.crashes.bin -a -b

# This is an object with both dwo and non-dwo sections.
# It's not correct, but it at least has both groups
# The first should pick up group 1.
runtest $d1 $d2   camp/empty.o -a
# The second should show a little bit.
runtest $d1 $d2   camp/empty.o -a -x groupnumber=2

# DW201712-001: Was failing to check augmentation length for fde.
runtest $d1 $d2   sarubbo-10/1.crashes.bin -a -b -d -e -f -F -g -G -i -I \
 -m -M -N -p -P -R -r -s -ta -w -y

# These all involved bounds violations so should error off
# fairly early.
runtest $d1 $d2   marcel/crash1 -a
runtest $d1 $d2   marcel/crash2 -a
runtest $d1 $d2   marcel/crash3 -a
runtest $d1 $d2   marcel/crash4 -a
runtest $d1 $d2   marcel/crash5 -a
runtest $d1 $d2   marcel/crash6 -a
runtest $d1 $d2   marcel/crash7 -a

# Got DW_DLE_RELOC_SECTION_RELOC_TARGET_SIZE_UNKNOWN due to
# presence of unexpected R_X86_64_PC32
runtest $d1 $d2   convey/foo.g3-O0-strictdwarf.o -F

# Before 4 March 2017 would terminate early with error.
runtest $d1 $d2   emre6/class_64_opt_fpo_split.dwp -a
# the fix had no effect on this, which works ok.
runtest $d1 $d2   emre6/class_64_opt_fpo_split -a

echo "=====START  $testsrc/hughes2 runtest.sh $testsrc/corruptdwarf-a/simplereader.elf good=$goodcount skip=$skipcount fail=$failcount"
  mklocal hughes2
    sh $testsrc/hughes2/runtest.sh $testsrc/corruptdwarf-a/simplereader.elf
    chkres $?  $testsrc/hughes2
  cd ..

# Tests with dwarfgen --add-language-version (new July 2025) 
#  --add-implicit-const --add-sun-func-offsets  
if [  $platform = "msys2" ]
then
  echo "=====SKIP implicitconst runtest.sh on msys2"
  skipcount=`expr $skipcount +  1 `
else
  echo "=====START   $testsrc/implicitconst sh runtest.sh \
    good=$goodcount skip=$skipcount fail=$failcount"
  mklocal implicitconst
    sh $testsrc/implicitconst/runtest.sh
    chkres $?  $testsrc/implicitconst/runtest.sh
  cd ..
fi

if [  $platform = "msys2" ]
then
  echo "=====SKIP debuglink on msys2"
  skipcount=`expr $skipcount +  1 `
else
  echo "=====START  $testsrc/nolibelf/runtest.sh good=$goodcount skip=$skipcount  fail=$failcount"
  mklocal nolibelf
    sh $testsrc/nolibelf/runtest.sh
    chkres $?  $testsrc/nolibelf/runtest.sh
  cd ..
fi

# All the following have been fuzzed and some have
# elf that is so badly damaged it is unusable.
# 08,09,12,14,16 in particular have really bad elf header data.
runtest $d1 $d2   sarubbo/01.hangs -a
runtest $d1 $d2   sarubbo/02.hangs -a
runtest $d1 $d2   sarubbo/03.hangs -a
runtest $d1 $d2   sarubbo/04.hangs -a
runtest $d1 $d2   sarubbo/05.hangs -a
runtest $d1 $d2   sarubbo/06.hangs -a
runtest $d1 $d2   sarubbo/07.hangs -a
runtest $d1 $d2   sarubbo/08.hangs -a
runtest $d1 $d2   sarubbo/09.hangs -a
runtest $d1 $d2   sarubbo/10.hangs -a
runtest $d1 $d2   sarubbo/11.hangs -a
runtest $d1 $d2   sarubbo/12.hangs -a
runtest $d1 $d2   sarubbo/13.hangs -a
runtest $d1 $d2   sarubbo/14.hangs -a
runtest $d1 $d2   sarubbo/15.hangs -a
runtest $d1 $d2   sarubbo/17.hangs -a
# test2.crashes has bad elf. With Ubuntu 16.04 libelf
# libelf detects an error in .debug_ranges so libdwarf
# reports error and dwarfdump stops. -fsanitize= detects errors too.
# Building latest libelf my self from
# https://launchpad.net/ubuntu/+source/libelf
# the libelf error is detected but there are no -fsanitize= errors
# detected.
runtest $d1 $d2   sarubbo/test2.crashes -a
# Exposed failure to check off-end in abbreviation reading, corrupted dWARF.
runtest $d1 $d2   sarubbo/test122.crashes -a

# These exposed weaknesses in decoding frame data in dwarfdump.
runtest $d1 $d2   sarubbo-11/testcase1.bin -a
runtest $d1 $d2   sarubbo-11/testcase2.bin -a
runtest $d1 $d2   sarubbo-11/testcase3.bin -a
runtest $d1 $d2   sarubbo-11/testcase4.bin -a
runtest $d1 $d2   sarubbo-11/testcase4.bin -ka
runtest $d1 $d2   sarubbo-11/testcase5.bin -a

# Object file die runs off end of die
runtest $d1 $d2   puzzor/heap_buf_overflow.o -a

# Fuzzed objects, each of which resulted in a specific out of bounds memory access.
if [ x$withlibz = "xno" ]
then
  echo "=====SKIP sarubbno-2 COMPRESSED test, no libz available(1)"
  skipcount=`expr $skipcount +  1 `
else
  runtest $d1 $d2 sarubbo-2/00024-libdwarf-memalloc-do_decompress_zlib -a
fi
runtest $d1 $d2 sarubbo-2/00025-libdwarf-heapoverflow-get_attr_value -a
runtest $d1 $d2 sarubbo-2/00026-libdwarf-heapoverflow-dwarf_get_aranges_list -a
runtest $d1 $d2 sarubbo-2/00027-libdwarf-heapoverflow-_dwarf_skim_forms -a

# With pre-Nov 11 dwarf_leb.c there are undefined operations
# in signed leb reading.
runtest $d1 $d2 sarubbo-2/00050-libdwarf-negate-itself -a

# This exposed a different off-end in abbrev reading.
runtest $d1 $d2   sarubbo/1112.crashes -a

# The test case has a circular typedef.
# It provokes various -ka warnings.
runtest $d1 $d2 parodi/TestA2l.elf -a
runtest $d1 $d2 parodi/TestA2l.elf -ka

# Exposed failure to check DW_FORM_string in _dwarf_get_size_of_val(),
# which is the real contribution of this fuzzed-object testcase.
# Libelf as of Ubuntu 16.04  will try to malloc an absurd
# section size of # 0x8000000110 for .debug_abbrev.
# That is, of course, way larger than the actual size of the object file.
runtest $d1 $d2   sarubbo/test433.crashes -a

# Testing DW201609-001 vulnerability.
# This will pass. Valid dwarf.
runtest $d1 $d2   DW201609-001/test1.o -i
# This will get an error, the object was patched
# to demonstrate the vulnerability is fixed.
# The reported error should be DW_DLE_SIBLING_LIST_IMPROPER
runtest $d1 $d2   DW201609-001/test2.o -i
# The reported error should be DW_DLE_SIBLING_LIST_IMPROPER
runtest $d1 $d2   DW201609-001/DW201609-001-poc  -i

# Should report line table botch DW_DLE_LINE_TABLE_BAD
# corrupt dwarf.
runtest $d1 $d2   DW201609-004/poc  -i -l
runtest $d1 $d2   DW201609-004/poc  -l
# corrupt dwarf.
runtest $d1 $d2   DW201609-003/poc  -i
# corrupt dwarf.
runtest $d1 $d2   DW201609-002/DW201609-002-poc  -i

# Testing DW_AT_discr_list
runtest $d1 $d2  grumbach/Test_ODB_Ada_record_types09_pkg_.o -i
runtest $d1 $d2  grumbach/Test_ODB_Ada_record_types09_pkg_.o -i -vvv
runtest $d1 $d2  grumbach/test2.o -i -vvv
runtest $d1 $d2  grumbach/test_odb_ada_record_types12_pkg_.o -i -vvv
runtest $d1 $d2  grumbach/test4.o -i -vvv
# Testing DW_AT_GNU_numerator, DW_AT_GNU_denominator and
# DW_AT_GNU_bias DWARF attributes.
runtest $d1 $d2  grumbach/test_bias.o -i -vvv
runtest $d1 $d2  grumbach/test_fixed.o -i -vvv
runtest $d1 $d2  grumbach/test_bias.o -ka
runtest $d1 $d2  grumbach/test_fixed.o -ka

# The object has a bad ELF section type. So should
# generate an error.  Should not coredump.
runtest $d1 $d2  xqx/awbug6.elf -i

# This test has odd abbreviation codes. See that we notice them.
runtest $d1 $d2  xqx-b/aw.elf -kb
runtest $d1 $d2  xqx-b/aw.elf -ka
runtest $d1 $d2  xqx-b/aw.elf -a
runtest $d1 $d2  xqx-b/aw.elf -f
runtest $d1 $d2  xqx-b/aw.elf -F
runtest $d1 $d2  xqx-b/awbug5.elf -kb
runtest $d1 $d2  xqx-b/awbug5.elf -ka
runtest $d1 $d2  xqx-b/awbug5.elf -a
runtest $d1 $d2  xqx-b/awbug5.elf -f
runtest $d1 $d2  xqx-b/awbug5.elf -F

runtest $d1 $d2  xqx-c/awbug6.elf -a

# Corrupted object files
runtest $d1 $d2  liu/divisionbyzero02.elf -a
runtest $d1 $d2  liu/divisionbyzero.elf -a
runtest $d1 $d2  liu/free_invalid_address.elf -a
runtest $d1 $d2  liu/heapoverflow01b.elf -a
runtest $d1 $d2  liu/heapoverflow01.elf -a
runtest $d1 $d2  liu/HeapOverflow0513.elf -a
runtest $d1 $d2  liu/infinitloop.elf -a
runtest $d1 $d2  liu/null01.elf -a
runtest $d1 $d2  liu/null02.elf -a
runtest $d1 $d2  liu/NULLdereference0522.elf -a
runtest $d1 $d2  liu/NULLdeference0522c.elf -a
runtest $d1 $d2  liu/OOB0505_01.elf -a
runtest $d1 $d2  liu/OOB0505_02_02.elf -a
runtest $d1 $d2  liu/OOB0505_02.elf -a
runtest $d1 $d2  liu/OOB0517_01.elf -a

# OOB0517_02.elf has a bogus non-dwo section name
# Because of the bogosity in the sections
# one cannot run all tests on this, nothing
# useful happens.
runtest $d1 $d2  liu/OOB0517_02.elf -a
# There is a bogus .debug_str section, lets show it.
runtest $d1 $d2  liu/OOB0517_02.elf -s
# This skips group 1 , dwo (group 2) is more complete.
runtest $d1 $d2  liu/OOB0517_02.elf -a -x groupnumber=2

runtest $d1 $d2  liu/OOB0517_03.elf -a
runtest $d1 $d2  liu/OOB_read3_02.elf -a
runtest $d1 $d2  liu/OOB_read3.elf -a
runtest $d1 $d2  liu/OOB_READ0519.elf -a
runtest $d1 $d2  liu/outofbound01.elf -a
runtest $d1 $d2  liu/outofbound01.elf -ka
runtest $d1 $d2  liu/outofboundread2.elf -a
runtest $d1 $d2  liu/outofboundread.elf -a

#  For line table variants checking.
for x in '-x line5=std' '-x line5=s2l' '-x line5=orig' '-x line5=orig2l'
do
runtest $d1 $d2  sparc/tcombined.o -a -R  -v -v -v -v -v -v $x
runtest $d1 $d2  sparc/tcombined.o -a -R   -v  $x
runtest $d1 $d2  sparc/tcombined.o -a -R    $x
runtest $d1 $d2  x86/dwarfdumpv4.3 -a -R  -v -v -v -v -v -v $x
runtest $d1 $d2 legendre/libmpich.so.1.0 -ka  $x
runtest $d1 $d2 legendre/libmpich.so.1.0 -a  $x
runtest $d1 $d2 legendre/libmpich.so.1.0 -l  $x
runtest $d1 $d2 irixn32/dwarfdump -f -x name=./dwarfdump.conf   -x abi=mips $x
# This for code coverage of reading dwarfdump.conf
runtest $d1 $d2 irixn32/dwarfdump -f -x name=./dwarfdump.conf   -x abi=fakeabi $x
runtest $d1 $d2  ppc2/powerpc-750-linux-gnu-hello-static -a   -R -v -v -v -v -v -v  $x
runtest $d1 $d2  mucci/main.o -R -ka  -v -v -v -v -v -v $x
done

runtest $d1 $d2 augmentation/a.out -f
runtest $d1 $d2 augmentation/a.out -f  -vvv
runtest $d1 $d2 corruptdwarf-a/simplereader.elf -i
runtest $d1 $d2 corruptdwarf-a/simplereader.elf -a
runtest $d1 $d2 corruptdwarf-a/simplereader.elf -a  -vvv

runtest $d1 $d2 irixn32/dwarfdump -i -x name=./dwarfdump.conf -x abi=mips -g

# Test support for DW_FORM_GNU_strp_alt
runtest $d1 $d2 hughes/libkrb5support.so.0.1.debug -i  -l -M -x -file-tied=$testsrc/hughes/krb5-1.11.3-38.fc20.x86_64

# for two-level line tables
runtest $d1 $d2 emre4/test19_64_dbg -l
runtest $d1 $d2 emre4/test19_64_dbg -a
runtest $d1 $d2 emre4/test19_64_dbg -ka
runtest $d1 $d2 emre4/test3_64_dbg -l
runtest $d1 $d2 emre4/test3_64_dbg -a
runtest $d1 $d2 emre4/test3_64_dbg -ka
runtest $d1 $d2 emre4/test19_64_dbg -l -vvv
runtest $d1 $d2 emre4/test19_64_dbg -a -vvv
runtest $d1 $d2 emre4/test19_64_dbg -ka -vvv
runtest $d1 $d2 emre4/test3_64_dbg -l -vvv
runtest $d1 $d2 emre4/test3_64_dbg -a -vvv
runtest $d1 $d2 emre4/test19_64_dbg -l -v
runtest $d1 $d2 emre4/test19_64_dbg -a -v
runtest $d1 $d2 emre4/test19_64_dbg -ka -v
runtest $d1 $d2 emre4/test3_64_dbg -l -v
runtest $d1 $d2 emre4/test3_64_dbg -a -v
runtest $d1 $d2 emre4/test3_64_dbg -ka -v

# This one has .debug_cu_index
# Some duplication with generic test loop.
runtest $d1 $d2 emre3/a.out.dwp -i
runtest $d1 $d2 emre3/a.out.dwp -i -v
runtest $d1 $d2 emre3/a.out.dwp -i -d
runtest $d1 $d2 emre3/a.out.dwp -i -d -v
runtest $d1 $d2 emre3/a.out.dwp -I

# This one should show the attr/form pairs ok.
runtest $d1 $d2 duplicatedattr/duplicated_attributes.o --no-dup-attr-check -i -O file=./testOfile
# This one should be short, getting an error due to duplicates.
runtest $d1 $d2 duplicatedattr/duplicated_attributes.o -i -O file=./testOfile
# For the rest ignore the dups and print all indetail.
runtest $d1 $d2 duplicatedattr/duplicated_attributes.o --no-dup-attr-check  -kD
runtest $d1 $d2 duplicatedattr/duplicated_attributes.o --no-dup-attr-check -kG
runtest $d1 $d2 duplicatedattr/duplicated_attributes.o --no-dup-attr-check -ku
runtest $d1 $d2 duplicatedattr/duplicated_attributes.o --no-dup-attr-check -ku -kuf
#
# These are testing  some mangled objects for
# sensible output. We do not want a core dump.
runtest $d1 $d2 williamson/heap_buffer_overflow.exe -i -G
runtest $d1 $d2 williamson/hbo_unminimized.exe -i -G
runtest $d1 $d2 williamson/heap_buffer_overflow_01.exe -i
# The following has a bad info value in a rela. Coredumped dwarfdump.
runtest $d1 $d2 williamson/heap_vulnerability_20150201 -i

# duplicatedattr test dir has stuff to test. FIXME

# This should not coredump dwarfdump. Did as of Jan 1, 2015
runtest $d1 $d2 comdatex/example.o -i
runtest $d1 $d2 comdatex/example.o -a -g -x groupnumber=2
runtest $d1 $d2 comdatex/example.o -a -g -x groupnumber=3

# Results are so large that if there are differences
# the diffs will take hours, allow ignoring these.
runtest $d1 $d2 debugfissionb/ld-new --check-tag-attr
runtest $d1 $d2 debugfissionb/ld-new --check-tag-attr --format-extensions
runtest $d1 $d2 debugfissionb/ld-new.dwp -I -v -v -v
runtest $d1 $d2 debugfissionb/ld-new --print-all-srcfiles
runtest $d1 $d2 debugfissionb/ld-new.dwp --print-all-srcfiles


# Check that we get mmap used/not on  a large-ish object.
runtest $d1 $d2 debugfissionb/ld-new -i --allocate-via-mmap --print-section-allocations
runtest $d1 $d2 debugfissionb/ld-new -i --print-section-allocations


if [ "x$withlibz" = "xno" -o "x$skipdecompress" = "xy" ]
then
  echo "=====SKIP klingler2/compresseddebug.amd64(3)"
  skipcount=`expr $skipcount +  3 `
else
  # Testing SHF_COMPRESSED .debug* section reading.
  runtest $d1 $d2  klingler2/compresseddebug.amd64 -i
  runtest $d1 $d2  klingler2/compresseddebug.amd64 -a
  # .eh_frame is not actually compressed...
  runtest $d1 $d2  klingler2/compresseddebug.amd64 -F
fi

# A big object.
if [ "x$skipbigobjects" = "xn" ]
then
  runtest $d1 $d2 debugfissionb/ld-new.dwp -i -v -v -v
  runtest $d1 $d2 debugfissionb/ld-new.dwp -ka
  runtest $d1 $d2 debugfissionb/ld-new.dwp -i -x tied=$testsrc/debugfissionb/ld-new
  runtest $d1 $d2 debugfissionb/ld-new.dwp -a -x tied=$testsrc/debugfissionb/ld-new
  runtest $d1 $d2 debugfissionb/ld-new -I
  runtest $d1 $d2 debugfissionb/ld-new -a
  echo "Testing -i --format-expr-ops-joined . a -d for exprs"
  runtest $d1 $d2  debugfissionb/ld-new -i --format-expr-ops-joined
  runtest $d1 $d2  debugfissionb/ld-new -ka
else
  echo "======SKIP BIG OBJects ld-new (8)"
  skipcount=`expr $skipcount +  8`
fi
runtest $d1 $d2  emre4/test19_64_dbg --file-name=./testdwarfdump.conf  -i -v

# A very short debug_types file. Used to result in error due to bug.
runtest $d1 $d2 emre/input.o -a

# Has a type unit so we can see the index for such.
runtest $d1 $d2 emre2/emre.ex -I
if [  $platform = "msys2" ]
then
  echo "=====SKIP debuglink on msys2"
  skipcount=`expr $skipcount +  1 `
else
  runtest $d1 $d2 emre2/emre.ex --print-gnu-debuglink
fi

runtest $d1 $d2  emre5/test33_64_opt_fpo_split.dwp  -v -a -M -x tied=$testsrc/emre5/test33_64_opt_fpo_split
runtest $d1 $d2  emre5/test33_64_opt_fpo_split.dwp  -ka -x tied=$testsrc/emre5/test33_64_opt_fpo_split

if [  $platform = "msys2" ]
then
  echo "=====SKIP baddie1 on msys2"
  skipcount=`expr $skipcount +  1 `
else
  echo "=====START  $testsrc/baddie1/runtest.sh good=$goodcount skip=$skipcount fail=$failcount"
  mklocal baddie1
  sh $testsrc/baddie1/runtest.sh ../$d2
  chkres $?  $testsrc/baddie1
  cd ..
fi

  # Also tests dwarfgen and libdwarf with DW_CFA_advance_loc
  # operations
echo "=====START  $testsrc/offsetfromlowpc/runtest.sh good=$goodcount skip=$skipcount fail=$failcount"
if [ $dwarfgenok = "n" ]
then
  echo "====SKIP run offsetfromlowpc (1)"
  skipcount=`expr $skipcount +  1 `
else
  mklocal offsetfromlowpc
    sh $testsrc/offsetfromlowpc/runtest.sh
    chkres $?  $testsrc/offsetfromlowpc/runtest.sh
  cd ..
fi

echo "=====START  $testsrc/strsize/runtest.sh good=$goodcount skip=$skipcount fail=$failcount"
if [ $dwarfgenok = "n" ]
then
  echo "====SKIP run strsize (1)"
  skipcount=`expr $skipcount +  1 `
else
  mklocal strsize
    sh $testsrc/strsize/runtest.sh
    chkres $? $testsrc/strsize
  cd ..
fi
# tests simple reader and more than one dwarf_init* interface
# across all object types
# here kaufmann/t.o is tested as input to simplereader.
if [  $platform = "msys2" ]
then
  echo "====SKIP debugfissionb runtest.sh(1)"
  skipcount=`expr $skipcount +  1 `
else
  echo "=====START $testsrc/debugfissionb runtest.sh ../simplereader good=$goodcount skip=$skipcount fail=$failcount"
  mklocal debugfissionb
    sh $testsrc/debugfissionb/runtest.sh
    chkres $?  $testsrc/debugfissionb-simplreader
  cd ..
fi

echo "=====START $testsrc/debugfission runtest.sh ../$d2 good=$goodcount skip=$skipcount fail=$failcount"
okzcat=y
ourzcat=zcat
which zcat 1>/dev/null
if [ $? -ne 0 ]
then
    echo "zcat missing, unavailable"
    okzcat=n
fi
# Prefer gzcat if present (Macos)
which gzcat 1>/dev/null
if [ $? -eq 0 ]
  then
  # On MacOS gzcat does what zcat does on Linux.
  echo "Using gzcat"
  ourzcat=gzcat
  okzcat=y 
fi

if [ $okzcat = "n"  -o $platform = "msys2" ]
then
  echo "====SKIP run debugfission/runtest.sh no zcat or gzcat (or is msys2) "
  skipcount=`expr $skipcount +  5 `
else
  mklocal debugfission
    sh $testsrc/debugfission/runtest.sh  ../$d2
    r=$?
    if [ $r -eq 0 ]
    then
      goodcount=`expr $goodcount + 5`
    else 
      echo "FAIL DEBUGFISSION/runtest.sh"
      failcount=`expr $failcount + 5`
    fi
    chkres $r  "$testsrc/debugfission/runtest.sh ../$d2"
  cd ..
fi

if [ $platform = "msys2" -o $dwarfgenok = "n"  ]
then
  echo "====SKIP run data16 runtest.sh (1)"
  skipcount=`expr $skipcount +  1 `
else
  echo "=====START  $testsrc/data16 runtest.sh ../$d2 good=$goodcount skip=$skipcount fail=$failcount"
  mklocal data16
    sh $testsrc/data16/runtest.sh
    chkres $?  "$testsrc/data16/runtest.sh"
  cd ..
fi

if [ $nlize = 'n' ]
then
  runtest $d1 $d2  sarubbo-8/1.crashes.bin  -a -b -d -e -f -F -g -G -i -I -m -M -N -p -P -R -r -s -ta -w -y
else
  echo "=====SKIP  sarubbo-8 with NLIZE (1)"
  skipcount=`expr $skipcount + 1`
fi

if [ $nlize = 'n' ]
then
  runtest  $d1 $d2   sarubbo-9/3.crashes.bin -a -b -d -e -f -F -g -G -i -I -m -M -N -p -P -R -r -s -ta -w -y
else
  echo "=====SKIP  sarubbo-9 with NLIZE (1)"
  skipcount=`expr $skipcount + 1`
fi

# This tries to use a nonexistent file. So we see the dwarfdump fail message.
runtest $d1 $d2 nonexistentobj.o -i

# This validates standard-based handling of DW_FORM_ref_addr
runtest $d1 $d2 diederen/hello -i

# this coredumps libdwarf 20121130
runtest $d1 $d2 libc6fedora18/libc-2.16.so.debug -a

# Testing the wasted-space from not using LEB.
runtest $d1 $d2 enciso5/sample_S_option.o  -kE

# AARCH64 Arm 64bit.
runtest $d1 $d2 juszkiewicz/t1.o -a
runtest $d1 $d2 juszkiewicz/t2.o -a -v
runtest $d1 $d2 juszkiewicz/tcombined.o -a

# Prints DIEs with the name or value DW_AT_low_pc
runtest $d1 $d2 enciso5/sample_S_option.o  -S match=DW_AT_low_pc
runtest $d1 $d2 enciso5/sample_S_option.o  -S match=DW_AT_low_pc -W
runtest $d1 $d2 enciso5/sample_S_option.o  -S vmatch=DW_AT_low_pc
runtest $d1 $d2 enciso5/sample_S_option.o  -S vmatch=DW_AT_low_pc -W

# Prints DIEs with the name or value DW_AT_high_pc
runtest $d1 $d2 enciso5/sample_S_option.o  -S match=DW_AT_high_pc
# Prints DIEs with the name or value 0x0000001c
runtest $d1 $d2 enciso5/sample_S_option.o  -S match=0x0000001c
# Prints DIEs with the name or value value DW_OP_plus
runtest $d1 $d2 enciso5/sample_S_option.o  -S any=DW_OP_plus
# Following is for URI testing.
runtest $d1 $d2 enciso5/sample_S_option.o  -S any=DW%5fOP_plus
# The following should work with a space but
# does not because the shell strips quotes and getopt() won't process
# the space-containing single option properly even if quoted.
# So we use uri-style.
# Following is for URI testing.
runtest $d1 $d2 enciso5/sample_S_option.o  -S match=DW_OP_plus_uconst%208
# The following prints any DIE with name or value containing  anything
# in the range reg0 through reg9.
runtest $d1 $d2 enciso5/sample_S_option.o  -S regex="reg[0-9]"
# Following is for URI testing
runtest $d1 $d2 enciso5/sample_S_option.o  -S regex="reg%5b0-9]"
# The following prints a single DIE, just basic information about it.
runtest $d1 $d2 enciso5/sample_W_option.o  -S match=gg
# With -W, both parent and child data about the DIE is printed.
runtest $d1 $d2 enciso5/sample_W_option.o  -S match=gg -W
# With -W, just parent data about the DIE is printed.
runtest $d1 $d2 enciso5/sample_W_option.o  -S match=gg -Wp
# With -W, just children data about the DIE is printed.
runtest $d1 $d2 enciso5/sample_W_option.o  -S match=gg -Wc

# The next are on the clang compiler v 2.9, which is making some mistakes.
runtest $d1 $d2 vlasceanu/a.out -i -M
runtest $d1 $d2 vlasceanu/a.out -a
runtest $d1 $d2 vlasceanu/a.out -ka

# Put uri in name. We don't do uri conversion on the input
# so these fail.
# Following is for URI testing
runtest $d1 $d2 moshe%2fhello  -i
#Put uri in name, let it fail as no translate done.
# Following is for URI testing and is supposed to fail
# as we suppress uri translation with -U. So it
# will fail to print anything but cannot-find-file.
runtest $d1 $d2 moshe%2fhello  -U -i
# same but with long option
runtest $d1 $d2 moshe%2fhello  --format-suppress-uri -i
#Put uri in name, do not mention the uri translatetion
# Following is for URI testing and it prints DWARF.
runtest $d1 $d2 moshe%2fhello  -q -i

# The -h option exists now
runtest $d1 $d2  moshe/hello -h
runtest $d1 $d2  moshe/hello -a -vvv -R -M
runtest $d1 $d2  moshe/hello -a -vvv -R -M -g
runtest $d1 $d2  moshe/hello -ka -vvv -R -M
runtest $d1 $d2  moshe/a.out.t -a -vvv -R -M
runtest $d1 $d2  moshe/a.out.t -ka -vvv -R -M

# Some of these are the same tests done based on $filelist
runtest $d1 $d2  dwarf4/ddg4.5dwarf-4-gdb-index --print-fission
runtest $d1 $d2  dwarf4/dd2g4.5dwarf-4 -a  -vvv -R -M
runtest $d1 $d2  dwarf4/dd2g4.5dwarf-4 -ka -vvv -R -M
runtest $d1 $d2  dwarf4/ddg4.5dwarf-4 -a  -vvv -R -M
runtest $d1 $d2  dwarf4/ddg4.5dwarf-4 -ka -vvv -R -M
runtest $d1 $d2  dwarf4/ddg4.5dwarf-4 -ku
runtest $d1 $d2  dwarf4/ddg4.5dwarf-4 -ku -kuf
# ka p, where we test a warning message is generated
# (p is printing option)
# And should run like just -p (as of Jan 2015 erroneously
# did many checks).
runtest $d1 $d2  dwarf4/ddg4.5dwarf-4 -ka -p  -R -M
# normal ka, full checks
runtest $d1 $d2  dwarf4/ddg4.5dwarf-4 -ka  -R -M
# ka P, where P means print CU names per compiler.
runtest $d1 $d2  dwarf4/ddg4.5dwarf-4 -ka -P  -R -M
# ka P kd, where so print CU names and error summary per compiler
runtest $d1 $d2  dwarf4/ddg4.5dwarf-4 -ka -kd -P  -R -M
runtest $d1 $d2  dwarf4/ddg4.5dwarf-4 -i
runtest $d1 $d2  dwarf4/ddg4.5dwarf-4 -i -g
runtest $d1 $d2  dwarf4/ddg4.5dwarf-4 -i -d
runtest $d1 $d2  dwarf4/ddg4.5dwarf-4 -i -d -v

runtest $d1 $d2  marinescu/hello.original -ka -x abi=ppc
# Following is for URI testing
runtest $d1 $d2  marinescu/hello%2eoriginal -ka -x abi=pp%63
runtest $d1 $d2  marinescu/hello.original -a -x abi=ppc
runtest $d1 $d2  marinescu/armcc-test-dwarf2.original -ka -x abi=ppc
runtest $d1 $d2  marinescu/armcc-test-dwarf2.original -a -x abi=ppc
runtest $d1 $d2  marinescu/tcombined.o.div -a
runtest $d1 $d2  marinescu/tcombined.o.seg -a
runtest $d1 $d2  marinescu2/dwarfdump-invalid-read -a
runtest $d1 $d2  marinescu2/hello.o.div -a

# The following 3 print the lines  differently.
# The first prints a shorthand for file path.
# The second a filepath for each line
# The third prints details on the line operators.
# In these 3 the name is long, so -l and -l -v print differently.
runtest $d1 $d2  wynn/unoptimised.axf -l
runtest $d1 $d2  wynn/unoptimised.axf -l -v
runtest $d1 $d2  wynn/unoptimised.axf -l -vvv
# These have short names, so -l -v prints like -l  prints.
runtest $d1 $d2  mucci/stream.o -l
runtest $d1 $d2  mucci/stream.o -l  -v
runtest $d1 $d2  mucci/stream.o -l  -vvv

# currently generates DW_DLE_LINE_FILE_NUM_BAD
# due to gcc bug in line output.
runtest $d1 $d2  moore/djpeg.v850 -l -R

runtest $d1 $d2  enciso2/template.elf -a -vvv -R -M
runtest $d1 $d2  enciso2/template.elf -a -R -M
runtest $d1 $d2  enciso2/template.elf -a -R -M -g
runtest $d1 $d2  enciso2/template.elf -ka -R -M
runtest $d1 $d2  enciso2/template.elf -ka -kxe -R -M
runtest $d1 $d2  enciso2/template.elf -kxe -R -M
runtest $d1 $d2  enciso2/test_templates.o  -a -R -M
runtest $d1 $d2  enciso2/test_templates.o  -a -R
runtest $d1 $d2  enciso2/test_templates.o  --print-pubnames
runtest $d1 $d2  x86/dwarfdumpv4.3 -S match=main
runtest $d1 $d2  x86/dwarfdumpv4.3 -S any=leb
runtest $d1 $d2  x86/dwarfdumpv4.3 -S 'regex=u.*leb'
runtest $d1 $d2  wynn/unoptimised.axf  -f   -x abi=arm
runtest $d1 $d2  wynn/unoptimised.axf  -kf  -x abi=arm
runtest $d1 $d2  arm/armcc-test-dwarf2 -f   -x abi=arm
runtest $d1 $d2  arm/armcc-test-dwarf2 -ka  -x abi=arm
runtest $d1 $d2  arm/armcc-test-dwarf2 -ka -kxe -x abi=arm
runtest $d1 $d2  arm/armcc-test-dwarf2 -kxe -x abi=arm
runtest $d1 $d2  arm/armcc-test-dwarf3 -f  -x abi=arm
runtest $d1 $d2  arm/armcc-test-dwarf3 -ka  -x abi=arm
runtest $d1 $d2  arm/armcc-test-dwarf3 -ka  -kxe -x abi=arm
runtest $d1 $d2  arm/armcc-test-dwarf3 -kxe -x abi=arm
runtest $d1 $d2  lloyd/arange.elf  -r
runtest $d1 $d2  lloyd/arange.elf  -kr

# With mips abi and C dwarfdump we get error
# DW_DLE_FRAME_REGISTER_UNREPRESENTABLE.  That is normal, expected.
# It is not MIPS and MIPS is just wrong here.  Testing it anyway!
runtest $d1 $d2  val_expr/libpthread-2.5.so -x abi=mips -F -v -v -v
if [ $platform = "msys2" ]
then
  echo "====SKIP run findcu runtest.sh (1)"
  skipcount=`expr $skipcount +  1 `
else
  echo "=====START  $testsrc/findcu/runtest.sh "good=$goodcount skip=$skipcoun fail=$failcountt
  mklocal findcu
    sh $testsrc/findcu/runtest.sh   
    chkres $? "$testsrc/findcu/cutest-of-a-libdwarf-interface"
  cd ..
fi

if [ $platform = "msys2" -o $dwarfgenok = "n"  ]
then
  echo "====SKIP run dwgena/runtest.sh  not dwarfgenok or is msys2 "
  skipcount=`expr $skipcount +  1 `
else 
  echo "====$START   $testsrc/dwgena/runtest.sh ../$d2 good=$goodcount skip=$skipcount fail=$failcount"
  mklocal dwgena
    sh $testsrc/dwgena/runtest.sh
    r=$?
    chkres $r '$testsrc/dwgena/runtest.sh'
  cd ..
fi

echo "=====START   $testsrc/dwgenc/runtest.sh good=$goodcount skip=$skipcount fail=$failcount"
if [ $dwarfgenok = "n" ]
then
  echo "====SKIP run dwgenc  (1)"
  skipcount=`expr $skipcount +  1 `
else
  mklocal dwgenc
    sh $testsrc/dwgenc/runtest.sh
    r=$?
    chkresn $r "$testsrc/dwgenc/runtest.sh" 1
  cd ..
fi

echo "=====START   $testsrc/sandnes2/runtest.sh good=$goodcount skip=$skipcount fail=$failcount"
mklocal sandnes2
  sh $testsrc/sandnes2/runtest.sh
  r=$?
  chkres $r  $testsrc/sandnes2
cd ..

if [ $platform = "msys2" ]
then
  echo "=====SKIP 1  msys2 $testsrc/legendre/runtest.sh NLIZE as it has leaks (1)"
  skipcount=`expr $skipcount +  1 `
else
  if [ $nlize = 'n' ]
  then
    echo "=====START $testsrc/legendre/runtest.sh  good=$goodcount skip=$skipcount  fail=$failcount"
    mklocal legendre
      sh $testsrc/legendre/runtest.sh  
      r=$?
      chkres $r  $testsrc/legendre
    cd ..
  else
    echo "=====SKIP 1  $testsrc/legendre/runtest.sh NLIZE as it has leaks (1)"
    skipcount=`expr $skipcount + 1`
  fi
fi

echo "=====START   $testsrc/enciso4/runtest.sh good=$goodcount skip=$skipcount fail=$failcount"
mklocal enciso4
  sh $testsrc/enciso4/runtest.sh
  chkres $?  $testsrc/enciso4
cd ..

# -g: use old dwarf loclist code.
runtest $d1 $d2 irixn32/dwarfdump -g  -x name=dwarfdump.conf \
     -x abi=mips
if [ $platform = "msys2" ]
then
  echo "====SKIP run test_simple_libfuncs h (1)"
  skipcount=`expr $skipcount +  1 `
else
  runsingle test_simple_libfuncs.base ./test_simple_libfuncs ./jitreader
fi
runsingle frame1-orig.base ./frame1/frame1  \
  $testsrc/frame1/frame1.orig
runsingle frame1-2018.base ./frame1/frame1 --stop-at-fde-n=10 \
   $testsrc/frame1/frame1.exe.2018-05-11
runsingle frame1-2018s.base ./frame1/frame1  --stop-at-fde-n=10 \
  --just-print-selected-regs \
  $testsrc/frame1/frame1.exe.2018-05-11
if [  $platform = "msys2" ]
then
  echo "=====SKIP debuglink on msys2"
  skipcount=`expr $skipcount +  2 `
else
  runsingle dwdebuglink-a.base ./dwdebuglink \
  "--add-debuglink-path=/exam/ple" \
  "--add-debuglink-path=/tmp/phony" $codedir/test/dummyexecutable

  runsingle dwdebuglink-b.base ./dwdebuglink \
  --no-follow-debuglink --add-debuglink-path=/exam/ple \
  --add-debuglink-path=/tmp/phony $codedir/test/dummyexecutable
fi

#runsingle test_dwnames.base ./test_dwnames \
#  -i $codedir/src/lib/libdwarf --run-self-test

runsingle fuzzmoy.base ./filelist/localfuzz_init_binary  \
   $testsrc/moya9/oob-repro
runsingle fuzzkal.base ./filelist/localfuzz_init_binary  \
   $testsrc/kaletta/test.o
runsingle fuzzpathkal.base ./filelist/localfuzz_init_path  \
   $testsrc/kaletta/test.o
runsingle fuzz40802.base ./filelist/localfuzz_init_binary  \
   $testsrc/ossfuzz40802/crash-3c238d58556b66f3e036a8a7a133b99470d539a
runsingle fuzz40802b.base ./filelist/localfuzz_init_binary  \
   $testsrc/ossfuzz40802/clusterfuzz-testcase-minimized-fuzz_init_binary-5538015955517440.fuzz
runsingle fuzz40624.base ./filelist/localfuzz_init_binary  \
   $testsrc/ossfuzz40674/clusterfuzz-testcase-minimized-fuzz_init_path-6557751518560256
if [ $platform = "msys2" ]
then
  echo "====SKIP run fuzzgoogle1.base fuzzgoogle1b.base (1)"
  skipcount=`expr $skipcount +  6 `
else
  runsingle fuzzgoogle1.base ./filelist/localfuzz_init_binary  \
    $testsrc/google1/crash-c7e04f405a39f3e92edb56c28180531b9b8211bd
  runsingle fuzzgoogle1b.base ./filelist/localfuzz_init_binary  \
    $testsrc/google1/crash-d8d1ea593642a46c57d50e6923bc02c1bbbec54d
  runsingle fuzzc-sun.base ./filelist/localfuzz_init_binary  \
    $testsrc/c-sun/poc
  runsingle fuzz201609.base ./filelist/localfuzz_init_binary  \
   $testsrc/DW201609-004/poc
  runsingle fuzzguil.base ./filelist/localfuzz_init_binary  \
   $testsrc/guilfanov2/double-free-poc

  runsingle fuzz201609b.base ./filelist/localfuzz_init_binary  \
    $testsrc/DW201609-002/DW201609-002-poc
  runsingle fuzz201690c.base ./filelist/localfuzz_init_binary  \
    $testsrc/DW201609-003/poc
fi
runsingle fuzz54724.base ./filelist/localfuzz_init_binary  \
  $testsrc/ossfuzz54724/clusterfuzz-54724-poc

runsingle fuzzpath40802.base ./filelist/localfuzz_init_path  \
   $testsrc/ossfuzz40802/crash-3c238d58556b66f3e036a8a7a133b99470d539a
runsingle fuzzpath40802b.base ./filelist/localfuzz_init_path  \
   $testsrc/ossfuzz40802/clusterfuzz-testcase-minimized-fuzz_init_binary-5538015955517440.fuzz
runsingle fuzzpath40624.base ./filelist/localfuzz_init_path  \
   $testsrc/ossfuzz40674/clusterfuzz-testcase-minimized-fuzz_init_path-6557751518560256
runsingle fuzzpathgoogle1.base ./filelist/localfuzz_init_path  \
   $testsrc/google1/crash-c7e04f405a39f3e92edb56c28180531b9b8211bd
runsingle fuzzpathgoogle1b.base ./filelist/localfuzz_init_path  \
   $testsrc/google1/crash-d8d1ea593642a46c57d50e6923bc02c1bbbec54d
runsingle fuzzpathc-sun.base ./filelist/localfuzz_init_path  \
   $testsrc/c-sun/poc
runsingle fuzzpath201609.base ./filelist/localfuzz_init_path  \
   $testsrc/DW201609-004/poc
runsingle fuzzpathguil.base ./filelist/localfuzz_init_path  \
   $testsrc/guilfanov2/double-free-poc
runsingle fuzzpath201609b.base ./filelist/localfuzz_init_path  \
  $testsrc/DW201609-002/DW201609-002-poc
runsingle fuzzpath201690c.base ./filelist/localfuzz_init_path  \
  $testsrc/DW201609-003/poc
runsingle fuzzpath54724.base ./filelist/localfuzz_init_path  \
  $testsrc/ossfuzz54724/clusterfuzz-54724-poc

if [  $platform = "msys2" ]
then 
  echo "====SKIP test_bitoffset on msys2"
  skipcount=`expr $skipcount +  1 `
else 
  runsingle test_bitoffseta.base ./test_bitoffset  \
    $testsrc/bitoffset/bitoffsetexampledw3.o \
    $testsrc/bitoffset/bitoffsetexampledw5.o  
fi

echo "platform : $platform"

if [ ! $platform = "macos" -a ! $platform = "msys2" ]
then
  runsingle test_harmlessb.base ./test_harmless $suppresstree
  runsingle test_harmlessc.base ./test_harmless $suppresstree  -f \
  $testsrc/testfindfuncbypc/findfuncbypc.exe1
else
  echo "====SKIP run test_harmless on macos count 2 (Darwin or Msys2) "
  skipcount=`expr $skipcount +  2 `
fi

runsingle test_sectionnames.base  ./test_sectionnames  \
    $testsrc/dwarf4/dd2g4.5dwarf-4

runsingle test_sectionnamesb.base ./test_sectionnames \
  $testsrc/testfindfuncbypc/findfuncbypc.exe1 \
  $testsrc/convey/testesb.c.o

runsingle test_arangeb.base ./test_arange  \
  $testsrc/irixn32/dwarfdump

if [ $platform = "msys2" ]
then
  echo "====SKIP run test_pubsreader on msys2  "
  skipcount=`expr $skipcount +  1 `
else
  runsingle test_pubsreaderb.base ./test_pubsreader  \
  $testsrc/irixn32/dwarfdump $testsrc/mustacchi/m32t.o
fi

runsingle test_jitreaderb.base ./jitreader

# Missing path
runsingle test_findfuncbypcb1.base ./findfuncbypc \
  --printdetails --pc=1
# pc not found
runsingle test_findfuncbypcb2.base ./findfuncbypc  \
  --printdetails --pc=1 $testsrc/testfindfuncbypc/findfuncbypc.exe1
# no output?
runsingle test_findfuncbypcb3.base ./findfuncbypc  \
  --printdetails $testsrc/testfindfuncbypc/findfuncbypc.exe1
if [ $platform = "msys2" ]
then 
  echo "====SKIP run findfunc --pc= on msys2  "
  skipcount=`expr $skipcount +  1 `
else 
  # pc not found
  runsingle test_findfuncbypcb4.base ./findfuncbypc  \
    --printdetails --pc=10000 $testsrc/testfindfuncbypc/findfuncbypc.exe1
  # should work
  runsingle test_findfuncbypcb5.base ./findfuncbypc  \
    --printdetails --pc=0x36a4 $testsrc/testfindfuncbypc/findfuncbypc.exe1
fi

runsingle test_simplereaderb.base ./simplereader \
  $testsrc/corruptdwarf-a/simplereader.elf
runsingle test_simplereaderb1.base ./simplereader \
  --names --check $testsrc/corruptdwarf-a/simplereader.elf
runsingle test_simplereaderb2.base ./simplereader \
  --passnullerror $testsrc/corruptdwarf-a/simplereader.elf
runsingle test_simplereaderb3.base ./simplereader \
  --use_init_fd $testsrc/corruptdwarf-a/simplereader.elf
#There is no output from the following as there is no
# .debug_types section to report on.
runsingle test_simplereaderb4.base ./simplereader \
  --isinfo=0 --use_init_fd $testsrc/corruptdwarf-a/simplereader.elf
# This has .debug_type
runsingle test_simplereaderb4b.base ./simplereader \
  --isinfo=0 --use_init_fd $testsrc/dwarf4/dd2g4.5dwarf-4

runsingle test_showsectiongroupsb.base  \
  ./showsectiongroups \
  $testsrc/debugfission/archive.o \
  $testsrc/debugfission/archive.dwo  \
  $testsrc/debugfission/target.o \
  $testsrc/debugfission/target.dwo
runsingle test_showsectiongroupsb1.base \
   ./showsectiongroups \
   "-group 1" $testsrc/debugfission/target.dwo
runsingle test_showsectiongroupsb4.base ./showsectiongroups \
  "-group 4" $testsrc/debugfission/archive.o \
  "-group 2" $testsrc/debugfission/archive.o

runsingle test_showsectiongroupsb0.base ./showsectiongroups \
  "-group 0" $testsrc/comdatex/example.o

runsingle test_showsectiongroupsc1.base ./showsectiongroups \
  "-group 1" $testsrc/comdatex/example.o

runsingle test_showsectiongroupsc2.base ./showsectiongroups \
  "-group 2" $testsrc/comdatex/example.o

runsingle test_showsectiongroupsc3.base  ./showsectiongroups \
  "-group 3" $testsrc/comdatex/example.o

runsingle test_showsectiongroupsc4.base  ./showsectiongroups \
  "-group 4" $testsrc/comdatex/example.o

runsingle test_showsectiongroupsc5.base  ./showsectiongroups \
  "-group 5" $testsrc/comdatex/example.o

# -u lets you provide a cu-name so you can select a CU and
# skip others when printing DIEs
runtest $d1 $d2 irixn32/dwarfdump -u  dwconf.c\
     -x name=dwarfdump.conf  -x abi=mips
#The following is for URI style test completeness
runtest $d1 $d2 irixn32/dwarfdump -u  dwconf%2ec\
     -x name=dwarfdump%2econf  -x abi=mips
runtest $d1 $d2 irixn32/dwarfdump -u  \
    /xlv44/6.5.15m/work/irix/lib/libc/libc_n32_M3/csu/crt1text.s \
     -x name=dwarfdump.conf -x abi=mips

#Following tests -c<str> and URI, the one restricted to GNU AS
# -cs means something different, not the same as -cg !
# The unadorned -c means print old .debug_loc in an unreliable way.
# which is really odd and confusing.
# only checks and reports on errors found in CUs with producer GNU AS.
runtest $d1 $d2 modula2/write-fixed -ka -cGNU%20AS  -M -R
runtest $d1 $d2 modula2/write-fixed -ka -M -R
# An unadorned -c here to provoke a message from dwarfdump options checking.
runtest $d1 $d2  sparc/tcombined.o -c -a -R  -v -v -v -v -v -v
runtest $d1 $d2  sparc/tcombined.o -ka -R  -v -v -v -v -v -v
runtest $d1 $d2  kartashev2/combined.o -a -R  -v -v -v -v -v -v
runtest $d1 $d2  kartashev2/combined.o -ka -R  -v -v -v -v -v -v
runtest $d1 $d2  x86/dwarfdumpv4.3 -a -R  -v -v -v -v -v -v
runtest $d1 $d2  x86/dwarfdumpv4.3 -ka -R -v -v -v -v -v -v
runtest $d1 $d2  mucci/stream.o -a -R   -v -v -v -v -v -v
runtest $d1 $d2  mucci/stream.o -ka -R   -v -v -v -v -v -v
runtest $d1 $d2  mucci/stream.o  -R -ka
runtest $d1 $d2  mucci/stream.o  -R -ka  -v -v -v -v -v -v
runtest $d1 $d2  mucci/main.o -a -R   -v -v -v -v -v -v
runtest $d1 $d2  mucci/main.o -ka -R   -v -v -v -v -v -v
runtest $d1 $d2  mucci/main.o  -R -ka  -v -v -v -v -v -v
runtest $d1 $d2  mucci/main.o  -R -ka
runtest $d1 $d2 mucci/stream.o -a -R -M
runtest $d1 $d2 mucci/stream.o -i -e
runtest $d1 $d2 legendre/libmpich.so.1.0 -f -F
runtest $d1 $d2 legendre/libmpich.so.1.0 -ka

if [ $nlize = 'n' -a ! $platform = "msys2" ]
then
  echo "=====START $testsrc/test-alex1/runtest.sh good=$goodcount skip=$skipcount fail=$failcount"
  mklocal test-alex1
    sh $testsrc/test-alex1/runtest.sh 
    chkres $?  $testsrc/test-alex1
  cd ..
else
  echo "=====SKIP 1 $testsrc/test-alex1/runtest.sh NLIZE and msys2"
  skipcount=`expr $skipcount + 1`
fi

if [ $nlize = 'n'  -a ! $platform = "msys2"  ]
then
  echo "=====START $testsrc/test-alex2/runtest.sh  good=$goodcount skip=$skipcount fail=$failcount"
  mklocal test-alex2
    sh $testsrc/test-alex2/runtest.sh 
    chkres $?  $testsrc/test-alex2
  cd ..
else
  echo "=====SKIP 1 $testsrc/test-alex2/runtest.sh NLIZE and msys2 "
  skipcount=`expr $skipcount + 1`
fi

# We need this to not do all DIE printing. FIXME
runtest $d1 $d2 macro5/dwarfdump-g3  -m
runtest $d1 $d2 macro5/dwarfdump-g3  -m -vvv
runtest $d1 $d2 macro5/dwarfdump-g3  -m -v

runtest $d1 $d2 convey/testesb.c.o -v  --print-macinfo
if [  $platform = "msys2" ]
then
  echo "=====SKIP debuglink on msys2"
  skipcount=`expr $skipcount +  2 `
else
  runtest $d1 $d2 debuglinkb/testid.debug -v  --print-macinfo
  runtest $d1 $d2 debuglinkb/testnoid.debug -v  --print-macinfo
fi
runtest $d1 $d2 emre4/test19_64_dbg -v  --print-macinfo
runtest $d1 $d2 emre4/test3_64_dbg -v  --print-macinfo
runtest $d1 $d2 emre5/test33_64_opt_fpo_split.dwp -v  --print-macinfo
runtest $d1 $d2 shopof1/main.exe -v  --print-macinfo

runtest $d1 $d2 convey/foo.g3-O0-strictdwarf.o -v  --print-macinfo
runtest $d1 $d2 enciso8/test-clang-dw5.o  -v  --print-macinfo
runtest $d1 $d2 enciso8/test-clang.o  -v  --print-macinfo
runtest $d1 $d2 kaletta/test.armlink.elf  -v  --print-macinfo
runtest $d1 $d2 kaletta/test.o  -v  --print-macinfo
runtest $d1 $d2 macinfo/a.out3.4  -v  --print-macinfo
runtest $d1 $d2 macinfo/a.out4.3  -v  --print-macinfo
runtest $d1 $d2 mustacchi/m32t.o  -v  --print-macinfo
runtest $d1 $d2 vlasceanu/const.o  -v  --print-macinfo
runtest $d1 $d2 wynn/unoptimised.axf  -v  --print-macinfo

runtest $d1 $d2 macro5/dwarfdump-g3  --print-macinfo
runtest $d1 $d2 macro5/dwarfdump-g3  --print-macinfo -v
runtest $d1 $d2 macro5/dwarfdump-g3  --check-macros
runtest $d1 $d2 macro5/dwarfdump-g3  --check-macros  -G
runtest $d1 $d2 macro5/dwarfdump-g3  --check-macros  -G -M
runtest $d1 $d2 macro5/dwarfdump-g3  --check-macros -v

#Here we ask for DIE printing.
runtest $d1 $d2 macro5/dwarfdump-g3 -i -m
runtest $d1 $d2 macro5/dwarfdump-g3 -i -m -vvv
runtest $d1 $d2 macro5/dwarfdump-g3 -i -m -v
runtest $d1 $d2 macro5/basetest     --print-macinfo
runtest $d1 $d2 macro5/basetest     --check-macros

#Following 2 show some DW_AT_MIPS_fde difference. So -C works.
runtest $d1 $d2  irix64/libc.so -ka -x name=dwarfdump.conf -x abi=mips-simple3
runtest $d1 $d2  irix64/libc.so -i -x name=dwarfdump.conf -x abi=mips-simple3

#FIXME
runtest $d1 $d2  irix64/libc.so --print-pubnames --print-weakname --print-type --print-static-var --print-static-func
runtest $d1 $d2  irixn32/libc.so --print-pubnames --print-static-var --print-weakname --print-type --print-static-var --print-static-func

#Following shows -C differences, see ia64/README. So -C works.
runtest $d1 $d2  ia64/mytry.ia64 -i
runtest $d1 $d2  ia64/mytry.ia64 -ka
runtest $d1 $d2  ia64/mytry.ia64 -i -C
runtest $d1 $d2  ia64/mytry.ia64 -ka  -C

runtest $d1 $d2  ref_addr/ELF3.elf -R -a -v -v -v -v -v -v
runtest $d1 $d2  ref_addr/ELF3.elf -R -a -M  -v -v -v -v -v -v
runtest $d1 $d2  ref_addr/ELF3.elf -R -ka -M -v -v -v -v -v -v

# This one fails,return add reg num 108.
runtest $d1 $d2  ppc2/powerpc-750-linux-gnu-hello-static -a  -v -v -v -v -v -v
runtest $d1 $d2  ppc2/powerpc-750-linux-gnu-hello-static -ka  -v -v -v -v -v -v
# This one works, return address reg 108 allowed.
runtest $d1 $d2  ppc2/powerpc-750-linux-gnu-hello-static -a   -R -v -v -v -v -v -v
runtest $d1 $d2  ppc2/powerpc-750-linux-gnu-hello-static -i   -R -v -v -v -v -v -v
# This one works, return address reg 108 allowed.
runtest $d1 $d2  ppc2/powerpc-750-linux-gnu-hello-static -a -R -v -v -v -v -v -v -x name=./dwarfdump.conf  -x abi=ppc
runtest $d1 $d2  ppc2/powerpc-750-linux-gnu-hello-static -i -R -v -v -v -v -v -v -x name=./dwarfdump.conf  -x abi=ppc

runtest $d1 $d2  louzon/ppcobj.o -a  -v -v -v -v -v -v -x name=./dwarfdump.conf  -x abi=ppc
runtest $d1 $d2  louzon/ppcobj.o -ka -v -v -v -v -v -v -x name=./dwarfdump.conf  -x abi=ppc
runtest $d1 $d2  linkonce/comdattest.o -ka -v -v -v -v -v -v -x name=./dwarfdump.conf  -x abi=ppc
runtest $d1 $d2  linkonce/comdattest.o -a -v -v -v -v -v -v -x name=./dwarfdump.conf  -x abi=ppc
runtest $d1 $d2 atefail/ig_server -kt

# Testing old interface to libdwarf with -g. IRIX only.
runtest $d1 $d2 irixn32/dwarfdump -f -g
runtest $d1 $d2 irixn32/dwarfdump -f -x name=./dwarfdump.conf -x abi=mips-simple3
runtest $d1 $d2 irixn32/dwarfdump --print-pubnames --print-static-var --print-weakname --print-type --print-static-var --print-static-func

runtest $d1 $d2 ia32/mytry.ia32 -F -x name=dwarfdump.conf -x abi=x86
runtest $d1 $d2 ia64/mytry.ia64 -F -x name=dwarfdump.conf -x abi=ia64
echo "The following is a misspelling of abi. Checks for error spelling so leave it in."
runtest $d1 $d2  irixn32/dwarfdump -f -x name=./dwarfdump.conf -x abi=mips-simple
runtest $d1 $d2  irixn32/dwarfdump -f -x name=./dwarfdump.conf -x abi=mips-simple3
runtest $d1 $d2  irixn32/dwarfdump -f -x name=./dwarfdump.conf -x abi=mips
# Restrict to a single fde report
runtest $d1 $d2 irixn32/dwarfdump -f -H 1  -x name=./dwarfdump.conf -x abi=mips
# Restrict to a single fde report with no function names shown
runtest $d1 $d2 irixn32/dwarfdump -f -H 1 -n  -x name=./dwarfdump.conf -x abi=mips
runtest $d1 $d2  irixn32/dwarfdump -f -x name=./dwarfdump.conf -x abi=mips
runtest $d1 $d2  irixn32/dwarfdump -f -x name=./dwarfdump.conf -x abi=mips
runtest $d1 $d2 irixn32/dwarfdump -f -x name=./dwarfdump.conferr1 -x abi=mips
runtest $d1 $d2 irixn32/dwarfdump --show-dwarfdump-conf -f -x name=./dwarfdump.conferr1 -x abi=mips
runtest $d1 $d2 val_expr/libpthread-2.5.so -f -v -v -x name=dwarfdump.conf -x abi=x86_64
runtest $d1 $d2 irixn32/dwarfdump -i -G
# restrict to a single CU
runtest $d1 $d2 irixn32/dwarfdump -i -H 1
runtest $d1 $d2 irixn32/dwarfdump -ka
runtest $d1 $d2 irixn32/dwarfdump -i -G -d

# Using old loclist call. Without -v nothing prints, so use -v.
# Adding -D is useless since then the attributes don't print at all so
# one cannot see the removal of offset from the loclist.
runtest $d1 $d2 irixn32/libc.so -g  -v -x name=dwarfdump.conf  -x abi=mips
runtest $d1 $d2 --show-dwarfdump-conf ia32/mytry.ia32 -i -G
runtest $d1 $d2 ia32/mytry.ia32 -i -G
runtest $d1 $d2 ia32/mytry.ia32 -i -G -d
runtest $d1 $d2 ia32/mytry.ia32 -ka -G -d
runtest $d1 $d2 cristi2/libc-2.5.so -F -x name=dwarfdump.conf -x abi=x86
runtest $d1 $d2 ia32/libc.so.6 -F -f -x name=dwarfdump.conf -x abi=x86
# Do not find function names (using -n)
runtest $d1 $d2 ia32/libc.so.6 -F -f -n  -x name=dwarfdump.conf -x abi=x86
# Restrict to single fde
runtest $d1 $d2 ia32/libc.so.6 -F -f -H 1 -x name=dwarfdump.conf -x abi=x86
# Restrict to single fde, single CIE
runtest $d1 $d2 ia32/libc.so.6 -F -f -H 1 -v -x name=dwarfdump.conf -x abi=x86
runtest $d1 $d2 ia32/libc.so.6 -F -f -n -x name=dwarfdump.conf -x abi=x86
runtest $d1 $d2 cristi2/libpthread-2.4.so -F -v -v -v -x name=dwarfdump.conf -x abi=x86
runtest $d1 $d2 cristi2/libpthread-2.4.so -ka -P -x name=dwarfdump.conf -x abi=x86
runtest $d1 $d2 cristi2/libpthread-2.4.so -ka -kd -P -x name=dwarfdump.conf -x abi=x86
runtest $d1 $d2 cristi2/libpthread-2.4.so -R -F  -v -v -v
runtest $d1 $d2 cristi2/libpthread-2.4.so -R -ka  -v -v -v

# this object has some duplicate DW_AT entries.
runtest $d1 $d2 cristi3/cristibadobj -m
runtest $d1 $d2 cristi3/cristibadobj -i -M
runtest $d1 $d2 cristi3/cristibadobj -i -M --no-dup-attr-check
# To see details of the attributes that are duplicated
runtest $d1 $d2 cristi3/cristibadobj --no-dup-attr-check  -i
runtest $d1 $d2 cristi3/cristibadobj -m  -v -v -v
runtest $d1 $d2 cristi3/cristibadobj --trace=0

# The following have KIND_RANGES_INFO and KIND_RANGES_INFO
# ... at least a little of it.
runtest $d1 $d2 ckdev/modulewithdwarf.ko -ka --trace=1 --trace=2 --trace=3
runtest $d1 $d2 debugnames/dwarfdump -ka --trace=1 --trace=2 --trace=3
runtest $d1 $d2 dwarf4/ddg4.5dwarf-4 -ka --trace=1 --trace=2 --trace=3

echo "BEGIN all-options testing"
for i in $filepaths
do
  echo  "=====BLOCK $i all options"
  for xtra in "-v" "-vv" "-vvv" "-D" "-H 2"
  do
    for k in  $baseopts " -M"
    do
	  runtest $d1 $d2 $i $k $xtra
    done
  done
done
for i in $filepaths
do
  echo "=====BLOCK $i all checking options"
  for xtra in "" "-kd"  "-ki"
  do
    for k in  $kopts
    do
      runtest $d1 $d2 $i $k $xtra
    done
  done
done
rm -f $dwba
rm -f $dwbb
if [ x$wrtimeo != "x" ]
then
  echo "base dwarfdump times"
  echo "$mypycom $testsrc/$mypydir/usertime.py baseline $otimeout"
  $mypycom $testsrc/$mypydir/usertime.py baseline $otimeout
  echo "new  dwarfdump times"
  echo "$mypycom $testsrc/$mypydir/usertime.py newversn $ntimeout"
  $mypycom $testsrc/$mypydir/usertime.py newversn $ntimeout
else
  echo "No /usr/bin/time data available to report"
fi
echo "PASS     count: $goodcount"
echo "FAIL     count: $failcount"
echo "SKIP     count: $skipcount"
echo "BUILDSOK count: $bldgoodcount (test harness ok)"
echo "VALGRIND count: $valgrindcount"
echo "VALGRIND  errs: $valgrinderrcount"
totalcount=`expr $goodcount + $failcount + $skipcount`
echo "TOTAL         : $totalcount"
echo 'Ending regressiontests: DWARFTEST.sh' `date`
ndsecs=`date '+%s'`
showminutes() {
   t=`expr  \( $2 \- $1 \+ 29  \) \/ 60`
   echo "Run time in minutes: $t"
}
showminutes $stsecs $ndsecs
if [ "x$nlize" = "xy" ]
then
  echo "Sanitize?              : y (yes)"
else
  echo "Sanitize?              : n (no)"
fi
if [ "x$SUPPRESSDEALLOCTREE" = "xy" ]
then
  echo "Suppress de_alloc_tree?: y (yes)"
else
  echo "Suppress de_alloc_tree?: n (no)"
fi
if [ "x$VALGRIND" = "xy" ]
then
  echo "valgrind?              : $VALGRIND"
fi

if [ $failcount -ne 0 ]
then
   exit 1
fi
exit 0
