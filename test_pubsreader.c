/*
  Copyright (c) 2021 David Anderson.  All rights reserved.
  This example is hereby placed in the public domain
  for anyone to use without restriction.  */
/*  test_pubsreader.c 
    This is an example of code reading dwarf .debug_typenames
    and .debug_gnu_typenames to ensure the libdwarf functions
    are tested.
    Some of the sections are SGI only so the test program
    should, in part, be aimed at an IRIX executable.

    To use on an IRIX object do:
        make
        ./test_pubsreader irixn32/dwarfdump
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


/*  This always emits a singld newline
    at the end. */
static int
die_findable_check(Dwarf_Debug dbg,
    Dwarf_Off die_offset,
    Dwarf_Off cudie_offset2,
    const char *whichtype,
    Dwarf_Error *error)
{
    int res = 0;
    char *diename = 0;
    char *diename2 = 0;
    Dwarf_Bool is_info = TRUE;
    Dwarf_Die die = 0;
    Dwarf_Die cudie = 0;

    /*  We do not really know if it references
        .debug_info or .debug_types, but supposedly
        it will always be .debug_info  */
    res = dwarf_offdie_b(dbg,die_offset,is_info,
        &die,error);
    if (res == DW_DLV_NO_ENTRY){
        printf(" dwarf_offdie_b NO ENTRY? in %s\n",whichtype);
        return 1;
    }   
    if (res == DW_DLV_ERROR){
        printf(" dwarf_offdie_b ERROR in %s: %s\n",
            whichtype,
            dwarf_errmsg(*error));
        return 1;
    }   
    res = dwarf_diename(die,&diename,error);
    if (res == DW_DLV_NO_ENTRY){
        /* do nothing */
    } else if (res == DW_DLV_ERROR){
        printf(" dwarf_diename ERROR whichtype %s: %s\n",
            whichtype,
            dwarf_errmsg(*error));
        return 1;
    }else {
        printf(" (die name %s)",diename);
    }
    res = dwarf_offdie_b(dbg,cudie_offset2,is_info,
        &cudie,error);
    if (res == DW_DLV_NO_ENTRY){
        printf(" dwarf_offdie_b cu die on %s: NO ENTRY?\n",
            whichtype);
        return 1;
    }  
    if (res == DW_DLV_ERROR){
        printf(" dwarf_offdie_b cu die ERROR in %s: %s\n",
            whichtype,
            dwarf_errmsg(*error));
        return 1;
    }  
    res = dwarf_diename(cudie,&diename2,error);
    if (res == DW_DLV_NO_ENTRY){
        /* do nothing */
    } else if (res == DW_DLV_ERROR){
        printf(" dwarf_diename cu ERROR in %s: %s\n",
            whichtype,
            dwarf_errmsg(*error));
        return 1;
    }else {
         printf(" (cu die name %s)",diename2);
    }
    printf("\n");
    dwarf_dealloc_die(die);
    dwarf_dealloc_die(cudie);
    return 0;
}

static int
try_type(Dwarf_Debug dbg)
{
    Dwarf_Error error = 0;
    int res = 0;
    int errcount = 0;
    Dwarf_Type* typep = 0;
    Dwarf_Signed count = 0;
    Dwarf_Signed printcount = 0;
    Dwarf_Signed i = 0;

    printf("Entry try_type()\n");
    res = dwarf_get_types(dbg,&typep,&count,
        &error); 
    if (res == DW_DLV_NO_ENTRY) {
        printf("No types in file\n");
        return 0;
    }
    if (res == DW_DLV_ERROR) {
        printf("FAIL dwarf_get_types %s\n",
            dwarf_errmsg(error));
        return 1;
    }
    printcount = (count > PRINT_LIMIT)?
        PRINT_LIMIT:count;
    printf("types count: %ld max, printing %ld\n",
        (long)count,(long)printcount);
    for (i = 0; i < printcount; ++i) {
        char * retname = 0;
        char * name2 = 0;
        Dwarf_Off die_offset = 0;
        Dwarf_Off cuhdr_offset = 0;
        Dwarf_Off die_offset2 = 0;
        Dwarf_Off cudie_offset2 = 0;
        Dwarf_Type t = typep[i];

        printf("typename %2ld",(long)i);
        res = dwarf_typename(t,&retname,&error);
        if (res == DW_DLV_ERROR) {
            printf("FAIL dwarf_typename %s\n",
                dwarf_errmsg(error));
            errcount = 1;
            break;
        }
        res = dwarf_type_die_offset(t,&die_offset,
           &error);
        if (res == DW_DLV_ERROR) {
            printf("FAIL dwarf_type_type_die_offset %s\n",
                dwarf_errmsg(error));
            errcount = 1;
            break;
        }
        if (res == DW_DLV_NO_ENTRY) {
            printf("FAIL dwarf_type_type_die_offset %s\n",
                "DW_DLV_NO_ENTRY");
            errcount = 1;
            break;
        }
        res = dwarf_type_cu_offset(t,&cuhdr_offset,
           &error);
        if (res == DW_DLV_ERROR) {
            printf("FAIL dwarf_type_cu_offset %s",
                dwarf_errmsg(error));
            errcount = 1;
            break;
        }
        if (res == DW_DLV_NO_ENTRY) {
            printf("FAIL dwarf_type_cu_offset %s\n",
                "DW_DLV_NO_ENTRY");
            errcount = 1;
            break;
        }
        res = dwarf_type_name_offsets(t,&name2,
           &die_offset2,&cudie_offset2,&error);
        if (res == DW_DLV_ERROR) {
            printf("FAIL dwarf_type_name_offsets %s",
                dwarf_errmsg(error));
            errcount = 1;
            break;
        }
        if (res == DW_DLV_NO_ENTRY) {
            printf("FAIL dwarf_type_name_offsets %s\n",
                "DW_DLV_NO_ENTRY");
            errcount = 1;
            break;
        }
        if (retname != name2) {
            printf(" name mismatch: %s vs %s\n",
                retname,name2);
            ++errcount;
            continue;
        }
        if (die_offset != die_offset2) {
            printf(" die offset mismatch: 0x%lx vs 0x%lx\n",
                (unsigned long)die_offset,
                (unsigned long)die_offset2);
            ++errcount;
            continue;
        }
        if (cuhdr_offset >= cudie_offset2) {
            /* CU offset meaning CU header offset */
            printf(" cu offset mismatch: 0x%lx vs 0x%lx\n",
                (unsigned long)cuhdr_offset,
                (unsigned long)cudie_offset2);
            ++errcount;
            continue;
        }
        if (cuhdr_offset >= die_offset) {
            printf(" die vs cu offset mismatch: %ld vs %ld\n",
                (unsigned long)die_offset,
                (unsigned long)cudie_offset2);
            ++errcount;
            continue;
        }
        printf("  \"%s\"",retname);
        res= die_findable_check(dbg,die_offset,cudie_offset2,
            "dwarf_types ",&error);
        errcount += res;
    }

    dwarf_types_dealloc(dbg,typep,count);
    return errcount;
}


static int
try_pubtype(Dwarf_Debug dbg)
{
    Dwarf_Error error = 0;
    int res = 0;
    int errcount = 0;
    Dwarf_Type* typep = 0;
    Dwarf_Signed count = 0;
    Dwarf_Signed printcount = 0;
    Dwarf_Signed i = 0;

    printf("Entry try_pubtype()\n");
    res = dwarf_get_pubtypes(dbg,&typep,&count,
        &error); 
    if (res == DW_DLV_NO_ENTRY) {
        printf("No pubtypes in file\n");
        return 0;
    }
    if (res == DW_DLV_ERROR) {
        printf("FAIL dwarf_get_pubtypes %s\n",
            dwarf_errmsg(error));
        return 1;
    }
    printcount = (count > PRINT_LIMIT)?
        PRINT_LIMIT:count;
    printf("pubtypes count: %ld max, printing %ld\n",
        (long)count,(long)printcount);
    for (i = 0; i < printcount; ++i) {
        char * retname = 0;
        char * name2 = 0;
        Dwarf_Off die_offset = 0;
        Dwarf_Off cuhdr_offset = 0;
        Dwarf_Off die_offset2 = 0;
        Dwarf_Off cudie_offset2 = 0;
        Dwarf_Type t = typep[i];

        printf("pubtypename %2ld",(long)i);
        res = dwarf_pubtypename(t,&retname,&error);
        if (res == DW_DLV_ERROR) {
            printf("FAIL dwarf_pubtypename %s\n",
                dwarf_errmsg(error));
            errcount = 1;
            break;
        }
        res = dwarf_pubtype_type_die_offset(t,&die_offset,
           &error);
        if (res == DW_DLV_ERROR) {
            printf("FAIL dwarf_pubtype_type_die_offset %s\n",
                dwarf_errmsg(error));
            errcount = 1;
            break;
        }
        if (res == DW_DLV_NO_ENTRY) {
            printf("FAIL dwarf_pubtype_type_die_offset %s\n",
                "DW_DLV_NO_ENTRY");
            errcount = 1;
            break;
        }
        res = dwarf_pubtype_cu_offset(t,&cuhdr_offset,
           &error);
        if (res == DW_DLV_ERROR) {
            printf("FAIL dwarf_pubtype_cu_offset %s",
                dwarf_errmsg(error));
            errcount = 1;
            break;
        }
        if (res == DW_DLV_NO_ENTRY) {
            printf("FAIL dwarf_pubtype_cu_offset %s\n",
                "DW_DLV_NO_ENTRY");
            errcount = 1;
            break;
        }
        res = dwarf_pubtype_name_offsets(t,&name2,
           &die_offset2,&cudie_offset2,&error);
        if (res == DW_DLV_ERROR) {
            printf("FAIL dwarf_pubtype_name_offsets %s",
                dwarf_errmsg(error));
            errcount = 1;
            break;
        }
        if (res == DW_DLV_NO_ENTRY) {
            printf("FAIL dwarf_pubtype_name_offsets %s\n",
                "DW_DLV_NO_ENTRY");
            errcount = 1;
            break;
        }
        if (retname != name2) {
            printf(" name mismatch: %s vs %s\n",
                retname,name2);
            ++errcount;
            continue;
        }
        if (die_offset != die_offset2) {
            printf(" die offset mismatch: 0x%lx vs 0x%lx\n",
                (unsigned long)die_offset,
                (unsigned long)die_offset2);
            ++errcount;
            continue;
        }
        if (cuhdr_offset >= cudie_offset2) {
            /* CU offset meaning CU header offset */
            printf("cu offset mismatch: 0x%lx vs 0x%lx\n",
                (unsigned long)cuhdr_offset,
                (unsigned long)cudie_offset2);
            ++errcount;
            continue;
        }
        if (cuhdr_offset >= die_offset) {
            printf("die vs cu offset mismatch: %ld vs %ld\n",
                (unsigned long)die_offset,
                (unsigned long)cuhdr_offset);
            ++errcount;
            continue;
        }
        printf("  \"%s\"\n",retname);
        res= die_findable_check(dbg,die_offset,cudie_offset2,
            "dwarf_pubtypes ",&error);
        errcount += res;
    }
    dwarf_pubtypes_dealloc(dbg,typep,count);
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
        printf("test_pubsreader not given file to open\n");
        printf("test_pubsreader exits\n");
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
            0,0,0,&error);
        if (res == DW_DLV_ERROR) {
            printf("Init of %s FAILED",
                dwarf_errmsg(error));
            ++failcount;
            continue;
        } else if (res == DW_DLV_NO_ENTRY) {
            printf("Init of %s No Entry\n",filepath);
            continue;
        }
        failcount += try_pubtype(dbg);
        failcount += try_type(dbg);
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
