/*
    Copyright (c) 2021 David Anderson.  All rights reserved.
    This example is hereby placed in the public domain
    for anyone to use without restriction.  */
/*  test_simple_libfuncs.c
    To use
        make
        ./test_simple_libfuncs
*/
#include "config.h"
/* Windows specific header files */
#if defined(_WIN32) && defined(HAVE_STDAFX_H)
#include "stdafx.h"
#endif /* HAVE_STDAFX_H */
#include <stdio.h>
#include <string.h>
#include "dwarf.h"
#include "libdwarf.h"

#define FALSE 0
#define TRUE 1

static const char *
basename(const char *path)
{
    const char *cp = path;
    int lastslash = -1;
    int i = 0;

    for ( ; *cp ; ++cp,++i) {
        if (*cp == '/') {
            lastslash = i;
        }
    }
    if (lastslash == -1) {
        return path;
    }
    if (!*cp && (lastslash+1) == i) {
        if (i >1) {
            return path+lastslash-1;
        }
        return path+lastslash;
    }
    return path+lastslash+1;
}

int
main(int argc, char **argv)
{
    Dwarf_Error error;
    Dwarf_Handler errhand = 0;
    Dwarf_Ptr errarg = 0;
    int i = 1;
    int failcount = 0;
    const char *filepath = 0;
    const char *base= 0;
    int res = DW_DLV_ERROR;
    Dwarf_Debug dbg = 0;

    if (i >= argc) {
        printf("test_simplelibfuncs not given file to open\n");
        printf("test_simplelibfuncs exits\n");
        return 1;
    }
    if (!strcmp(argv[i],"--suppress-de-alloc-tree")) {
        dwarf_set_de_alloc_flag(FALSE);
        ++i;
    }
    if (i >= argc) {
        printf("test_simplelibfuncs not given file to open.\n");
        printf("test_simplelibfuncs exits.\n");
        return 1;
    }
    filepath = argv[i];
    base = basename(filepath);
    res = dwarf_init_path(filepath,
        0,0,
        DW_GROUPNUMBER_ANY,errhand,errarg,&dbg,
        &error);
    if (res == DW_DLV_ERROR) {
        printf("Init of %s FAILED\n",
            dwarf_errmsg(error));
        ++failcount;
    } else if (res == DW_DLV_NO_ENTRY) {
        printf("Init of %s No Entry\n",base);
        ++failcount;
    }
    if (!failcount) {
        int oldapply = 0;
        int oldapplyb = 0;
        Dwarf_Small origasize = 0;
        Dwarf_Small origasizeb = 0;
        void       *funcp = 0;
        Dwarf_Half  offset_size = 0;
        int         ires = 0;

        printf("Opened objectfile %s\n",base);
        /*  The default for the flag is 1. */
        oldapply = dwarf_set_reloc_application(0);
        oldapplyb = dwarf_set_reloc_application(oldapply);
        if (!oldapply  ||  oldapplyb) {
            printf("ERROR: dwarf_set_reloc_application()"
                "is not working");
            ++failcount;
        }
        /*  We know 1 is a bogus address size (in practice) */
        origasize = dwarf_set_default_address_size(dbg,1);
        origasizeb = dwarf_set_default_address_size(dbg,origasize);
        if (origasize == origasizeb) {
            printf("ERROR: dwarf_set_address_size()"
                "is not working");
            ++failcount;
        }
        funcp = dwarf_get_endian_copy_function(dbg);
        if (!funcp) {
            printf("ERROR: dwarf_get_endian_copy_function()"
                "is not working");
            ++failcount;
        }

        /*  getting the object file version of offset size,
            not DWARF offset size. */
        ires = dwarf_get_offset_size(dbg,&offset_size,0);
        if (ires != DW_DLV_OK) {
            printf("ERROR: dwarf_get_offset_size()"
                "return value %d, not DW_DLV_OK",ires);
            ++failcount;
        } else {
            if (offset_size != 4 && offset_size != 8) {
                printf("ERROR: dwarf_get_offset_size()"
                    "return offset size %d, not 4 or 8\n",
                    offset_size); 
                ++failcount;
            }
        }
        
    }
    if (failcount) {
        return 1;
    }
    printf("PASS test_simple_libfuncs\n");
    return 0;
}
