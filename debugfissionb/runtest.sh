#!/bin/sh

sr=../simplereader
. ../BASEFILES.sh
ts=$testsrc/debugfissionb
tf=$bldtest/debugfissionb
isfail="n"

. $testsrc/BASEFUNCS.sh

# Adding --no-dup-attr-check  to runs of
# simplereader as of 0.12.0
# it is now in simplereader to actually
# make this true.
#  Some of the tu/cu hashchecks are on a PE
# object with duplicate attrs and we do not
# want the dups to be noticed so we test the
# hash calls in libdwarf.

cpifmissing $testsrc/kaufmann/t.o t.o

m() {
  dwdumper=$1
  baseline=$ts/$2
  if [ ! -f $baseline ]
  then
    touch $baseline
  fi
  opts=$3
  # read uncompressed in $tf as of 18 Nov 2025
  obj=$tf/ld-new.dwp
  tmp=junk.$2
  echo "$sr $opts $obj to $tmp"
  $sr --no-dup-attr-check $opts $obj 1> ${tmp} 2>&1
  r=$?
  if test  $r  -ne 0
  then
      n=`basename $obj`
      echo exit_status  $r $sr $n  >>$tmp
      return
  fi
  diff $diffopt $baseline $tmp
  if test  $?  -ne 0
  then
      echo "fail test $baseline vs $tmp"
      echo "to update, mv $tf/$tmp $baseline"
      isfail="y"
      echo "rerun: $ts/runtest.sh"
  fi
}

m $sr thash1.base '--tuhash=058027967850060b'
m $sr thash2.base '--tufissionhash=b1fcaeaf1d01cc85'
m $sr chash1.base '--cuhash=032ccfcfbc7c9d26'
m $sr chash2.base '--cufissionhash=0441e597e1e38549'
# We have the hash arg so output is limited in size.
# The following two are  not much of a test of options. 
# Just a simple basic run.
m $sr chash2.base '--cufissionhash=0441e597e1e38549' '--passnullerror'
m $sr chash2.base '--cufissionhash=0441e597e1e38549' '--passnullerror' '--simpleerrhand'

m2() {
  mysr=$1
  baseline=$ts/$2
  obj=$3
  rtype=$4
  if [ $rtype = "fd" ]
  then
     # use dwarf_init() which uses dwarf_init_b()
     opt="--use-init-fd"
  else
     # use dwarf_init_path()
     opt=""
  fi
  if [ ! -f $baseline ]
  then
    touch $baseline
  fi
  tmp=junk.${rtype}.$2
  echo "$mysr $opt $obj to $tmp"
  $mysr --no-dup-attr-check $opt $obj 1> ${tmp} 2>&1
  r=$?
  if test  $r  -ne 0
  then
      n=`basename $obj`
      echo exit_status  $r   $sr $opt $n   >>$tmp
  fi
  diff $baseline $tmp
  if test  $?  -ne 0
  then
      echo "fail test $baseline vs $tmp using $sr $opt $obj"
      echo "to update, mv $tf/$tmp $baseline"
      isfail="y"
      echo "rerun: $ts/runtest.sh" 
      #exit 1
  fi
}

m2 $sr moa.base $testsrc/macho-kask/simplereaderi386  path
m2 $sr moax64.base $testsrc/macho-kask/simplereaderx86_64  path
m2 $sr moobject32.base $testsrc/macho-kask/mach-o-object32  path
m2 $sr moobject64.base $testsrc/macho-kask/mach-o-object64 path
m2 $sr moddg4.base $testsrc/macho-kask/dwarfdump_G4  path
m2 $sr pedll.base $testsrc/pe1/libexamine-0.dll  path
m2 $sr peexe64.base $testsrc/pe1/kask-dwarfdump_64.exe path
m2 $sr nodwarf.base t.o path

m2 $sr moa.base $testsrc/macho-kask/simplereaderi386 fd
m2 $sr moax64.base $testsrc/macho-kask/simplereaderx86_64 fd 

# for macho dSYM using fd we need to pass the true dSYM object name
# because we left simplereader simple in the fd case.
m2 $sr moobject32.base $testsrc/macho-kask/mach-o-object32.dSYM/Contents/Resources/DWARF/mach-o-object32 fd
m2 $sr moobject64.base $testsrc/macho-kask/mach-o-object64.dSYM/Contents/Resources/DWARF/mach-o-object64 fd
m2 $sr moddg4.base  $testsrc/macho-kask/dwarfdump_G4.dSYM/Contents/Resources/DWARF/dwarfdump_G4 fd

m2 $sr pedll.base $testsrc/pe1/libexamine-0.dll fd
m2 $sr peexe64x.base $testsrc/pe1/kask-dwarfdump_64.exe fd
m2 $sr nodwarfexit1.base t.o fd

if [ $isfail = "y" ]
then
  echo fail debugfissionb  simplereader interfaces test
  echo "rerun: $ts/runtest.sh"
  exit 1
fi
echo "PASS debugfissionb/runtest.sh  simplereader interfaces test"
exit 0
