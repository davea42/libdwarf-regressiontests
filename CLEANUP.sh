#!/bin/sh
# Clean up the temp files left behind by a test.
# Unwise to run this except in a regressiontest
# source or test directory.
. ./SHALIAS.sh
(cd dwgena ; make clean)
(cd debugfission ; make clean)
# The following is copied from the kaufmann dir. Drop it.
rm -f debugfissionb/t.o
# The /tmp/dwa* files are lock files to prevent running two regr.
# tests at the same time as two-at-once will not work!
rm -f /tmp/dwa.*
rm -f /tmp/dwb.*

rm -f config.h.in~
rm -f dwgenc/runx
rm -f dwgenc/testoutput.o
rm -f filelist/filelist
rm -f filelist/filelista
rm -f filelist/filelistb
rm -f filelist/filelistc
rm -f filelist/filelistd
rm -f libdwallocs
rm -f */libdwallocs
rm -rf libbld
rm -f test_arange
rm -f test_pubsreader
rm -f test_bitoffset
rm -f test_sectionnames
rm -f dwarf_names.h
rm -f dwarf_names_enum.h
rm -f dwarf_names_new.h
rm -f dwn_s_out
rm -f dwn_t_out
rm -f frame1/framexlocal.c
rm -f frame1/frame2018.out
rm -f frame1/selregs2018.out
rm -f tmp*
rm -f testendian
rm -f tmp*err*
rm -f core
rm -f dwba
rm -f dwbb
rm -f */core
rm -f junk*
rm -f ALL*
rm -f libdwarf.a
rm -f testoutput
rm -f libdwoldframecol.a
rm -f test_harmless
rm -f checkforlibz/a.out
rm -f checkforlibz/junk*
rm -f baddie1/testincorrect*
rm -f bad-dwop/badskipbranchd3.o
rm -f bad-dwop/badskipbranchd5.o
rm -f BASEFILES.sh
rm -f baddie1/dwarfdump.conf
rm -f bigobj/dwarfdump.conf
rm -f data16/dwarfdump.conf
rm -f debugfission/dwarfdump.conf
rm -f debugfissionb/dwarfdump.conf
rm -f debuglink/dwarfdump.conf
rm -f dwarfextract/dwarfdump.conf
rm -f dwgena/dwarfdump.conf
rm -f dwgenc/dwarfdump.conf
rm -f emre2/dwarfdump.conf
rm -f enciso4/dwarfdump.conf
rm -f fails
rm -f guilfanov/dwarfdump.conf
rm -f implicitconst/dwarfdump.conf
rm -f test-alex1/test1
rm -f test-alex1/test2
rm -f test-alex1/outdiffs
rm -f test-alex1/out1
rm -f test-alex1/out2
rm -f test-alex2/test2
rm -f test-alex2/out1
rm -f dwarfextract/test1.new
rm -f dwarfextract/test1out
rm -f dwarfextract/dwarfextractc
rm -f dwarfextract/test2out
rm -f dwarfextract/testc.new
rm -f williamson/newout
rm -f williamson/newunminout
rm -f williamson/vgcore*
rm -f BASEFILES
rm -f navarro/getglobals
rm -f hughes2/*core*
rm -f dwarfextract/testcout
rm -f dwarfextract/basecstdout
rm -f dwarfextract/basestdout
rm -f dwarfextract/dwarfextract
rm -f findcu/testoutput
rm -f findcu/cutest
rm -f kartashev/kart2.tar
rm -f tn
rm -f to
rm -f */junk*
rm -f a.out
rm -f dwarfnames-s.c
rm -f dwarfnames-s
rm -f dwarfnames-t.c
rm -f dwarfnames-t
rm -f legendre/frame_test1
rm -f legendre/frame_test2
rm -f OF* testOfile
rm -f dwarfdump
rm -f dwarfgen
rm -f simplereader
rm -f junkckpath
# The following only really do anything if one
# accidentally did a build configure under regressiontests.
rm -f config.h.in~
rm -f showsectiongroups
rm -f jitreader
rm -rf dwarfdump/
rm -rf dwarfexample/
rm -rf dwarfgen/
rm -rf libdwarf/
rm -f libtool
rm -f stamp-h1
rm -f Makefile
rm -f config.h
rm -f config.log
rm -f config.status
rm -f bigobj/bigobject
rm -f bigobj/makebig
rm -f bigobj/a.out
rm -f bigobj/junk*
rm -f moore/dwarfdump.conf
rm -f mustacchi/dwarfdump.conf
rm -f nolibelf/dwarfdump.conf
rm -f offsetfromlowpc/dwarfdump.conf
rm -f runx
rm -f sandnes2/dwarfdump.conf
rm -f scripts/filelist
rm -f strsize/dwarfdump.conf
rm -f supplementary/dwarfdump.conf
rm -f testoffdie/dwarfdump.conf
rm -f williamson/dwarfdump.conf
rm -f base
rm -f checkforlibzstd/a.out
rm -f dwarfdump.O
rm -f findfuncbypc

