/*
    Copyright (c) 2021 David Anderson.  All rights reserved.
    This example is hereby placed in the public domain
    for anyone to use without restriction.  */
/*  test_bitoffset.c 
    Test of dwarf_bitoffset() function.
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
print_offset_list(Dwarf_Off cudie_offset2,
    Dwarf_Bool is_info,
    Dwarf_Off * offbuf,
    Dwarf_Unsigned offcount,
    Dwarf_Unsigned cu_total_length)
{
    Dwarf_Unsigned u = 0;
    int retv = 0;

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
             printf("FAIL comparing children offsets %lu 0x%lx 0x%lx\n",
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
         } else if(res==DW_DLV_ERROR) {
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
            printf("Section Name of line section for die: %s\n",secname);
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
                    printf("DIE DW_AT_name has form DW_FORM_string\n");
                    printed_hasform = TRUE;
                } else {
                    res = dwarf_hasform(attr,DW_FORM_strp,
                        &hasform,error);
                    if (res == DW_DLV_OK) {
                        printf("DIE DW_AT_name has form DW_FORM_strp\n");
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

FIXME
static int
try_bitoffset(Dwarf_debug dbg)

{
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
            &error);
        if (res == DW_DLV_ERROR) {
            printf("Init of %s FAILED",
                dwarf_errmsg(error));
            ++failcount;
            continue;
        } else if (res == DW_DLV_NO_ENTRY) {
            printf("Init of %s No Entry\n",filepath);
            continue;
        }
        failcount += try_bitoffset(dbg);
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
