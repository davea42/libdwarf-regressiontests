#! /bin/sh
# Assumes a single argument, naming a dwarfdump.
# So it's testing the new dwarfdump.


dd=../dwarfdump
ourzcat=zcat
which gzcat 1>/dev/null
if [ $? -eq 0 ]
then
  # On MacOS gzcat does what zcat does on Linux.
  ourzcat=gzcat
fi

$dd -a archive.o  >junk1.new
$ourzcat archiveo.base.gz >archiveo.base
diff archiveo.base junk1.new
if [  $?  -ne 0 ]
then
    echo FAIL debugfission archiveo test 1
    echo "update via : mv junk1.new archiveo.base ; gzip archiveo.base"
    exit 1
fi

$dd -a archive.dwo  >junk2.new
$ourzcat archivedwo.base.gz >archivedwo.base
diff archivedwo.base junk2.new
if [  $?  -ne 0 ]
then
    echo FAIL debugfission archivedwo 2
    echo "update via : mv junk2.new archivedwo.base ; gzip archivedwo.base"
    exit 1
fi

$dd -a target.o  >junk3.new
$ourzcat targeto.base.gz > targeto.base
diff  targeto.base junk3.new
if [  $?  -ne 0 ]
then
    echo FAIL debugfission targeto test 3
    echo "update via : mv junk3.new targeto.base ; gzip targeto.base"
    exit 1
fi

$dd -a target.dwo  >junk4.new
$ourzcat targetdwo.base.gz > targetdwo.base
diff  targetdwo.base junk4.new
if [  $?  -ne 0 ]
then
    echo FAIL debugfission targetdwo 4
    echo "update via : mv junk4.new targetdwo.base ; gzip targetdwo.base"
    exit 1
fi

$dd -i -M -vvv archive.dwo  >junk5.new
$ourzcat archivedwo-iMvvv.base.gz >archivedwo-iMvvv.base
diff archivedwo-iMvvv.base junk5.new
if [  $?  -ne 0 ]
then
    echo FAIL debugfission archivedwo-iMvvv 5
    echo "update via : mv junk5.new archivedwo-iMvvv.base ; gzip archivedwo-iMvvv.base"
    exit 1
fi
echo "PASS debugfission/runtest.sh"
exit 0
