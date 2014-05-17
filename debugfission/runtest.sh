#! /bin/sh
# Assumes a single argument, naming a dwarfdump.
# So it's testing the new dwarfdump.


dd=$1

$dd -a archive.o  >junk1.new
zcat archiveo.base.gz >archiveo.base
diff archiveo.base junk1.new
if [  $?  -ne 0 ]
then
    echo FAIL debugfission archiveo test 1
    exit 1
fi

$dd -a archive.dwo  >junk2.new
zcat archivedwo.base.gz >archivedwo.base
diff archivedwo.base junk2.new
if [  $?  -ne 0 ]
then
    echo FAIL debugfission archivedwo 2
    exit 1
fi

$dd -a target.o  >junk3.new
zcat targeto.base.gz > targeto.base
diff  targeto.base junk3.new
if [  $?  -ne 0 ]
then
    echo FAIL debugfission targeto test 3
    exit 1
fi

$dd -a target.dwo  >junk4.new
zcat targetdwo.base.gz > targetdwo.base
diff  targetdwo.base junk4.new
if [  $?  -ne 0 ]
then
    echo FAIL debugfission targetdwo 4
    exit 1
fi

$dd -i -M -vvv archive.dwo  >junk5.new
zcat archivedwo-iMvvv.base.gz >archivedwo-iMvvv.base
diff archivedwo-iMvvv.base junk5.new
if [  $?  -ne 0 ]
then
    echo FAIL debugfission archivedwo-iMvvv 5
    exit 1
fi
echo PASS debug fission
exit 0
