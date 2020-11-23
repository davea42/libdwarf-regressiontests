#! /bin/sh
# Assumes a single argument, naming a dwarfdump.
# So it's testing the new dwarfdump.


dd=../dwarfdump
ourzcat=zcat
. ../BASEFILES
ts=$testsrc/debugfission
tf=$bldtest/debugfission

which gzcat 1>/dev/null
if [ $? -eq 0 ]
then
  # On MacOS gzcat does what zcat does on Linux.
  ourzcat=gzcat
fi

b=archiveo.base
bz=archiveo.base.gz
$dd -a $ts/archive.o  >junk1.new
$ourzcat $ts/$bz > $b
diff $b junk1.new
if [  $?  -ne 0 ]
then
    echo fail debugfission archiveo test 1
    echo "update in $tf via : mv junk1.new $b"
    echo " gzip $b ; mv $bz  $ts/$bz"
    exit 1
fi

b=archivedwo.base
bz=archivedwo.base.gz
jt=junk2.new
$dd -a $ts/archive.dwo  >$jt
$ourzcat $ts/$bz >$b
diff $b $jt
if [  $?  -ne 0 ]
then
    echo fail debugfission archivedwo 2
    echo "update in $tf via : mv $jt $b"
    echo " gzip $b ; mv $bz  $ts/$bz"
    exit 1
fi

b=targeto.base
bz=targeto.base.gz
jt=junk3.new
$dd -a $ts/target.o  >$jt
$ourzcat $ts/$bz > $b
diff  $b $jt
if [  $?  -ne 0 ]
then
    echo fail debugfission targeto test 3
    echo "update via : $jt $b"
    echo " gzip $b ; mv $bz  $ts/$bz"
    exit 1
fi

b=targetdwo.base
bz=targetdwo.base.gz
jt=junk4.new
$dd -a $ts/target.dwo  >$jt
$ourzcat $ts/$bz > $b
diff  $b $jt
if [  $?  -ne 0 ]
then
    echo fail debugfission targetdwo 4
    echo "update via : cp $jt $b"
    echo " gzip $b ; mv $bz  $ts/$bz"
    exit 1
fi

b=archivedwo-iMvvv.base
bz=archivedwo-iMvvv.base.gz
jt=junk5.new
$dd -i -M -vvv $ts/archive.dwo  >$jt
$ourzcat $ts/$bz >$b
diff  $b $jt
if [  $?  -ne 0 ]
then
    echo fail debugfission archivedwo-iMvvv 5
    echo "update via : cp $jt $b"
    echo " gzip $b ; mv $bz  $ts/$bz"
    exit 1
fi
echo "PASS debugfission/runtest.sh"
exit 0
