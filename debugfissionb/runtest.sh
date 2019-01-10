#!/bin/sh
# Pass in simplereader path like ../simplereader
if [ $# -ne 1 ]
then
   echo FAIL: Missing required executable path.
   exit 1
fi
if [ ! -x $1 ]
then
   echo "FAIL: executable not marked executable: $1"
   exit 1
fi
sr=$1
. ../BASEFILES
isfail="n"
# Avoid spurious differences because of the names of the
# various dwarfdump versions being tested.
# This only deals with names like /tmp*dwarfdump2 and /tmp*dwarfdump
# and .*/dwarfdump2 and .*/dwarfdump
unifyddname () {
  nstart=$1
  nend=$2
  t1=junku1
  t2=junku2
  t3=junku3
  sed -e 'sx\/tmp.*\/dwarfdump2xdwarfdumpx' < $nstart >$t1
  sed -e 'sx\..*\/dwarfdump2xdwarfdumpx' <$t1 >$t2
  sed -e 'sx\/tmp.*\/dwarfdumpxdwarfdumpx' < $t2 >$t3
  sed -e 'sx\..*\/dwarfdumpxdwarfdumpx' < $t3 >$nend
  rm -f $t1
  rm -f $t2
  rm -f $t3
}


m() {
  dwdumper=$1
  baseline=$2
  if [ ! -f $baseline ]
  then
    touch $baseline
  fi
  opts=$3
  obj=./ld-new.dwp
  tmp=junk.${baseline}
  $sr $opts $obj 1> ${tmp} 2>&1
  r=$?
  if test  $r  -ne 0
  then
      echo exit_status  $r $sr $obj  >>$tmp
      return
  fi
  diff $baseline $tmp
  if test  $?  -ne 0
  then
      echo "FAIL test $baseline vs $tmp"
      echo "to update, mv $tmp $baseline"
      isfail="y"
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
  baseline=$2
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
  tmp=junk.${rtype}.${baseline}
  $mysr $opt $obj 1> ${tmp} 2>&1
  r=$?
  if test  $r  -ne 0
  then
      echo exit_status  $r   $sr $opt $obj   >>$tmp
  fi
  diff $baseline $tmp
  if test  $?  -ne 0
  then
      echo "FAIL test $baseline vs $tmp using $sr $opt $obj"
      echo "to update, mv $tmp $baseline"
      isfail="y"
      #exit 1
  fi
}

m2 $sr moa.base ../macho-kask/simplereaderi386  path
m2 $sr moax64.base ../macho-kask/simplereaderx86_64  path
m2 $sr moobject32.base ../macho-kask/mach-o-object32  path
m2 $sr moobject64.base ../macho-kask/mach-o-object64 path
m2 $sr moddg4.base ../macho-kask/dwarfdump_G4  path
m2 $sr pedll.base ../pe1/libexamine-0.dll  path
m2 $sr peexe64.base ../pe1/kask-dwarfdump_64.exe path
m2 $sr nodwarf.base ../kaufmann/t.o path

m2 $sr moa.base ../macho-kask/simplereaderi386 fd
m2 $sr moax64.base ../macho-kask/simplereaderx86_64 fd 

# for macho dSYM using fd we need to pass the true dSYM object name
# because we left simplereader simple in the fd case.
m2 $sr moobject32.base ../macho-kask/mach-o-object32.dSYM/Contents/Resources/DWARF/mach-o-object32 fd
m2 $sr moobject64.base ../macho-kask/mach-o-object64.dSYM/Contents/Resources/DWARF/mach-o-object64 fd
m2 $sr moddg4.base  ../macho-kask/dwarfdump_G4.dSYM/Contents/Resources/DWARF/dwarfdump_G4 fd

m2 $sr pedll.base ../pe1/libexamine-0.dll fd
m2 $sr peexe64.base ../pe1/kask-dwarfdump_64.exe fd
m2 $sr nodwarfexit1.base ../kaufmann/t.o fd

if [ $isfail = "y" ]
then
  echo FAIL debugfissionb  simplereader interfaces test
  exit 1
fi

echo PASS debugfissionb  simplereader interfaces test
exit 0
