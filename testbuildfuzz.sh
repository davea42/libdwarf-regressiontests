

src=~/dwarf/code/
fdir=$src/fuzz
lib=$src/src/lib/libdwarf
testsrc=~/dwarf/regressiontests/testbuildfuzz.c

list='
fuzz_aranges.c
fuzz_crc_32.c
fuzz_crc.c
fuzz_debug_addr_access.c
fuzz_debuglink.c
fuzz_debug_str.c
fuzz_die_cu_attrs.c
fuzz_die_cu_attrs_loclist.c
fuzz_die_cu.c
fuzz_die_cu_info1.c
fuzz_die_cu_offset.c
fuzz_die_cu_print.c
fuzz_dnames.c
fuzz_findfuncbypc.c
fuzz_gdbindex.c
fuzz_globals.c
fuzz_gnu_index.c
fuzz_init_b.c
fuzz_init_binary.c
fuzz_init_path.c
fuzz_macro_dwarf4.c
fuzz_macro_dwarf5.c
fuzz_rng.c
fuzz_set_frame_all.c
fuzz_showsectgrp.c
fuzz_simplereader_tu.c
fuzz_srcfiles.c
fuzz_stack_frame_access.c
fuzz_str_offsets.c
fuzz_tie.c
fuzz_xuindex.c'


for s in $list
do
   x="cc -I $lib $testsrc $fdir/$s "
   echo $x
   $x
   if [ $? -ne 0 ]
   then
      echo "compile failed"
      exit 1
   fi
done
