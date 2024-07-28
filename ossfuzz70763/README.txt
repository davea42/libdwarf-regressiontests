
28 July 2024
We have an infinite recursion in this sequence, so
we have an error and fail to get out of the loop.
Wuite possibly _dwarf_internal_global_formref_b() is
the one leading us astray on failure?

#398 0x55ad0c13706f in find_sig8_target_as_global_offset libdwarf/src/lib/libdwarf/dwarf_form.c:678:11

#399 0x55ad0c135b86 in _dwarf_internal_global_formref_b libdwarf/src/lib/libdwarf/dwarf_form.c:944:15

#400 0x55ad0c13482a in dwarf_global_formref_b libdwarf/src/lib/libdwarf/dwarf_form.c:753:11

#401 0x55ad0c13482a in dwarf_global_formref libdwarf/src/lib/libdwarf/dwarf_form.c:739:11

#402 0x55ad0c110bcf in find_cu_die_base_fields libdwarf/src/lib/libdwarf/dwarf_die_deliv.c:1447:23

#403 0x55ad0c110bcf in finish_cu_context_via_cudie_inner libdwarf/src/lib/libdwarf/dwarf_die_deliv.c:696:19

#404 0x55ad0c110bcf in finish_up_cu_context_from_cudie libdwarf/src/lib/libdwarf/dwarf_die_deliv.c:1718:15

#405 0x55ad0c110bcf in _dwarf_create_a_new_cu_context_record_on_list libdwarf/src/lib/libdwarf/dwarf_die_deliv.c:1860:11

#406 0x55ad0c241935 in _dwarf_find_CU_Context_given_sig libdwarf/src/lib/libdwarf/dwarf_find_sigref.c:147:20

#407 0x55ad0c241935 in _dwarf_internal_find_die_given_sig8 libdwarf/src/lib/libdwarf/dwarf_find_sigref.c:208:10

#408 0x55ad0c13706f in find_sig8_target_as_global_offset libdwarf/src/lib/libdwarf/dwarf_form.c:678:11
