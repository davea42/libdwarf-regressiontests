/*
  Copyright (c) 2021 David Anderson.  All rights reserved.
  This example is hereby placed in the public domain
  for anyone to use without restriction.  */
/*  test_testsectionnames.c 
    To use 
        make
        ./test_sectionnames irixn32/dwarfdump
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

static int
try_section_names(Dwarf_Debug dbg,Dwarf_Error *error)
{
    int errcount = 0;
    const char *secname = 0;
    int res = 0; 
    char *sn = ".debug_ranges";

    res = dwarf_get_ranges_section_name(dbg,&secname,error);
    if (res == DW_DLV_NO_ENTRY) {
        printf("No %s section\n",sn);
    } else if (res == DW_DLV_ERROR) {
        printf("Error in %s. Error is %s\n",sn,dwarf_errmsg(*error)); 
        ++errcount;
    } else {
        printf("The %s section name is %s\n",sn,secname);
    }
    secname = 0;

    sn = ".debug_aranges";
    res = dwarf_get_aranges_section_name(dbg,&secname,error);
    if (res == DW_DLV_NO_ENTRY) {
        printf("No %s section\n",sn);
    } else if (res == DW_DLV_ERROR) {
        printf("Error in %s. Error is %s\n",sn,dwarf_errmsg(*error)); 
        ++errcount;
    } else {
        printf("The %s section name is %s\n",sn,secname);
    }
    secname = 0;

    sn = ".debug_line";
    res = dwarf_get_line_section_name(dbg,&secname,error);
    if (res == DW_DLV_NO_ENTRY) {
        printf("No %s section\n",sn);
    } else if (res == DW_DLV_ERROR) {
        printf("Error in %s. Error is %s\n",sn,dwarf_errmsg(*error)); 
        ++errcount;
    } else {
        printf("The %s section name is %s\n",sn,secname);
    }
    secname = 0;

    sn = ".debug_str";
    res = dwarf_get_string_section_name(dbg,&secname,error);
    if (res == DW_DLV_NO_ENTRY) {
        printf("No %s section\n",sn);
    } else if (res == DW_DLV_ERROR) {
        printf("Error in %s. Error is %s\n",sn,dwarf_errmsg(*error)); 
        ++errcount;
    } else {
        printf("The %s section name is %s\n",sn,secname);
    }
    secname = 0;

    sn = ".debug_info";
    res = dwarf_get_die_section_name(dbg,TRUE,&secname,error);
    if (res == DW_DLV_NO_ENTRY) {
        printf("No %s section\n",sn);
    } else if (res == DW_DLV_ERROR) {
        printf("Error in %s. Error is %s\n",sn,dwarf_errmsg(*error)); 
        ++errcount;
    } else {
        printf("The %s section name is %s\n",sn,secname);
    }
    secname = 0;
    sn = ".debug_types";
    res = dwarf_get_die_section_name(dbg,FALSE,&secname,error);
    if (res == DW_DLV_NO_ENTRY) {
        printf("No %s section\n",sn);
    } else if (res == DW_DLV_ERROR) {
        printf("Error in %s. Error is %s\n",sn,dwarf_errmsg(*error)); 
        ++errcount;
    } else {
        printf("The %s section name is %s\n",sn,secname);
    }
    secname = 0;

    sn = ".debug_frame";
    res = dwarf_get_frame_section_name(dbg,&secname,error);
    if (res == DW_DLV_NO_ENTRY) {
        printf("No %s section\n",sn);
    } else if (res == DW_DLV_ERROR) {
        printf("Error in %s. Error is %s\n",sn,dwarf_errmsg(*error)); 
        ++errcount;
    } else {
        printf("The %s section name is %s\n",sn,secname);
    }
    secname = 0;

    sn = ".eh_frame";
    res = dwarf_get_frame_section_name_eh_gnu(dbg,&secname,error);
    if (res == DW_DLV_NO_ENTRY) {
        printf("No %s section\n",sn);
    } else if (res == DW_DLV_ERROR) {
        printf("Error in %s. Error is %s\n",sn,dwarf_errmsg(*error)); 
        ++errcount;
    } else {
        printf("The %s section name is %s\n",sn,secname);
    }
    secname = 0;
  
    sn = ".debug_macro";
    res = dwarf_get_macro_section_name(dbg,&secname,error);
    if (res == DW_DLV_NO_ENTRY) {
        printf("No %s section\n",sn);
    } else if (res == DW_DLV_ERROR) {
        printf("Error in %s. Error is %s\n",sn,dwarf_errmsg(*error)); 
        ++errcount;
    } else {
        printf("The %s section name is %s\n",sn,secname);
    }
    secname = 0;
  
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
        failcount += try_section_names(dbg,&error);
        res2 = dwarf_finish(dbg,&error);
        if (res2 == DW_DLV_ERROR) {
            printf("dwarf_finish of %s FAILED %s\n",
                filepath,
                dwarf_errmsg(error));
            ++failcount;
            continue;
        } 
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
