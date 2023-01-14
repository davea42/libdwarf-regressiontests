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

static int printed_secname = FALSE;
static int printed_hasform = FALSE;
static int first_cu_die_done = FALSE;

/*  Prints the offsets of children DIEs
    of the CU die at cudie_offset2
    For the object file irixn32/dwarfdump
    the correct output as shown by dwarfdump -G irixn32/dwarfdump
    is
    0x82 0x9d 0xb8 0xd0
    0xe0
    That is the first CU die test_pubsreader.c sees
    as currently in DWARFTEST.sh */
unsigned v[5] = {0x82,0x9d,0xb8,0xd0, 0xe0};

static int
print_offset_list(Dwarf_Off cudie_offset2,
    Dwarf_Bool is_info,
    Dwarf_Off * offbuf,
    Dwarf_Unsigned offcount,
    Dwarf_Unsigned cu_total_length)
{
    Dwarf_Unsigned u = 0;
    int            retv = 0;

    printf("CU die offset 0x%lx  is_info %u\n",
        (unsigned long)cudie_offset2,is_info);
    printf("list entry count %lu  CU total length 0x%lx\n",
        (unsigned long)offcount,
        (unsigned long)cu_total_length);
    printf("  ");
    for (u = 0; u < offcount; ++u) {
        if (u%4 == 0) {
            printf("\n  ");
        }
        printf(" 0x%lx",(unsigned long)offbuf[u]);
    }
    printf("\n");
    for (u = 0; u < offcount; ++u) {
        if (v[u] != offbuf[u]) {
            printf("FAIL comparing children offsets "
                "%lu 0x%lx 0x%lx\n",
                (unsigned long)u,
                (unsigned long)offbuf[u],
                (unsigned long)v[u]);
            ++retv;
        }
    }
    return retv;
}

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
    int errcnt = 0;

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
    if (!first_cu_die_done) {
        Dwarf_Off *offbuf = 0;
        Dwarf_Unsigned offcount = 0;
        Dwarf_Bool is_info = 0;
        Dwarf_Unsigned cu_total_length = 0;

        res = dwarf_cu_header_basics(cudie,0,
            &is_info,0,0,0,0,0,0,&cu_total_length,error);
        if (res == DW_DLV_OK) {
            res = dwarf_offset_list(dbg,
                cudie_offset2,
                is_info,&offbuf,&offcount,error);
            if (res == DW_DLV_OK) {
                errcnt += print_offset_list(cudie_offset2,is_info,
                    offbuf,offcount,cu_total_length);
                dwarf_dealloc(dbg, offbuf, DW_DLA_LIST);
                first_cu_die_done = TRUE;
            } else if (res==DW_DLV_ERROR) {
                printf("dwarf_offset_list ERROR: %s \n",
                    dwarf_errmsg(*error));
                return 1;
            } else {
                printf("dwarf_offset_list NO ENTRY\n");
            }
        } else if (res==DW_DLV_ERROR) {
            printf("dwarf_cu_header_basics ERROR: %s \n",
                dwarf_errmsg(*error));
            return 1;
        } else {
            printf("dwarf_cu_header_basics NO ENTRY\n");
        }
    }
    if (!printed_secname) {
        const char *secname = 0;
        res = dwarf_get_line_section_name_from_die(die,
            &secname,error);
        if (res == DW_DLV_OK) {
            printed_secname = TRUE;
            printf("Section Name of line section for die: %s\n",
                secname);
        } else if (res == DW_DLV_ERROR) {
            printf("ERROR getting line section name from die: %s\n",
                dwarf_errmsg(*error));
            dwarf_dealloc_error(dbg,*error);
            errcnt = 1;
        } else {
            printf("No line section\n");
        }
    }
    if (!printed_hasform) {
        Dwarf_Bool hasform = 0;
        Dwarf_Attribute attr = 0;
        Dwarf_Off atoff = 0;

        /*  Just here to test dwarf_hasform() */
        res = dwarf_attr(die,DW_AT_name,&attr,error);
        if (res == DW_DLV_OK) {
            res = dwarf_hasform(attr,DW_FORM_string,
                &hasform,error);
            if (res == DW_DLV_OK) {
                if (hasform) {
                    printf("DIE DW_AT_name has form "
                        "DW_FORM_string\n");
                    printed_hasform = TRUE;
                } else {
                    res = dwarf_hasform(attr,DW_FORM_strp,
                        &hasform,error);
                    if (res == DW_DLV_OK) {
                        printf("DIE DW_AT_name has form "
                            "DW_FORM_strp\n");
                        printed_hasform = TRUE;
                    } else {
                        if (res == DW_DLV_ERROR) {
                            printf("ERROR getting attr offset %s\n",
                                dwarf_errmsg(*error));
                            errcnt = 1;
                        } else {
                            printf("NO_ENTRY dwarf_hasform %s\n",
                                dwarf_errmsg(*error));
                            printf("Should be impossible\n");
                        }
                    }
                }
            }
            res = dwarf_attr_offset(die,attr,&atoff,error);
            if (res != DW_DLV_OK) {
                if (res == DW_DLV_ERROR) {
                    printf("ERROR getting attr offset %s\n",
                        dwarf_errmsg(*error));
                    errcnt = 1;
                } else {
                    printf("NO_ENTRY getting attr offset %s\n",
                        dwarf_errmsg(*error));
                    printf("Should be impossible\n");
                    errcnt = 1;
                }
            } else {
                printf("Attr offset of AT_name : 0x%lu\n",
                    (unsigned long)atoff);
            }
        } else {
            if (res == DW_DLV_ERROR) {
                printf("dwarf_attr call FAILED. bad. error: %s\n",
                    dwarf_errmsg(*error));
                errcnt = 1;
            }
        }
        if (attr) {
            dwarf_dealloc_attribute(attr);
            attr = 0;
        }
        if (res == DW_DLV_ERROR) {
            printf("Error in testing hasform %s\n",
                dwarf_errmsg(*error));
            dwarf_dealloc_error(dbg,*error);
            errcnt = 1;
        }
    }
    dwarf_dealloc_die(die);
    dwarf_dealloc_die(cudie);
    return errcnt;
}

static int
try_funcs(Dwarf_Debug dbg)
{
    Dwarf_Error error = 0;
    int res = 0;
    int errcount = 0;
    Dwarf_Global* typep = 0;
    Dwarf_Signed count = 0;
    Dwarf_Signed printcount = 0;
    Dwarf_Signed i = 0;

    printf("Entry try_funcs()\n");
    res = dwarf_globals_by_type(dbg,
        DW_GL_FUNCS,&typep,&count,
        &error);
    if (res == DW_DLV_NO_ENTRY) {
        printf("No funcs in file\n");
        return 0;
    }
    if (res == DW_DLV_ERROR) {
        printf("FAIL dwarf_get_funcs %s\n",
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
        Dwarf_Global t = typep[i];

        printf("globals %2ld",(long)i);
        res = dwarf_globname(t,&retname,&error);
        if (res == DW_DLV_ERROR) {
            printf("FAIL dwarf_globname %s\n",
                dwarf_errmsg(error));
            errcount = 1;
            break;
        }
        res = dwarf_global_die_offset(t,&die_offset, &error);
        if (res == DW_DLV_ERROR) {
            printf("FAIL dwarf_func_die_offset %s\n",
                dwarf_errmsg(error));
            errcount = 1;
            break;
        }
        if (res == DW_DLV_NO_ENTRY) {
            printf("FAIL dwarf_func_die_offset %s\n",
                "DW_DLV_NO_ENTRY");
            errcount = 1;
            break;
        }
        res = dwarf_global_cu_offset(t,&cuhdr_offset, &error);
        if (res == DW_DLV_ERROR) {
            printf("FAIL dwarf_func_cu_offset %s",
                dwarf_errmsg(error));
            errcount = 1;
            break;
        }
        if (res == DW_DLV_NO_ENTRY) {
            printf("FAIL dwarf_func_cu_offset %s\n",
                "DW_DLV_NO_ENTRY");
            errcount = 1;
            break;
        }
        res = dwarf_global_name_offsets(t,&name2,
            &die_offset2,&cudie_offset2,&error);
        if (res == DW_DLV_ERROR) {
            printf("FAIL dwarf_func_name_offsets %s",
                dwarf_errmsg(error));
            errcount = 1;
            break;
        }
        if (res == DW_DLV_NO_ENTRY) {
            printf("FAIL dwarf_global_name_offsets %s\n",
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
            "dwarf_funcs ",&error);
        errcount += res;
    }
    dwarf_globals_dealloc(dbg,typep,count);
    return errcount;
}

static int
try_weaks(Dwarf_Debug dbg)
{
    Dwarf_Error error = 0;
    int res = 0;
    int errcount = 0;
    Dwarf_Global* typep = 0;
    Dwarf_Signed count = 0;
    Dwarf_Signed printcount = 0;
    Dwarf_Signed i = 0;

    printf("Entry try_weaks()\n");
    res = dwarf_globals_by_type(dbg,
        DW_GL_WEAKS,&typep,&count,
        &error);
    if (res == DW_DLV_NO_ENTRY) {
        printf("No weaknames in file\n");
        return 0;
    }
    if (res == DW_DLV_ERROR) {
        printf("FAIL dwarf weaks %s\n",
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
        Dwarf_Global t = typep[i];

        printf("globals %2ld",(long)i);
        res = dwarf_globname(t,&retname,&error);
        if (res == DW_DLV_ERROR) {
            printf("FAIL dwarf_weakname %s\n",
                dwarf_errmsg(error));
            errcount = 1;
            break;
        }
        res = dwarf_global_die_offset(t,&die_offset, &error);
        if (res == DW_DLV_ERROR) {
            printf("FAIL dwarf_weak_die_offset %s\n",
                dwarf_errmsg(error));
            errcount = 1;
            break;
        }
        if (res == DW_DLV_NO_ENTRY) {
            printf("FAIL dwarf_weak_die_offset %s\n",
                "DW_DLV_NO_ENTRY");
            errcount = 1;
            break;
        }
        res = dwarf_global_cu_offset(t,&cuhdr_offset, &error);
        if (res == DW_DLV_ERROR) {
            printf("FAIL dwarf_weak_cu_offset %s",
                dwarf_errmsg(error));
            errcount = 1;
            break;
        }
        if (res == DW_DLV_NO_ENTRY) {
            printf("FAIL dwarf_weak_cu_offset %s\n",
                "DW_DLV_NO_ENTRY");
            errcount = 1;
            break;
        }
        res = dwarf_global_name_offsets(t,&name2,
            &die_offset2,&cudie_offset2,&error);
        if (res == DW_DLV_ERROR) {
            printf("FAIL dwarf_weak_name_offsets %s",
                dwarf_errmsg(error));
            errcount = 1;
            break;
        }
        if (res == DW_DLV_NO_ENTRY) {
            printf("FAIL dwarf_weak_name_offsets %s\n",
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
            "dwarf_weaks ",&error);
        errcount += res;
    }
    dwarf_globals_dealloc(dbg,typep,count);
    return errcount;
}

static int
try_vars(Dwarf_Debug dbg)
{
    Dwarf_Error error = 0;
    int res = 0;
    int errcount = 0;
    Dwarf_Global* typep = 0;
    Dwarf_Signed count = 0;
    Dwarf_Signed printcount = 0;
    Dwarf_Signed i = 0;

    printf("Entry try_vars()\n");
    res = dwarf_globals_by_type(dbg,DW_GL_VARS,&typep,&count,
        &error);
    if (res == DW_DLV_NO_ENTRY) {
        printf("No varnames in file\n");
        return 0;
    }
    if (res == DW_DLV_ERROR) {
        printf("FAIL dwarf_get_vars %s\n",
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
        Dwarf_Global t = typep[i];

        printf("globals %2ld",(long)i);
        res = dwarf_globname(t,&retname,&error);
        if (res == DW_DLV_ERROR) {
            printf("FAIL dwarf_varname %s\n",
                dwarf_errmsg(error));
            errcount = 1;
            break;
        }
        res = dwarf_global_die_offset(t,&die_offset, &error);
        if (res == DW_DLV_ERROR) {
            printf("FAIL dwarf_var_die_offset %s\n",
                dwarf_errmsg(error));
            errcount = 1;
            break;
        }
        if (res == DW_DLV_NO_ENTRY) {
            printf("FAIL dwarf_var_die_offset %s\n",
                "DW_DLV_NO_ENTRY");
            errcount = 1;
            break;
        }
        res = dwarf_global_cu_offset(t,&cuhdr_offset, &error);
        if (res == DW_DLV_ERROR) {
            printf("FAIL dwarf_var_cu_offset %s",
                dwarf_errmsg(error));
            errcount = 1;
            break;
        }
        if (res == DW_DLV_NO_ENTRY) {
            printf("FAIL dwarf_var_cu_offset %s\n",
                "DW_DLV_NO_ENTRY");
            errcount = 1;
            break;
        }
        res = dwarf_global_name_offsets(t,&name2,
            &die_offset2,&cudie_offset2,&error);
        if (res == DW_DLV_ERROR) {
            printf("FAIL dwarf_var_name_offsets %s",
                dwarf_errmsg(error));
            errcount = 1;
            break;
        }
        if (res == DW_DLV_NO_ENTRY) {
            printf("FAIL dwarf_var_name_offsets %s\n",
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
            "dwarf_vars ",&error);
        errcount += res;
    }
    dwarf_globals_dealloc(dbg,typep,count);
    return errcount;
}
static int
try_global(Dwarf_Debug dbg)
{
    Dwarf_Error error = 0;
    int res = 0;
    int errcount = 0;
    Dwarf_Global* typep = 0;
    Dwarf_Signed count = 0;
    Dwarf_Signed printcount = 0;
    Dwarf_Signed i = 0;

    printf("Entry try_global()\n");
    res = dwarf_get_globals(dbg,&typep,&count,
        &error);
    if (res == DW_DLV_NO_ENTRY) {
        printf("No globals in file\n");
        return 0;
    }
    if (res == DW_DLV_ERROR) {
        printf("FAIL dwarf_get_globals %s\n",
            dwarf_errmsg(error));
        return 1;
    }
    printcount = (count > PRINT_LIMIT)?
        PRINT_LIMIT:count;
    printf("globals count: %ld max, printing %ld\n",
        (long)count,(long)printcount);
    for (i = 0; i < printcount; ++i) {
        char * retname = 0;
        char * name2 = 0;
        Dwarf_Off die_offset = 0;
        Dwarf_Off cuhdr_offset = 0;
        Dwarf_Off die_offset2 = 0;
        Dwarf_Off cudie_offset2 = 0;
        Dwarf_Global t = typep[i];

        printf("globals %2ld",(long)i);
        res = dwarf_globname(t,&retname,&error);
        if (res == DW_DLV_ERROR) {
            printf("FAIL dwarf_typename %s\n",
                dwarf_errmsg(error));
            errcount = 1;
            break;
        }
        res = dwarf_global_die_offset(t,&die_offset,
            &error);
        if (res == DW_DLV_ERROR) {
            printf("FAIL dwarf_global_type_die_offset %s\n",
                dwarf_errmsg(error));
            errcount = 1;
            break;
        }
        if (res == DW_DLV_NO_ENTRY) {
            printf("FAIL dwarf_global_die_offset %s\n",
                "DW_DLV_NO_ENTRY");
            errcount = 1;
            break;
        }
        res = dwarf_global_cu_offset(t,&cuhdr_offset,
            &error);
        if (res == DW_DLV_ERROR) {
            printf("FAIL dwarf_global_cu_offset %s",
                dwarf_errmsg(error));
            errcount = 1;
            break;
        }
        if (res == DW_DLV_NO_ENTRY) {
            printf("FAIL dwarf_global_cu_offset %s\n",
                "DW_DLV_NO_ENTRY");
            errcount = 1;
            break;
        }
        res = dwarf_global_name_offsets(t,&name2,
            &die_offset2,&cudie_offset2,&error);
        if (res == DW_DLV_ERROR) {
            printf("FAIL dwarf_type_name_offsets %s",
                dwarf_errmsg(error));
            errcount = 1;
            break;
        }
        if (res == DW_DLV_NO_ENTRY) {
            printf("FAIL dwarf_global_name_offsets %s\n",
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
            "dwarf_global ",&error);
        errcount += res;
    }

    dwarf_globals_dealloc(dbg,typep,count);
    return errcount;
}

static int
try_type(Dwarf_Debug dbg)
{
    Dwarf_Error error = 0;
    int res = 0;
    int errcount = 0;
    Dwarf_Global* typep = 0;
    Dwarf_Signed count = 0;
    Dwarf_Signed printcount = 0;
    Dwarf_Signed i = 0;

    printf("Entry try_type()\n");
    res = dwarf_globals_by_type(dbg, DW_GL_TYPES,&typep,&count,
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
        Dwarf_Global t = typep[i];

        printf("typename %2ld",(long)i);
        res = dwarf_globname(t,&retname,&error);
        if (res == DW_DLV_ERROR) {
            printf("FAIL dwarf_typename %s\n",
                dwarf_errmsg(error));
            errcount = 1;
            break;
        }
        res = dwarf_global_die_offset(t,&die_offset,
            &error);
        if (res == DW_DLV_ERROR) {
            printf("FAIL dwarf_type_die_offset %s\n",
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
        res = dwarf_global_cu_offset(t,&cuhdr_offset,
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
        res = dwarf_global_name_offsets(t,&name2,
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

    dwarf_globals_dealloc(dbg,typep,count);
    return errcount;
}

static int
try_pubtype(Dwarf_Debug dbg)
{
    Dwarf_Error error = 0;
    int res = 0;
    int errcount = 0;
    Dwarf_Global* typep = 0;
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
        Dwarf_Global t = typep[i];

        printf("pubtypename %2ld",(long)i);
        res = dwarf_globname(t,&retname,&error);
        if (res == DW_DLV_ERROR) {
            printf("FAIL dwarf_pubtypename %s\n",
                dwarf_errmsg(error));
            errcount = 1;
            break;
        }
        res = dwarf_global_die_offset(t,&die_offset,
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
        res = dwarf_global_cu_offset(t,&cuhdr_offset,
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
        res = dwarf_global_name_offsets(t,&name2,
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
    dwarf_globals_dealloc(dbg,typep,count);
    return errcount;
}

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
    int old1 = 0;
    int old2 = 0;
    int old3 = 0;
    unsigned int uint1 = 0;
    unsigned int uint2= 0;
    unsigned int uint3= 0;
    const unsigned char *intext =
        (const unsigned char *)"A few characters to work with";

    if (i >= argc) {
        printf("test_pubsreader not given file to open\n");
        printf("test_pubsreader exits\n");
        return 1;
    }
    if (!strcmp(argv[i],"--suppress-de-alloc-tree")) {
        dwarf_set_de_alloc_flag(FALSE);
        ++i;
    }
    if (i >= argc) {
        printf("test_pubsreader not given file to open\n");
        printf("test_pubsreader exits\n");
        return 1;
    }

    old1 = dwarf_set_stringcheck(1);
    old2 = dwarf_set_stringcheck(0);
    old3 = dwarf_set_stringcheck(0);
    if (old1) {
        printf("FAIL: dwarf_set_stringcheck default was "
            "wrong at %d\n", old1);
        failcount++;
    }
    if (!old2) {
        printf("FAIL: dwarf_set_stringcheck set wrong at %d\n",
            old2);
        failcount++;
    }
    if (old3) {
        printf("FAIL: dwarf_set_stringcheck set wrong at %d\n",
            old3);
        failcount++;
    }
    if (!failcount) {
        printf("PASS dwarf_set_stringcheck() tests\n");
    } else {
        printf("FAIL dwarf_set_stringcheck() tests\n");
    }
    /*  zero is the init value always used. */
    uint1 = dwarf_basic_crc32(intext,strlen( (const char *)intext),0);
    printf("dwarf_basic_crc32() 1 returns 0x%x\n",uint1);

    uint2 = dwarf_basic_crc32(intext,strlen((const char *)intext),
        uint1);
    printf("dwarf_basic_crc32() 2 returns 0x%x\n",uint2);

    uint3 = dwarf_basic_crc32(intext,strlen( (const char *)intext),0);
    printf("dwarf_basic_crc32() 3 returns 0x%x\n",uint3);
    if (uint3 != 0x2535a0d3) {
        /*  While the PRINT BY BYTE below is endian sensitive, the
            value as integer is not. This should not fail, the
            value shows the same bigendian or littleendian. */
        printf("FAIL crc expected 0x2535a0d3 got 0x%x\n",uint3);
        failcount++;
    }
    { /* PRINT BY BYTE */
        if (sizeof(uint3) != 4) {
            printf("Size of integer type is %u bytes\n",
                (unsigned int)sizeof(uint3));
            printf("So we don't show in plain byte format as it won't"
                " be right\n");
        } else {
            printf("crc32() 3 value as bytes so endian matters: "
                "0x<suppressed for BE/LE compatibility>\n");
#if 0
            Printing the bytes means endianness matters in
            regression testing.
            Lets not do that.
            for (s=(char *)&uint3; ui < 4; ++ui,++s) {
                printf("%02x ",(unsigned char)*s);
            }
            printf("\n");
#endif
        }
    }
    if (uint1 != uint3) {
        printf("FAIL dwarf_basic_crc32() first and "
            "third not identical!\n");
        /* Indicates not repeatable for some reason */
        failcount++;
    }
    if (uint1 == uint2) {
        printf("FAIL dwarf_basic_crc32() first second identical!\n");
        /* Indicates the init value ignored!. That's wrong. */
        failcount++;
    }

    for ( ; i < argc; ++i) {
        const char *filepath = 0;
        const char *base = 0;
        int res2 = 0;
        int res = DW_DLV_ERROR;
        Dwarf_Debug dbg = 0;
        char          true_path_buf[2000];
        unsigned int  true_path_buflen = 2000;
        char          *str1 = "dummy1";
        char          *str2 = "dummy1";
        char          *dl_path_array[2];
        unsigned int   dl_path_array_size = 2;
        unsigned char  dl_path_source;

        dl_path_array[0] = str1;
        dl_path_array[1] = str2;
        filepath = argv[i];
        base = basename(filepath);
        res = dwarf_init_path_dl(filepath,
            true_path_buf,true_path_buflen,
            DW_GROUPNUMBER_ANY,errhand,errarg,&dbg,
            dl_path_array,
            dl_path_array_size,
            &dl_path_source,
            &error);
        (void)dl_path_source; /* avoid warning */
        if (res == DW_DLV_ERROR) {
            printf("Init of %s FAILED",
                dwarf_errmsg(error));
            ++failcount;
            continue;
        } else if (res == DW_DLV_NO_ENTRY) {
            printf("Init of %s No Entry\n",base);
            continue;
        }
        failcount += try_global(dbg);
        failcount += try_pubtype(dbg);
        failcount += try_type(dbg);
        failcount += try_vars(dbg);
        failcount += try_weaks(dbg);
        failcount += try_funcs(dbg);
        res2 = dwarf_finish(dbg);
        if (res2 == DW_DLV_NO_ENTRY) {
            printf("dwarf_finish of %s DW_DLV_NO_ENTRY\n",
                base);
            ++failcount;
            continue;
        }
    }
    if (failcount) {
        return 1;
    }
    return 0;
}
