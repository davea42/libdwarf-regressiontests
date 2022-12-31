/*
  Copyright (c) 2021 David Anderson.  All rights reserved.
  This example is hereby placed in the public domain
  for anyone to use without restriction.  */
/*  test_arange.c 
    To use 
        make
        ./test_arange 
*/
#include "config.h"
/* Windows specific header files */
#if defined(_WIN32) && defined(HAVE_STDAFX_H)
#include "stdafx.h"
#endif /* HAVE_STDAFX_H */
#ifdef HAVE_SYS_TYPES_H
#include <sys/types.h> /* For open() */
#endif /* HAVE_SYS_TYPES_H */
#ifdef HAVE_SYS_STAT_H
#include <sys/stat.h>  /* For open() */
#endif /* HAVE_SYS_STAT_H */
#include <fcntl.h>     /* For open() */
#ifdef HAVE_STDLIB_H
#include <stdlib.h> /* for exit() */
#endif /* HAVE_STDLIB_H */
#ifdef _WIN32
#include <io.h> /* for close() */
#elif defined HAVE_UNISTD_H
#include <unistd.h> /* for close() */
#endif /* _WIN32 */
#include <stdio.h>
#include <errno.h>
#ifdef HAVE_STRING_H
#include <string.h>
#endif /* HAVE_STRING_H */
#ifdef HAVE_STDINT_H
#include <stdint.h> /* For uintptr_t */
#endif /* HAVE_STDINT_H */
#include "dwarf.h"
#include "libdwarf.h"
#include "libdwarf_private.h"

#ifndef O_RDONLY
/*  This is for a Windows environment */
# define O_RDONLY _O_RDONLY
#endif

#ifdef _O_BINARY
/*  This is for a Windows environment */
#define O_BINARY _O_BINARY
#else
# ifndef O_BINARY
# define O_BINARY 0  /* So it does nothing in Linux/Unix */
# endif
#endif /* O_BINARY */

#define TRUE 1
#define FALSE 0
#define PRINT_LIMIT 5

/*  We set up a case where we can call dwarf_get_arange()
    to test it. */
static int
try_arange(Dwarf_Debug dbg,Dwarf_Error *error)
{
    Dwarf_Arange *aranges = 0;
    Dwarf_Signed arcount = 0;
    Dwarf_Signed selectedarange = 0;
    Dwarf_Addr   selectedaddr = 0;
    Dwarf_Signed i = 0;
    int res = 0;
    int errcount = 0;

    res = dwarf_get_aranges(dbg,&aranges,&arcount,error);
    if (res == DW_DLV_NO_ENTRY) {
        printf("No aranges\n");
        return 0;
    }
    if (res == DW_DLV_ERROR) {
        printf("ERROR calling dwarf_aranges! %s\n",
            dwarf_errmsg(*error));
        return 1;
    }
    for (i = 0; i <arcount; ++i) {
        Dwarf_Unsigned segment = 0;
        Dwarf_Unsigned segment_entry_size = 0;
        Dwarf_Addr  start = 0;
        Dwarf_Unsigned length = 0;
        Dwarf_Off cu_die_offset = 0;

        res = dwarf_get_arange_info_b(aranges[i],
            &segment, &segment_entry_size,
            &start, &length, &cu_die_offset,error);
        if (res != DW_DLV_OK) {
            if (res == DW_DLV_ERROR) {
                printf("ERROR calling dwarf_get_arange_info_b! %s\n",
                    dwarf_errmsg(*error));
                return 1;
            }
            printf("NO_ENTRY calling dwarf_get_arange_info_b! \n");
            return 1;
        }
        if (i > 5 && start && !selectedarange ) {
            selectedarange = i;
            selectedaddr = start;
            printf("Selected index %ld addr 0x%lx\n",
                (long)i,(unsigned long)start);
        }
        if (i < 10) {
            /* Just printing a few. */
            printf("arange %ld addr 0x%lx \n",
                (long)i,(unsigned long)start);
        }
    }
    if (selectedarange) {
        Dwarf_Unsigned segment = 0;
        Dwarf_Unsigned segment_entry_size = 0;
        Dwarf_Addr  start = 0;
        Dwarf_Unsigned length = 0;
        Dwarf_Off cu_die_offset = 0;
        Dwarf_Arange selar = 0;

        res = dwarf_get_arange(aranges,arcount,selectedaddr,
            &selar,error);
        if (res != DW_DLV_OK) {
            if (res == DW_DLV_ERROR) {
                printf("ERROR calling dwarf_get_arange! %s\n",
                    dwarf_errmsg(*error));
                return 1;
            }
            printf("NO_ENTRY calling dwarf_get_arange_info_b! \n");
            return 1;
        }

        res = dwarf_get_arange_info_b(selar,
            &segment, &segment_entry_size,
            &start, &length, &cu_die_offset,error);
        if (res != DW_DLV_OK) {
            if (res == DW_DLV_ERROR) {
                printf("ERROR X calling dwarf_get_arange_info_b! %s\n",
                    dwarf_errmsg(*error));
                return 1;
            }
            printf("NO_ENTRY X calling dwarf_get_arange_info_b! \n");
            return 1;
        }
        if (start != selectedaddr) {
            printf("Got the wrong arange somehow!. 0x%lx vs 0x%lx\n",
                (unsigned long)start,(unsigned long)selectedaddr);
            return 1;
        } else {
            printf("dwarf_get_arange worked ok found addr 0x%lx."
                "  Passed\n",(unsigned long)start);
        }
        /*  The address here won't match. Should get NO_ENTRY */
        res = dwarf_get_arange(aranges,arcount,27,
            &selar,error);
        if (res != DW_DLV_NO_ENTRY) {
            if (res == DW_DLV_ERROR) {
                printf("ERROR calling dwarf_get_arange! %s\n",
                    dwarf_errmsg(*error));
                return 1;
            }
            printf("bogus match calling dwarf_get_arange\n");
            return 1;
        } else {
            printf("dwarf_get_arange worked ok, did not find "
                "fake addr 0x%lx."
                "  Passed\n",(unsigned long)27);
        }
    }
    for (i = 0; i <arcount; ++i) {
        dwarf_dealloc(dbg,aranges[i],DW_DLA_ARANGE);
    }
    dwarf_dealloc(dbg,aranges,DW_DLA_LIST);
    return errcount;
}

int
main(int argc, char **argv)
{
    Dwarf_Error error;
    Dwarf_Handler errhand = 0;
    Dwarf_Ptr errarg = 0;
    int i = 1;
    int failcount = 0;

    if (i >= argc) {
        printf("test_sectionnames not given file to open\n");
        printf("test_sectionnames exits\n");
        return 1;
    }
    if (!strcmp(argv[i],"--suppress-dealloc-tree")) {
        dwarf_set_de_alloc_flag(FALSE);
        ++i;
    }
    if (i >= argc) {
        printf("test_sectionnames not given file to open\n");
        printf("test_sectionnames exits\n");
        return 1;
    }

    for( ; i < argc; ++i) {
        const char *filepath = 0;
        int res2 = 0;
        int res = DW_DLV_ERROR;
        Dwarf_Debug dbg = 0;

        filepath = argv[i];
        res = dwarf_init_path(filepath,
            0,0,
            DW_GROUPNUMBER_ANY,errhand,errarg,&dbg,
            &error);
        if (res == DW_DLV_ERROR) {
            printf("Init of %s FAILED\n",
                dwarf_errmsg(error));
            ++failcount;
            continue;
        } else if (res == DW_DLV_NO_ENTRY) {
            printf("Init of %s No Entry\n",filepath);
            continue;
        }
        printf("Opened objectfile %s\n",filepath);
        failcount += try_arange(dbg,&error);
        res2 = dwarf_finish(dbg);
        if (res2 == DW_DLV_NO_ENTRY) {
            printf("dwarf_finish of %s DW_DLV_NO_ENTRY\n",
                filepath);
            ++failcount;
            continue;
        }
    }
    if (failcount) {
         return 1;
    }
    return 0;
}
