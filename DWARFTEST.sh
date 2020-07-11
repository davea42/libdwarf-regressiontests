#!/bin/sh
trap "echo Exit testing due to signal ;  rm -f /tmp/dwbc.$$ /tmp/dwba.$$ /tmp/dwbb.$$ ; exit 1 " 2
#
echo "Env vars that affect the tests:" 
echo "  If you wish do one or more of these before running the tests."
echo "  Add sanity..............: export NLIZE=y"
echo "  Suppress de_alloc_tree..: export SUPPRESSDEALLOCTREE=y"
echo "  Revert to normal test...: unset SUPPRESSDEALLOCTREE ; unset NLIZE"

# On certain VMs if too much change, we get
# stuck at 1% done forever (and after 10 hours
# far from done with the tests).
# suppress those tests via:
# export SUPPRESSBIGDIFFS=y
# It is not test runtime that is the problem.
# If the actual result difference is substantial
# the shell time doing diff etc takes too long.

echo 'Starting regressiontests: DWARFTEST.sh' `date`
. ./SHALIAS.sh
stsecs=`date '+%s'`
# dwarfgen and libelf go together here.
withlibelf="withlibelf"
if [ $# -eq 0 ]
then
  echo "DWARFTESTS.sh no withlibelf/nolibelf argument"
  echo "Defaults to  withlibelf"
  withlibelf=withlibelf
fi
shortest=n
#comment the following line out for a normal test.
#No env var provided for this. Unsure the last time used. 
#shortest=y

suppresstree=
#next line is the dwarfdump option to suppress de alloc tree
#suppresstree="--suppress-de-alloc-tree"
#suppresstree="--suppress-de-alloc-tree --print-alloc-sums"
#Now with env var.
if [ x$SUPPRESSDEALLOCTREE = "xy" ]
then
   suppresstree="--suppress-de-alloc-tree" 
fi

for i in $*
do
  case $i in
  nolibelf) echo "DWARFTESTS.sh arg is $i"
        withlibelf="nolibelf" 
        shift;;
  # Makefile does not yet support this option
  --suppress-de-alloc-tree) echo "DWARFTESTS.sh arg is $i"
        echo "Suppressing de_alloc_tree"
        suppresstree=$i 
        shift;;

  withlibelf) echo "DWARFTESTS.sh arg is $i"
        withlibelf="withlibelf" 
        shift;;

  *)
       echo "Improper argument $i to DWARFTEST.sh" 
       echo "use withlibelf or nolibelf"
       echo "or use --suppress-de-alloc-tree"
       exit 1 ;;
  esac
done

if [ ! -f ./BASEFILES -o ! -f ./dwarfdump ]
then
  echo "./BASEFILES and ./dwarfdump needed. do configure and make buildbefore running the tests"
  exit 1
fi

cd checkforlibz
sh runtest.sh
if [ $? -ne 0 ]
then
  withlibz="nolibz"
else
  withlibz="withlibz"
fi
cd ..
echo "build with libelf.........: $withlibelf"
echo "build with libz...........: $withlibz"
# The following is a dwarfdump option
# and tells dwarfdump to ask libdwarf to do less!
# The following is needed for --print-alloc-sums
rm -f libdwallocs

# We do not use DWARFTEST in ps -eaf |grep DWARFTEST as we do not want to 
# match the grep from ps
ps -eaf >/tmp/dwbc.$$ 
grep DWARFTEST.sh < /tmp/dwbc.$$ >/tmp/dwba.$$ 2>/dev/null
echo "wc -l /tmp/dwbc.$$........: " `wc -l /tmp/dwbc.$$`
rm -f /tmp/dwbc.$$
echo "Lock file.................: /tmp/dwba.$$"
echo "Lock file content follows.:"
cat /tmp/dwba.$$
grep DWARFTEST.sh </tmp/dwba.$$ > /tmp/dwbb.$$
ct=`wc -l </tmp/dwbb.$$`
echo "DWARFTEST.sh running......: $ct"
echo "Lock file.................: /tmp/dwbb.$$"
echo "Lock file content follows.:"
cat /tmp/dwbb.$$
ct=`wc -l </tmp/dwbb.$$`
if [ $ct -gt 1 ]
then
  echo "Only one DWARFTEST.sh can run at a time on a machine"
  echo "Something is wrong, DWARFTEST.sh already running: $ct"
  echo "dwbb.$$ contains:"
  echo /tmp/dwbb.$$
  echo "do......................: rm /tmp/dwba* /tmp/dwbb* "
  echo "Check with: ps -eaf |grep DWARF"
  exit 1
fi

endian=L
CC=cc
which $CC >/dev/null
if [ $? -ne 0 ]
then
  # No native cc. Try gcc.
  CC=gcc
fi
$CC testendian.c -o testendian
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
p3=`which python3`
if [ $? -eq 0 ]
then
  mypydir=python3
  mypycom=$p3
else
  p2=`which python2`
  if [ $? -eq 0 ]
  then
    mypydir=python2
    mypycom=$p2
  fi
fi

# Do the following two for address-sanitization.
# Not all tests will be run in that case.

if [ x$NLIZE != 'xy' ]
then
  NLIZE='n'
  export NLIZE
  ASAN_OPTIONS=
  export ASAN_OPTIONS
  nlizeopt=
  echo "Using -fsanitize .........: no"
else
  ASAN_OPTIONS="allocator_may_return_null=1"
  export ASAN_OPTIONS
  nlizeopt="-fsanitize=address -fsanitize=leak -fsanitize=undefined"
  echo "Using -fsanitize=leak.....: yes"
fi
if [ "x$suppresstree" = "x--suppress-de-alloc-tree" ]
then
  echo "Suppress de_alloc_tree....: yes"
else
  echo "Suppress de_alloc_tree....: no"
  suppresstree=
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

# Speeds up diff on big files with small differences.
echo a >/tmp/junkadwtests
echo a >/tmp/junkbdwtests
diffopt="--speed-large-files"
diff $diffopt /tmp/junkadwtests /tmp/junkbdwtests 2>/dev/null
if [ $? -ne 0 ]
then
  # the option is not supported.  
  diffopt=""
  echo "speed up big diffs........: no"
else 
  echo "speed up big diffs........: yes"
fi
rm /tmp/junkadwtests /tmp/junkbdwtests

myhost=`hostname`
echo   "hostname..................: $myhost"
goodcount=0
failcount=0
. ./BASEFILES
top_srcdir=$libdw
# Must match the file location in PICKUPBIN 
top_builddir=/tmp/regressionbuild
echo "code source...............: $top_srcdir"
d1=./dwarfdump.O
d2=./dwarfdump
bdir=`pwd`
echo "old is....................: $d1"
echo "new is....................: $d2"
dwlib=$bdir/libdwarf.a
dwinc=$top_srcdir/libdwarf


#  oi and  Ei are to ensure that things
# work properly when using libelf. Including relocations.
#baseopts='-F'
if [ x$withlibelf = "xwithlibelf" ]
then
  baseopts='-b -c  -f -F -i -l -m  -p -r -s -ta -tf -tv -y -w  -N '
else
  baseopts='-b -c  -f -F -i -l -m  -p -r -s -ta -tf -tv -y -w  -N '
fi

kopts="-ka -kb -kc -ke -kf -kF -kg  -kl -km -kM -kn -kr -kR -ks -kS -kt -kx -ky -kxe -kD -kG -ku -kuf"

# These accumulate times so we can print actual dwarfdump
# user, sys, clock times at the end (see usertime.py).
. ./RUNTIMEFILES
if [ x$wrtimeo != "x" ]
then
  echo "/usr/bin/time timing......: yes"
else
  echo "/usr/bin/time timing......: no"
fi
rm -f $otimeout 
rm -f $ntimeout
chkres () {
  if [ $1 = 0 ]
  then
    goodcount=`expr $goodcount + 1`
  else
    echo FAIL  $2
    failcount=`expr $failcount + 1`
  fi
}
chkresn () {
  if [ $1 = 0 ]
  then
    goodcount=`expr $goodcount + $3`
  else
    echo FAIL  $2
    failcount=`expr $failcount + $3`
  fi
}

#ia32/libpt_linux_x86_r.so.1  -f -F runs too long.
#filepaths=""
#if [ x$withlibelf = "xnolibelf" ]
#then
#    echo "=====SKIP sarubbo-6/1.crashes.bin sarubbo-4/libresolv.a because nolibelf"
#else
#    filepaths='sarubbo-6/1.crashes.bin sarubbo-4/libresolv.a'
#fi

filepaths='$filepaths moshe/hello
jborg/simple
gilmore/a.out
navarro/compressed_aranges_test
enciso8/test-clang-dw5.o
enciso8/test-clang-wpieb-dw5.o
sarubbo-7/4.crashes.bin
sarubbo-5/1.crashes.bin
jacobs/test.o
klingler/test-with-zdebug
diederen2/pc_dwarf_bad_attributes.elf
diederen2/pc_dwarf_bad_sibling2.elf
diederen2/pc_dwarf_bad_reloc_empty_debug_info.elf
diederen2/pc_dwarf_bad_sibling.elf
diederen2/pc_dwarf_bad_reloc_section_link.elf
diederen2/pc_dwarf_bad_string_offset.elf
diederen3/pc_dwarf_bad_name3.elf
emre3/a.out.dwp
emre3/foo.dwo
emre3/main.dwo
emre3/foo.o
emre3/main.o 
diederen/hello
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
cristi3/cristibadobj
liu/divisionbyzero02.elf
liu/divisionbyzero.elf
liu/free_invalid_address.elf
liu/heapoverflow01b.elf
liu/heapoverflow01.elf
liu/HeapOverflow0513.elf
liu/infinitloop.elf
liu/null01.elf
liu/null02.elf
liu/NULLdereference0519.elf
liu/NULLderefer0505_01.elf
liu/NULLdereference0522.elf
liu/OOB0505_01.elf
liu/OOB0505_02_02.elf
liu/OOB0505_02.elf
liu/OOB0517_01.elf
liu/OOB0517_03.elf
liu/OOB_read3_02.elf
liu/OOB_read3.elf
liu/OOB_read4.elf
liu/OOB_READ0519.elf
liu/outofbound01.elf
liu/outofboundread2.elf
liu/outofboundread.elf
irix64/libc.so 
irixn32/libc.so 
irixn32/dwarfdump' 


if [ "$suppressbigdiffs" != "y" ]
then
  filepaths="dwgenb/dwarfgen $filepaths"
  filepaths="klingler/dwarfgen-zdebug $filepaths"
  filepaths="dwarf4/dd2g4.5dwarf-4 $filepaths"
  filepaths="dwarf4/ddg4.5dwarf-4 $filepaths"
fi

# Was in the list, but does not exist!
#x86-64/x86_64testcase.o 


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
  mv $1 $2
  #nstart=$1
  #nend=$2
  #sed -e 'sx.\/dwarfdump.Ox.\/dwarfdumpx' < $nstart > $nend
}
# For stderr we need to fix the name due to getopt.c
unifyddnameb () {
  nstart=$1
  nend=$2
  sed -e 'sx.\/dwarfdump.Ox.\/dwarfdumpx' < $nstart > $nend
}

totaltestcount=0
runtest () {
	olddw=$1
	newdw=$2
	targ=$3
	shift
	shift
	shift
	
        totaltestcount=`expr $totaltestcount + 1`
        pctstring=`$mypycom $mypydir/showpct.py $totaltestcount`
        echo "=====START Pct $pctstring  $*  $targ" 
        rm -f core
        rm -f tmp1 tmp2 tmp3
        rm -f tmp1err tmp2err tmp3err 
        rm -f tmp1errb tmp1errc
        rm -f tmp1berr tmp2berr
        # OFo OFn are targets of dwarfdump -O file=path
        #
        rm -f OFo OFn  OFo1 OFn1 
        rm -f OFo2 OFn2
        rm -f OFo3 OFn3
	    rm -f OFobkup

        # Running an old one till baselines established.
        echo "old start " `date`
        tmplist="$*"
        #echo "dadebug tmplist baseline line5 difference-fix ",$tmplist 
        # dadebug temp strip -x
        #tmplist2=`stripx "$*"`
        # echo "dadebug tmplist2 ",$tmplist2 
        echo "======" $tmplist $targ >> $otimeout
        if [ x$wrtimeo != "x" ]
        then
          $wrtimeo $olddw $tmplist  $targ 1>tmp1a 2>tmp1erra
        else
          $olddw $tmplist  $targ 1>tmp1a 2>tmp1erra
        fi
        #$olddw $*  $targ 1>tmp1a 2>tmp1erra
        echo "old done " `date`
        unifyddname tmp1a tmp1
        unifyddnameb tmp1erra tmp1err
        if [ -f core ]
        then
           echo corefile in  $olddw '(old dwarfdump)'
           rm core
        fi
        if [ -f OFo ] 
        then
           unifyddname OFo OFo1
           grep -v Usage   OFo1 >OFo2
           # Delete date on first line
           sed '1d' OFo2 >OFo3
           cp OFo OFobkup
        fi

        echo "new start " `date`
        echo "======" $tmplist $targ >> $ntimeout
        if [ x$wrtimen != "x" ]
        then
          $wrtimen $newdw $suppresstree $* $targ 1>tmp2a 2>tmp2erra
        else
          $newdw $suppresstree $* $targ 1>tmp2a 2>tmp2erra
        fi
        echo "new done " `date`
        # No need to unify for new dd name.
        unifyddname tmp2a tmp2
        unifyddnameb tmp2erra tmp2err
        date
        if [ -f core ]
        then
           echo corefile in  $newdw
           exit 1
        fi
        cat tmp2  >tmp3
        if [ -f OFo ] 
        then
           # Here OFo is really OFn
           unifyddname OFo OFn1
           cp OFo OFnbkup
           grep -v Usage   OFn1 >OFn2
           # Delete date on first line
           sed '1d' OFn2 >OFn3
        fi

        if [ -f OFn3 -o -f OFo3 ]
        then
          touch OFn3 OFo3
          #cmp  OFo3 OFn3
          #if [ $? -ne 0 ]
          #then
            diff $diffopt OFo3 OFn3
            if [ $? -eq 0 ]
            then
              goodcount=`expr $goodcount + 1`
            else
              echo "FAIL -O file=path"  $* $targ
              failcount=`expr $failcount + 1`
            fi
          #else
          #  goodcount=`expr $goodcount + 1`
          #fi
        fi

        # 
        #cmp tmp1 tmp3
        #if [ $? -ne 0 ]
        #then
          diff $diffopt tmp1 tmp3
          if [ $? = 0 ]
          then
            goodcount=`expr $goodcount + 1`
          else
            echo FAIL  $* $targ
            failcount=`expr $failcount + 1`
          fi
        #else
        #  goodcount=`expr $goodcount + 1`
        #fi

        grep -v Usage   tmp1err >tmp1berr
        grep -v Usage   tmp2err >tmp2berr
        #cmp tmp1berr tmp2berr
        #if [ $? -ne 0 ]
        #then
          diff $diffopt tmp1berr tmp2berr
          if [ $? = 0 ]
          then
            goodcount=`expr $goodcount + 1`
          else
            echo FAIL Usage  $* $targ
            failcount=`expr $failcount + 1`
          fi
        #else
        #  goodcount=`expr $goodcount + 1`
        #fi
        rm -f core
        rm -f tmp1 tmp2 tmp3
        rm -f tmp1err tmp2err tmp3err 
        rm -f tmp1errb tmp1errc
        rm -f tmp1berr tmp2berr
	    rm -f OFobkup
        rm -f OFo OFn  OFo1 OFn1 
        rm -f OFo2 OFn2
        rm -f OFo3 OFn3
}
# end 'runtest'

#=============BEGIN THE TESTS===============

# printing .debug_gnu_pubnames and .debug_gnu_pubtypes
runtest $d1 $d2 debugfission/archive.o --print-debug-gnu
runtest $d1 $d2 debugfission/target.o  --print-debug-gnu
runtest $d1 $d2 gsplitdwarf/frame1     --print-debug-gnu
runtest $d1 $d2 gsplitdwarf/getdebuglink --print-debug-gnu
runtest $d1 $d2 moya/simple.o          --print-debug-gnu
runtest $d1 $d2 moya/with-types.o      --print-debug-gnu
runtest $d1 $d2 moya3/ranges_base.o    -a -G -M -v
runtest $d1 $d2 moya3/ranges_base.dwo  -a -G -M -v
runtest $d1 $d2 moya3/ranges_base.dwo  -a -G -M -v --file-tied=moya3/ranges_base.o


# New September 11, 2019.
if [ x$withlibelf = "xnolibelf" ]
then
  echo "=====SKIP  testoffdie  runtest.sh nolibelf $withlibz "
else
  echo "=====START  testoffdie runtest.sh $top_srcdir $top_builddir $withlibelf $withlibz"
  cd testoffdie 
  sh runtest.sh $top_srcdir $top_builddir $withlibelf $withlibz
  chkres $? "testoffdie/runtest.sh"
  cd ..
fi




# .gnu_debuglink and .note.gnu.build-id  section tests.
if [ x$withlibelf = "xnolibelf" ]
then
  echo "=====SKIP  debuglink  runtest.sh nolibelf"
else
  echo "=====START  debuglink  runtest.sh"
  cd debuglink
  sh runtest.sh $withlibelf $withlibz
  chkres $? "debuglink/runtest.sh"
  cd ..
fi

#gcc using -gsplit-dwarf option
# debuglink via DWARF4. frame one via DWARF5
runtest $d1 $d2 gsplitdwarf/getdebuglink                  --print_fission -a 
runtest $d1 $d2 gsplitdwarf/getdebuglink.dwo --print_fission -a
runtest $d1 $d2 gsplitdwarf/getdebuglink.dwo --file-tied=gsplitdwarf/getdebuglink --print_fission -a
runtest $d1 $d2 gsplitdwarf/frame1-frame1.dwo             -a --print-fission
runtest $d1 $d2 gsplitdwarf/frame1.dwo --file-tied=gsplitdwarf/frame1 -a --print-fission 
runtest $d1 $d2 gsplitdwarf/frame1 -a --print-fission
# Same but now with -vv
runtest $d1 $d2 gsplitdwarf/getdebuglink -a -vv --print_fission 
runtest $d1 $d2 gsplitdwarf/getdebuglink.dwo -a -vv --print_fission
runtest $d1 $d2 gsplitdwarf/getdebuglink.dwo --file-tied=gsplitdwarf/getdebuglink -a -vv --print_fission
runtest $d1 $d2 gsplitdwarf/frame1.dwo -a -vv --print-fission
runtest $d1 $d2 gsplitdwarf/frame1.dwo --file-tied=gsplitdwarf/frame1 -a -vv --print-fission 
runtest $d1 $d2 gsplitdwarf/frame1 -a --print-fission -vv

# tiny and severly damaged 'object' file.
runtest $d1 $d2 kapus/bad.obj -a

#DWARF5 with .debug_rnglists and .debug_loclists
runtest $d1 $d2 moya2/filecheck.dwo -i -vv --print-raw-loclists --print_raw_rnglists
runtest $d1 $d2 moya2/filecheck.dwo -ka --print_raw_rnglists

runtest $d1 $d2 rnglists/readelfobj -vv  --print-raw-rnglists
runtest $d1 $d2 rnglists/readelfobj -ka
runtest $d1 $d2 rnglists/linelen.o  -v --print-raw-rnglists
runtest $d1 $d2 rnglists/linelen.o  -ka 
runtest $d1 $d2 rnglists/extractdba.o -v  --print-raw-rnglists
runtest $d1 $d2 rnglists/extractdba.o -v  -ka
runtest $d1 $d2 rnglists/pe_map.o -v --print-raw-rnglists
runtest $d1 $d2 rnglists/pe_map.o  --print-raw-rnglists

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
if [ x$withlibelf = "xnolibelf" ]
then
  cd mustacchi
  sh runtest.sh
  chkres $? "mustacchi/runtestnolibelf.sh"
  cd ..
else
  cd mustacchi
  sh runtest.sh
  chkres $? "mustacchi/runtest.sh"
  sh runtestnolibelf.sh
  chkres $? "mustacchi/runtestnolibelf.sh"
  cd ..
fi

runtest $d1 $d2 val_expr/libpthread-2.5.so --print-gnu-debuglink
if [ -f /lib/x86_64-linux-gnu/libc-2.27.so ]
then
  echo "=====START  --print-gnu-debuglink /lib/x86_64-linux-gnu/libc-2.27.so"
  runtest $d1 $d2 /lib/x86_64-linux-gnu/libc-2.27.so --print-gnu-debuglink
  chkres $? "libc-2.27.so --print-gnu-debuglink"
else
  echo "=====SKIP  --print-gnu-debuglink /lib/x86_64-linux-gnu/libc-2.27.so"
fi

# Test ensuring R_386_GOTPC relocation understood. June 202
runtest $d1 $d2 mustacchi/relgotpc.o -a -M
# DWARF5 test, new 17 June 2020.
runtest $d1 $d2 moya2/filecheck.dwo -a -M
runtest $d1 $d2 moya2/filecheck.dwo -a -vvv -M
# sample object with DW_AT_containing type in a use
# which is standard
runtest $d1 $d2 encisoa/DW_AT_containing_type.o --check-tag-attr
runtest $d1 $d2 encisoa/DW_AT_containing_type.o --check-tag-attr --format-extensions
if [ x$withlibelf = "xnolibelf" ]
then
  runtest $d1 $d2 encisoa/DW_AT_containing_type.o -o --check-tag-attr
  runtest $d1 $d2 encisoa/DW_AT_containing_type.o -Ei --check-tag-attr --format-extensions
fi

# PE basic tests.
runtest $d1 $d2 pe1/libexamine-0.dll --print-all 
runtest $d1 $d2 pe1/libexamine-0.dll --print-info --format-attr-name --format-global-offsets
runtest $d1 $d2 pe1/libexamine-0.dll --print-info --format-attr-name -vvv
runtest $d1 $d2 pe1/libexamine-0.dll --print-strings 

runtest $d1 $d2 pe1/kask-dwarfdump_64.exe --print-all 
runtest $d1 $d2 pe1/kask-dwarfdump_64.exe --print-info --format-attr-name -vvv 

# mach-o basic tests.
runtest $d1 $d2 macho-kask/simplereaderi386   -a 
runtest $d1 $d2 macho-kask/simplereaderi386   -b 
runtest $d1 $d2 macho-kask/simplereaderi386   -a -vvv
runtest $d1 $d2 macho-kask/simplereaderx86_64 -a 
runtest $d1 $d2 macho-kask/simplereaderx86_64 -b 
runtest $d1 $d2 macho-kask/simplereaderx86_64 -a -vvv
# The following 2 should give the same output as the first,
# in spite of naming a simple text placeholder.
runtest $d1 $d2 macho-kask/mach-o-object32    -a 
runtest $d1 $d2 macho-kask/mach-o-object32    -a  -vvv
runtest $d1 $d2 macho-kask/mach-o-object64    -a 
runtest $d1 $d2 macho-kask/mach-o-object64    -a  -vvv
# This is G4 big-endian
runtest $d1 $d2 macho-kask/dwarfdump_G4    -a  -vvv

# the following have a DWARF section the last
# section. _64 failed. Now fixed in libdwarf.
runtest $d1 $d2  macho-kask/dwarfdump_32 -a
runtest $d1 $d2  macho-kask/dwarfdump_64 -a

# Vulnerability CVE-2017-9998 in libdwarf
runtest $d1 $d2   wolff/POC1 -a
runtest $d1 $d2   wolff/POC1 -b

#Show the usage options list
if [ $withlibelf = "withlibelf" ]
then
  echo "=====START foo.o -h --help"
  runtest $d1 $d2 foo.o -h
  runtest $d1 $d2 foo.o --help
else
  echo "=====SKIP foo.o -h --help"
fi
# Some errors in options list use, which
# should not show the options list
runtest $d1 $d2 foo.o  -j
runtest $d1 $d2 foo.o -x unknown
runtest $d1 $d2 foo.o --unknown-longopt
runtest $d1 $d2 -M  -M

# This has right idea in .debug_str_offsets, but wrong table length.
runtest $d1 $d2 enciso8/test-clang-dw5.o -s --print-str-offsets
# This has a correct table (new clang, soon will be available).
runtest $d1 $d2 enciso8/test-clang-wpieb-dw5.o -s --print-str-offsets
if [ $withlibelf = "withlibelf" ]
then
  runtest $d1 $d2 enciso8/test-clang-dw5.o -o -s --print-str-offsets
  runtest $d1 $d2 enciso8/test-clang-wpieb-dw5.o -o -s --print-str-offsets
fi


# These have .debug_str_offsets sections, but they are empty
# or bogus (created from a draft, not final, DWARF5, I think)
# so do not expect much output.
runtest $d1 $d2 emre3/a.out.dwp --print-str-offsets 
runtest $d1 $d2 emre3/foo.dwo --print-str-offsets
runtest $d1 $d2 emre3/main.dwo --print-str-offsets 
runtest $d1 $d2 emre5/test33_64_opt_fpo_split.dwp
runtest $d1 $d2 emre6/class_64_opt_fpo_split.dwp 
runtest $d1 $d2 emre6/class_64_opt_fpo_split --print-gnu-debuglink

runtest $d1 $d2  sarubbo-3/1.crashes.bin -a -b -c 

# This is an object with both dwo and non-dwo sections.
# It's not correct, but it at least has both groups
# The first should pick up group 1.
runtest $d1 $d2   camp/empty.o -a
# The second should show a little bit.
runtest $d1 $d2   camp/empty.o -a -x groupnumber=2

# DW201712-001: Was failing to check augmentation length for fde.
runtest $d1 $d2   sarubbo-10/1.crashes.bin -a -b -c -d -e -f -F -g -G -i -I \
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
if [ $withlibelf = "withlibelf" ]
then
  runtest $d1 $d2   convey/foo.g3-O0-strictdwarf.o -oi -F
fi

# Before 4 March 2017 would terminate early with error.
runtest $d1 $d2   emre6/class_64_opt_fpo_split.dwp -a
# the fix had no effect on this, which works ok.
runtest $d1 $d2   emre6/class_64_opt_fpo_split -a

if [ $withlibelf = "withlibelf" ]
then
  echo "=====START   hughes2 runtest.sh"
  cd hughes2
  sh runtest.sh ../simplereader ../corruptdwarf-a/simplereader.elf
  chkres $?  hughes2
  cd ..
else
  echo "=====SKIP   hughes2 runtest.sh no libelf as coredump is a bit unix/linux specific"
fi

if [ $withlibelf = "withlibelf" ]
then
  echo "=====START   implicitconst runtest.sh"
  cd implicitconst
  sh runtest.sh
  chkres $?  implicitconst
  cd ..
else
  echo "=====SKIP   implicitconst sh runtest.sh no libelf"
fi

echo "=====START   nolibelf runtest.sh"
cd nolibelf
sh runtest.sh
chkres $?  nolibelf
cd ..


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
runtest $d1 $d2   sarubbo-11/testcase5.bin -a

# Object file die runs off end of die
runtest $d1 $d2   puzzor/heap_buf_overflow.o -a

# Fuzzed objects, each of which resulted in a specific out of bounds memory access.
runtest $d1 $d2 sarubbo-2/00024-libdwarf-memalloc-do_decompress_zlib -a
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
runtest $d1 $d2  liu/NULLdereference0519.elf -a
runtest $d1 $d2  liu/NULLderefer0505_01.elf -a
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
runtest $d1 $d2  liu/OOB_read4.elf -a
runtest $d1 $d2  liu/OOB_READ0519.elf -a
runtest $d1 $d2  liu/outofbound01.elf -a
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
runtest $d1 $d2 irixn32/dwarfdump -f -x name=./dwarfdump.conf -x abi=mips-irix2 $x
runtest $d1 $d2  ppc2/powerpc-750-linux-gnu-hello-static -a   -R -v -v -v -v -v -v  $x
runtest $d1 $d2  mucci/main.o -c -R -ka  -v -v -v -v -v -v $x
done

runtest $d1 $d2 augmentation/a.out -f 
runtest $d1 $d2 augmentation/a.out -f  -vvv
runtest $d1 $d2 corruptdwarf-a/simplereader.elf -i  
runtest $d1 $d2 corruptdwarf-a/simplereader.elf -a  
runtest $d1 $d2 corruptdwarf-a/simplereader.elf -a  -vvv

runtest $d1 $d2 irixn32/dwarfdump -i -x name=./dwarfdump.conf -x abi=mips-irix2 -g

# Test support for DW_FORM_GNU_strp_alt
runtest $d1 $d2 hughes/libkrb5support.so.0.1.debug -i  -l -M -x tied=hughes/krb5-1.11.3-38.fc20.x86_64 

# for two-level line tables 
runtest $d1 $d2 emre4/test19_64_dbg -l
runtest $d1 $d2 emre4/test19_64_dbg -a
runtest $d1 $d2 emre4/test3_64_dbg -l
runtest $d1 $d2 emre4/test3_64_dbg -a
runtest $d1 $d2 emre4/test19_64_dbg -l -vvv
runtest $d1 $d2 emre4/test19_64_dbg -a -vvv
runtest $d1 $d2 emre4/test3_64_dbg -l -vvv
runtest $d1 $d2 emre4/test3_64_dbg -a -vvv
runtest $d1 $d2 emre4/test19_64_dbg -l -v
runtest $d1 $d2 emre4/test19_64_dbg -a -v
runtest $d1 $d2 emre4/test3_64_dbg -l -v
runtest $d1 $d2 emre4/test3_64_dbg -a -v


# This one has .debug_cu_index
# Some duplication with generic test loop.
runtest $d1 $d2 emre3/a.out.dwp -i
runtest $d1 $d2 emre3/a.out.dwp -i -v
runtest $d1 $d2 emre3/a.out.dwp -i -d
runtest $d1 $d2 emre3/a.out.dwp -i -d -v
runtest $d1 $d2 emre3/a.out.dwp -I

runtest $d1 $d2 duplicatedattr/duplicated_attributes.o -i -O file=./OFo
runtest $d1 $d2 duplicatedattr/duplicated_attributes.o -kD
runtest $d1 $d2 duplicatedattr/duplicated_attributes.o -kG
runtest $d1 $d2 duplicatedattr/duplicated_attributes.o -ku
runtest $d1 $d2 duplicatedattr/duplicated_attributes.o -kuf
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
if [ $suppressbigdiffs = "n" ]
then
  runtest $d1 $d2 debugfissionb/ld-new --check-tag-attr
  runtest $d1 $d2 debugfissionb/ld-new --check-tag-attr --format-extensions
  runtest $d1 $d2 debugfissionb/ld-new.dwp -I -v -v -v
  # Testing SHF_COMPRESSED .debug* section reading.
  runtest $d1 $d2  klingler2/compresseddebug.amd64 -i
  runtest $d1 $d2  klingler2/compresseddebug.amd64 -a
  # .eh_frame is not actually compressed...
  runtest $d1 $d2  klingler2/compresseddebug.amd64 -F

  # A big object.
  runtest $d1 $d2 debugfissionb/ld-new.dwp -i -v -v -v
  runtest $d1 $d2 debugfissionb/ld-new.dwp -ka
  runtest $d1 $d2 debugfissionb/ld-new.dwp -i -x tied=debugfissionb/ld-new
  runtest $d1 $d2 debugfissionb/ld-new.dwp -a -x tied=debugfissionb/ld-new
  runtest $d1 $d2  debugfissionb/ld-new -I
  runtest $d1 $d2  debugfissionb/ld-new -a  
  runtest $d1 $d2  debugfissionb/ld-new -ka  
else
  # Skip on vms a bit too weak to do this big a diff
  # in a reasonable time if it really has differences.
  echo "=====SKIP  some debugfissionb/ld-new.dwp tests"
fi

# A very short debug_types file. Used to result in error due to bug.
runtest $d1 $d2 emre/input.o -a

# Has a type unit so we can see the index for such.
runtest $d1 $d2 emre2/emre.ex -I
runtest $d1 $d2 emre2/emre.ex --print-gnu-debuglink

runtest $d1 $d2  emre5/test33_64_opt_fpo_split.dwp  -i -x tied=emre5/test33_64_opt_fpo_split 


echo "=====START   baddie1 runtest.sh"
cd baddie1
sh runtest.sh ../$d2 
chkres $?  baddie1
cd ..

if [ $withlibelf = "withlibelf" ]
then
  echo "=====START   offsetfromlowpc sh runtest.sh ../dwarfgen ../$d2  ../simplereader"
  # Also tests dwarfgen and libdwarf with DW_CFA_advance_loc
  # operations
  cd offsetfromlowpc
  sh runtest.sh ../dwarfgen ../$d2  ../simplereader
  chkres $?  offsetfromlowpc
  cd ..
else
  echo "=====SKIP   offsetfromlowpc sh runtest.sh no libelf"
fi

if [ $withlibelf = "withlibelf" ]
then
  echo "=====START   strsize sh runtest.sh "
  cd strsize
  sh runtest.sh 
  chkres $? strsize
  cd ..
else
  echo "=====SKIP   strsize sh runtest.sh no libelf"
fi

echo "=====START   debugfissionb/runtest.sh multiplesimplereader tests"
# tests simple reader and more than one dwarf_init* interface
# across all object types
# here kaufmann/t.o is tested as input to simplereader.
cd debugfissionb
sh runtest.sh  ../simplereader
chkres $?  debugfissionb-simplreader
cd ..

echo "=====START   debugfission runtest.sh"
cd debugfission
sh runtest.sh  ../$d2 
chkres $?  debugfission
cd ..

echo "=====START   data16 runtest.sh"
if [ $NLIZE = 'n' -a $withlibelf = "withlibelf" ]
then
  cd data16
  sh runtest.sh
  chkres $?  "data16/runtest.sh"
  cd ..
else
  echo "=====SKIP  data16/runtest.sh with NLIZE or if no libelf"
fi

if [ $NLIZE = 'n' ]
then
  runtest $d1 $d2   sarubbo-8/1.crashes.bin  -a -b -c -d -e -f -F -g -G -i -I -m -M -N -p -P -R -r -s -ta -w -y 
  chkres $?  sarubbo-8 
else
  echo "=====SKIP  sarubbo-8 with NLIZE"
fi

if [ $NLIZE = 'n' ]
then
  runtest  $d1 $d2   sarubbo-9/3.crashes.bin -a -b -c -d -e -f -F -g -G -i -I -m -M -N -p -P -R -r -s -ta -w -y 
  chkres $?  sarubbo-9
else
  echo "=====SKIP  sarubbo-9 with NLIZE"
fi

# This tries to use a nonexistent file. So we see the dwarfdump fail message.
runtest $d1 $d2 nonexistentobj.o -i

# This validates standard-based handling of DW_FORM_ref_addr
runtest $d1 $d2 diederen/hello -i

# this coredumps libdwarf 20121130
runtest $d1 $d2 libc6fedora18/libc-2.16.so.debug -a

# Testing the wasted-space from not using LEB.
runtest $d1 $d2 enciso5/sample_S_option.o  -kE

if test $withlibelf = "withlibelf" ; then
  # These print object header (elf) information.
  runtest $d1 $d2 enciso5/sample_S_option.o  -E
  runtest $d1 $d2 enciso5/sample_S_option.o  -Ea
  runtest $d1 $d2 enciso5/sample_S_option.o  -Eh
  runtest $d1 $d2 enciso5/sample_S_option.o  -El
  runtest $d1 $d2 enciso5/sample_S_option.o  -Ei
  runtest $d1 $d2 enciso5/sample_S_option.o  -Ep
  runtest $d1 $d2 enciso5/sample_S_option.o  -Er
  runtest $d1 $d2 enciso5/sample_S_option.o  -Er -g
  runtest $d1 $d2 irixn32/dwarfdump  -Ef
  # Following finds no debug_loc.
  runtest $d1 $d2 enciso5/sample_S_option.o  -Eo
  # Following finds a debug_loc.
  runtest $d1 $d2 mucci/main.gcc -Eo
  #Following has no .debug_ranges
  runtest $d1 $d2 enciso5/sample_S_option.o  -ER
  #Following has .debug_ranges
  runtest $d1 $d2 mucci/main.gcc  -ER
  runtest $d1 $d2 mucci/main.gcc  -ER -g
  runtest $d1 $d2 enciso5/sample_S_option.o  -Es
  # The Et does nothing, we do not seem to have 
  # a .debug_pubtypes (IRIX specific) section anywhere.
  runtest $d1 $d2 enciso5/sample_S_option.o  -Et
  runtest $d1 $d2 enciso5/sample_S_option.o  -Ex
  runtest $d1 $d2 enciso5/sample_S_option.o  -Ed
else
  echo "=====SKIP a range of -E options, not usable with no libelf" 
fi

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
# Following is for URI testing
runtest $d1 $d2 moshe%2fhello  -U -i
#Put uri in name, do not mention the uri translatetion
# Following is for URI testing
runtest $d1 $d2 moshe%2fhello  -q -i

# The -h option exists now
if [ $withlibelf = "withlibelf" ]
then
  runtest $d1 $d2  moshe/hello -h 
else
  echo "====SKIP runtest $d1 $d2  moshe/hello -h nolibelf"
fi
runtest $d1 $d2  moshe/hello -a -vvv -R -M
runtest $d1 $d2  moshe/hello -a -vvv -R -M -g
runtest $d1 $d2  moshe/hello -ka -vvv -R -M
runtest $d1 $d2  moshe/a.out.t -a -vvv -R -M
runtest $d1 $d2  moshe/a.out.t -ka -vvv -R -M

if [ "$suppressbigdiffs" != "y" ]
then
  # Some of these are the same tests done based on $filelist
  runtest $d1 $d2  dwarf4/ddg4.5dwarf-4-gdb-index --print_fission
  runtest $d1 $d2  dwarf4/dd2g4.5dwarf-4 -a  -vvv -R -M
  runtest $d1 $d2  dwarf4/dd2g4.5dwarf-4 -ka -vvv -R -M
  runtest $d1 $d2  dwarf4/ddg4.5dwarf-4 -a  -vvv -R -M
  runtest $d1 $d2  dwarf4/ddg4.5dwarf-4 -ka -vvv -R -M
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
else
  echo "SKIP various dwarf4/ddg4.5dwarf-4 tests"
fi

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

if test $withlibelf = "withlibelf" ; then
  echo "=====START  findcu runtest.sh $top_srcdir $top_builddir $withlibelf $withlibz"
  cd findcu 
  sh runtest.sh $top_srcdir $top_builddir $withlibelf $withlibz 
  chkres $? 'findcu/cutest-of-a-libdwarf-interface'
  cd ..
else
  echo "=====SKIP  findcu runtest.sh $top_srcdir $top_builddir $withlibelf $withlibz"
fi



echo "=====START  test_harmless"
  libopts=''
  if test $withlibelf = "withlibelf" 
  then
    libopts='-lelf'
  fi
  if [ $withlibz = "withlibz" ]
  then
    libopts="$libopts -lz"
  fi
  echo "test_harmless: $CC -Wall -I$top_srcdir/libdwarf -I$top_builddir -I$top_builddir/libdwarf  -gdwarf $nlizeopt test_harmless.c  -o test_harmless $dwlib $libopts"
  $CC -Wall -I$top_srcdir/libdwarf -I$top_builddir -I$top_builddir/libdwarf  -gdwarf $nlizeopt test_harmless.c  -o test_harmless $dwlib $libopts
  chkres $? 'check harmless-error compiling test-harmless.c failed'
  ./test_harmless
  chkres $? 'check harmless-error execution failed'

if test $withlibelf = "withlibelf" ; then
  echo "=====START   dwgena/runtest.sh ../$d2"
  cd dwgena
  sh runtest.sh ../$d2
  r=$?
  chkresn $r 'dwgena/runtest.sh' 9
  cd ..
else
  echo "====SKIP dwgena/runtest.sh no libelf"
fi

if test $withlibelf = "withlibelf" ; then
  echo "=====START   dwgenc/runtest.sh ../$d2"
  cd dwgenc
  sh runtest.sh ../$d2
  r=$?
  chkresn $r 'dwgenc/runtest.sh' 1
  cd ..
else
  echo "====SKIP dwgenc/runtest.sh no libelf"
fi

echo "=====START   frame1/runtest.sh $top_srcdir $top_builddir $dwlib $withlibelf $withlibz"
cd frame1
sh runtest.sh $top_srcdir $top_builddir $dwlib $withlibelf $withlibz
r=$?
chkres $r frame1
cd ..

if [ $NLIZE = 'n' ]
then
  if [ $endian = 'L' ]
  then
    if [ $withlibelf = "withlibelf" ]
    then
      echo "=====START   dwarfextract/runtest.sh ../$d2 $top_builddir $top_srcdir $dwlib $withlibelf $withlibz"
      # This has serious problems with leaks, so
      # do not do $NLIZE for now..
      cd dwarfextract
      rm -f dwarfextract
      sh runtest.sh ../$d2 $top_builddir $top_srcdir $dwlib $withlibelf $withlibz
      chkres $?  dwarfextract
      cd ..
    else
        echo "====SKIP dwarfextract/runtest.sh $withlibelf $withlibz"
    fi
  else
    echo "=====SKIP  dwarfextract/runtest.sh with big endian test host"
  fi
else
echo "=====SKIP  dwarfextract/runtest.sh with NLIZE"
fi

echo "=====START   sandnes2/runtest.sh"
cd sandnes2
sh runtest.sh
r=$?
chkres $r  sandnes2
cd ..

if [ $NLIZE = 'n' ]
then
  echo "=====START   legendre/runtest.sh  $top_srcdir $top_builddir $withlibelf $withlibz"
  cd legendre
  sh runtest.sh $top_srcdir $top_builddir $withlibelf $withlibz
  r=$?
  chkres $r  legendre
  cd ..
else
  echo "=====SKIP   legendre/runtest.sh NLIZE as it has leaks"
fi

echo "=====START   enciso4/runtest.sh $d1 $d2"
cd enciso4
sh runtest.sh $d1 $d2 
chkres $?  enciso4
cd ..

# -g: use old dwarf loclist code.
runtest $d1 $d2 irixn32/dwarfdump -g  -x name=dwarfdump.conf  -x abi=mips-irix

# -u lets you provide a cu-name so you can select a CU and 
# skip others when printing DIEs
runtest $d1 $d2 irixn32/dwarfdump -u  dwconf.c -x name=dwarfdump.conf  -x abi=mips-irix
#The following is for URI style test completeness
runtest $d1 $d2 irixn32/dwarfdump -u  dwconf%2ec -x name=dwarfdump%2econf  -x abi=mips-irix
runtest $d1 $d2 irixn32/dwarfdump -u  /xlv44/6.5.15m/work/irix/lib/libc/libc_n32_M3/csu/crt1text.s  -x name=dwarfdump.conf -x abi=mips-irix

#Following tests -c and URI, the one restricted to GNU AS 
# only checks and reports on errors found in CUs with producer GNU AS.
runtest $d1 $d2 modula2/write-fixed -ka -cGNU%20AS  -M -R
runtest $d1 $d2 modula2/write-fixed -ka -M -R





runtest $d1 $d2  sparc/tcombined.o -a -R  -v -v -v -v -v -v
runtest $d1 $d2  sparc/tcombined.o -ka -R  -v -v -v -v -v -v
runtest $d1 $d2  kartashev2/combined.o -a -R  -v -v -v -v -v -v
runtest $d1 $d2  kartashev2/combined.o -ka -R  -v -v -v -v -v -v
runtest $d1 $d2  x86/dwarfdumpv4.3 -a -R  -v -v -v -v -v -v
runtest $d1 $d2  x86/dwarfdumpv4.3 -ka -R -v -v -v -v -v -v
runtest $d1 $d2  mucci/stream.o -a -R   -v -v -v -v -v -v
runtest $d1 $d2  mucci/stream.o -ka -R   -v -v -v -v -v -v
runtest $d1 $d2  mucci/stream.o -c -R -ka  
runtest $d1 $d2  mucci/stream.o -c -R -ka  -v -v -v -v -v -v
runtest $d1 $d2  mucci/main.o -a -R   -v -v -v -v -v -v
runtest $d1 $d2  mucci/main.o -ka -R   -v -v -v -v -v -v
runtest $d1 $d2  mucci/main.o -c -R -ka  -v -v -v -v -v -v
runtest $d1 $d2  mucci/main.o -c -R -ka  
runtest $d1 $d2 mucci/stream.o -a -R -M
runtest $d1 $d2 mucci/stream.o -i -e
runtest $d1 $d2 legendre/libmpich.so.1.0 -f -F 
runtest $d1 $d2 legendre/libmpich.so.1.0 -ka 

if test $withlibelf = "withlibelf" ; then
  for i in cell/c_malloc.o moore/simplec.o \
    enciso2/test_templates.o enciso3/test.o kartashev/combined.o \
    linkonce/comdattest.o louzon/ppcobj.o  mucci/main.o \
    mucci/main.o.gcc mucci/main.o.pathcc  \
    mucci/stream.o  saurabh/augstring.o \
    shihhuangti/t1.o shihhuangti/t2.o shihhuangti/tcombined.o \
    sparc/tcombined.o  atefail/ig_server  cell/c_malloc.o
  do
    runtest $d1 $d2 $i -o
    for o in -oi -ol -op -or -of -oo -oR
    do
      runtest $d1 $d2 $i $o
    done
  done
else
  echo "=====SKIP a range of -o options and test objects, no libelf"
fi





if [  $type = "dd2" ]
then
  # Running dd on this file is too slow. Only dd2 ok.
  # The issue is the number of registers and which
  # frame reg access interface is used for -f and -F.
  runtest $d1 $d2  ia32/libpt_linux_x86_r.so.1 -a -vvv -R -F
  runtest $d1 $d2  ia32/libpt_linux_x86_r.so.1 -c -vvv -R -F
fi

if [ $NLIZE = 'n' ]
then
  echo "=====START test-alex1/runtest.sh $dwlib $top_builddir $top_srcdir $withlibelf $withlibz"
  cd test-alex1
  chkres $?  "cd to test-alex1"
  sh runtest.sh $dwlib $top_builddir $top_srcdir $withlibelf $withlibz
  chkres $?  test-alex1
  cd ..
else
  echo "=====SKIP test-alex1/runtest.sh NLIZE as it has leaks"
fi

if [ $NLIZE = 'n' ]
then
  echo "=====START test-alex2/runtest.sh $dwlib $top_builddir $top_srcdir $withlibelf $withlibz"
  cd test-alex2
  chkres $?  "cd to test-alex2"
  sh runtest.sh $dwlib $top_builddir $top_srcdir $withlibelf $withlibz
  chkres $?  test-alex2
  cd ..
else
  echo "=====SKIP   test-alex2/runtest.sh NLIZE as it has leaks"
fi

# We need this to not do all DIE printing. FIXME
runtest $d1 $d2 macro5/dwarfdump-g3  -m
runtest $d1 $d2 macro5/dwarfdump-g3  -m -vvv
runtest $d1 $d2 macro5/dwarfdump-g3  -m -v
#Here we ask for DIE printing.
runtest $d1 $d2 macro5/dwarfdump-g3 -i -m
runtest $d1 $d2 macro5/dwarfdump-g3 -i -m -vvv
runtest $d1 $d2 macro5/dwarfdump-g3 -i -m -v

#Following 2 show some DW_AT_MIPS_fde difference. So -C works.
runtest $d1 $d2  irix64/libc.so -ka   -x name=dwarfdump.conf -x abi=mips-simple3
runtest $d1 $d2  irix64/libc.so -i    -x name=dwarfdump.conf -x abi=mips-simple3
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
runtest $d1 $d2  ppc2/powerpc-750-linux-gnu-hello-static -c   -R -v -v -v -v -v -v 
# This one works, return address reg 108 allowed.
runtest $d1 $d2  ppc2/powerpc-750-linux-gnu-hello-static -a -R -v -v -v -v -v -v -x name=./dwarfdump.conf  -x abi=ppc 
runtest $d1 $d2  ppc2/powerpc-750-linux-gnu-hello-static -c -R -v -v -v -v -v -v -x name=./dwarfdump.conf  -x abi=ppc 

runtest $d1 $d2  louzon/ppcobj.o -a  -v -v -v -v -v -v -x name=./dwarfdump.conf  -x abi=ppc
runtest $d1 $d2  louzon/ppcobj.o -ka -v -v -v -v -v -v -x name=./dwarfdump.conf  -x abi=ppc
runtest $d1 $d2  linkonce/comdattest.o -ka -v -v -v -v -v -v -x name=./dwarfdump.conf  -x abi=ppc
runtest $d1 $d2  linkonce/comdattest.o -a -v -v -v -v -v -v -x name=./dwarfdump.conf  -x abi=ppc
runtest $d1 $d2 atefail/ig_server -kt 
# Testing old interface to libdwarf with -g. IRIX only.
runtest $d1 $d2 irixn32/dwarfdump -f -g 
runtest $d1 $d2 irixn32/dwarfdump -f -x name=./dwarfdump.conf -x abi=mips-simple3  
runtest $d1 $d2 irixn32/dwarfdump -f -n -x name=./dwarfdump.conf -x abi=mips-simple3  
runtest $d1 $d2 ia32/mytry.ia32 -F -x name=dwarfdump.conf -x abi=x86
runtest $d1 $d2 ia64/mytry.ia64 -F -x name=dwarfdump.conf -x abi=ia64 
# The following is a misspelling of abi. Checks for error spelling so leave it in.
runtest $d1 $d2  irixn32/dwarfdump -f -x name=./dwarfdump.conf -x abi=mips-simple 
runtest $d1 $d2  irixn32/dwarfdump -f -x name=./dwarfdump.conf -x abi=mips-simple3 
runtest $d1 $d2  irixn32/dwarfdump -f -x name=./dwarfdump.conf -x abi=mips-irix
# Restrict to a single fde report
runtest $d1 $d2 irixn32/dwarfdump -f -H 1  -x name=./dwarfdump.conf -x abi=mips-irix
# Restrict to a single fde report with no function names shown
runtest $d1 $d2 irixn32/dwarfdump -f -H 1 -n  -x name=./dwarfdump.conf -x abi=mips-irix
# mips-irix2 is the new name for what was mips-simple.
runtest $d1 $d2  irixn32/dwarfdump -f -x name=./dwarfdump.conf -x abi=mips-irix2
runtest $d1 $d2  irixn32/dwarfdump -f -x name=./dwarfdump.conf -x abi=mips
runtest $d1 $d2 irixn32/dwarfdump -f -x name=./dwarfdump.conferr1 -x abi=mips
runtest $d1 $d2 val_expr/libpthread-2.5.so -f -v -v -x name=dwarfdump.conf -x abi=x86_64 
runtest $d1 $d2 irixn32/dwarfdump -i -G 
# restrict to a single CU
runtest $d1 $d2 irixn32/dwarfdump -i -H 1 
runtest $d1 $d2 irixn32/dwarfdump -ka
runtest $d1 $d2 irixn32/dwarfdump -i -G -d  

# Using old loclist call. Without -v nothing prints, so use -v.
# Adding -D is useless since then the attributes don't print at all so
# one cannot see the removal of offset from the loclist.
runtest $d1 $d2 irixn32/libc.so -g  -v -x name=dwarfdump.conf  -x abi=mips-irix
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
runtest $d1 $d2 cristi3/cristibadobj -m 
runtest $d1 $d2 cristi3/cristibadobj -m  -v -v -v

#Lets just drop this report. Wait till the end.
#echo PASS $goodcount  " after running the first test group"
#echo FAIL $failcount  " after running the first test group"
if [ x$shortest = "xn" ]
then
  for i in $filepaths
  do
     echo  "===== $i all options"
     for xtra in "-v" "-vv" "-vvv" "-D" "-H 2" 
     do
       for k in  $baseopts " -M" 
       do
	      runtest $d1 $d2 $i $k $xtra
          if [ x$withlibelf = "xwithlibelf" ]
          then
             # Force use of libelf
             runtest $d1 $d2 $i $k $xtra " -oi"
          fi
       done
     done
  done
  for i in $filepaths
  do
     echo ===== $i all checking options
     # -kd ensures we report the test statistics
     for xtra in "" "-kd"  "-ki" 
     do
       for k in  $kopts
       do
         runtest $d1 $d2 $i $k $xtra
       done
     done
  done
fi   
rm -f /tmp/dwba.$$
rm -f /tmp/dwbb.$$
if [ x$wrtimeo != "x" ]
then
  echo "base dwarfdump times"
  echo "$mypycom $mypydir/usertime.py baseline $otimeout"
  $mypycom $mypydir/usertime.py baseline $otimeout
  echo "new  dwarfdump times"
  echo "$mypycom $mypydir/usertime.py newversn $ntimeout"
  $mypycom $mypydir/usertime.py newversn $ntimeout
else
  echo "No /usr/bin/time data available to report"
fi
echo PASS $goodcount
echo FAIL $failcount
echo 'Ending regressiontests: DWARFTEST.sh' `date`
ndsecs=`date '+%s'`
showminutes() {
   t=`expr  \( $2 \- $1 \+ 29  \) \/ 60`
   echo "Run time in minutes: $t"
}
showminutes $stsecs $ndsecs
if [ $failcount -ne 0 ]
then
   exit 1
fi
exit 0
