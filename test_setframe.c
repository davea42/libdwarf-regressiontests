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

static struct testv {
    int tabsize;
    int cfa_val;
    int same_val;
    int undefined_val;
    int initial_val;
} vals[] = {
{ 200,300,302,302,302}, /* sameval==undefinedval */
{ 200,301,301,302,302}, /* cfa ==sameval */
{ 200,301,301,302,302}, /* cfa ==undefval */
{ 200,300,301,302,304}, /* initial val not same or undef */
{ 200,300,301,199,301}, /* undef val <= tabsize */
{ 200,300,199,302,302}, /* same  val <= tabsize */
{ 200,100,301,302,302}, /* cfa <= tabsize */
};

static int failcount = 0;
static void
testn(unsigned u,
    Dwarf_Debug dbg, 
    Dwarf_Error *error)
{
    struct testv *t = 0;
    int           res = 0;
    Dwarf_Cie    *cie_data = 0;
    Dwarf_Signed  cie_count = 0;
    Dwarf_Fde    *fde_data = 0;
    Dwarf_Signed  fde_count = 0;

    t = &vals[u];
    dwarf_set_frame_same_value(dbg,t->same_val);
    dwarf_set_frame_undefined_value(dbg,t->undefined_val);
    dwarf_set_frame_rule_table_size(dbg,t->tabsize);
    dwarf_set_frame_rule_initial_value(dbg,t->initial_val);
    dwarf_set_frame_cfa_value(dbg,t->cfa_val);

    res = dwarf_get_fde_list (dbg, &cie_data, &cie_count,
        &fde_data,&fde_count,error);
    if (res == DW_DLV_NO_ENTRY) {
        res = dwarf_get_fde_list_eh(dbg, &cie_data, &cie_count, 
            &fde_data,&fde_count,error);
    }

    if (res == DW_DLV_OK) {
         dwarf_dealloc_fde_cie_list(dbg, cie_data,cie_count,
             fde_data,fde_count);
         printf("FAIL:  %u should have gotten error,"
             " did not\n",u);
             ++failcount;
         return;
    } else if (res == DW_DLV_NO_ENTRY) {
         printf("FAIL: %u should have gotten error, not NO ENTRY\n",
             u);
         ++failcount;
         return;
    } 
    { /* DW_DLV_ERROR */
         int errnum = dwarf_errno(*error);
         if (errnum == DW_DLE_DEBUGFRAME_ERROR) {
             printf("PASS: %u errormsg %s\n",u,
                 dwarf_errmsg(*error));
             dwarf_dealloc_error(dbg,*error);
             *error = 0;
             return;
         } else {
             printf("FAIL: %u wrong errormsg %s\n",
                 u,
                 dwarf_errmsg(*error));
             ++failcount;
         }
         dwarf_dealloc_error(dbg,*error);
         *error = 0;
    }
    return;
}
static void
testseta(Dwarf_Debug dbg, Dwarf_Error *error)
{
    unsigned int count =
        sizeof(vals)/sizeof(vals[0]);
    unsigned int u = 0;
    for ( ; u < count ; ++u) {
        testn(u,dbg,error);
    }
}

/*  For the test to work properly on macOS
    we need to allow finding dSYM.
    So we need  a real buffer */
char dw_true_path_buffer[BUFSIZ];
unsigned int dw_true_path_bufferlen = BUFSIZ;

int
main(int argc, char **argv)
{
    Dwarf_Error error;
    Dwarf_Handler errhand = 0;
    Dwarf_Ptr errarg = 0;
    int i = 1;

    if (i >= argc) {
        printf("test_setframe not given file to open\n");
        printf("test_setframe exits\n");
        return 1;
    }
    if (!strcmp(argv[i],"--suppress-de-alloc-tree")) {
        /*  The test code does not expect or allow this.
            So ignore it. */
        ++i;
    }
    if (i >= argc) {
        printf("test_setframe not given file to open.\n");
        printf("test_setframe exits.\n");
        return 1;
    }

    for ( ; i < argc; ++i) {
        const char *filepath = 0;
        const char *base= 0;
        int res2 = 0;
        int res = DW_DLV_ERROR;
        Dwarf_Debug dbg = 0;

        dw_true_path_buffer[0] = 0;
        filepath = argv[i];
        base = basename(filepath);
        res = dwarf_init_path(filepath,
            dw_true_path_buffer,
            dw_true_path_bufferlen,
            DW_GROUPNUMBER_ANY,errhand,errarg,&dbg,
            &error);
        if (res == DW_DLV_ERROR) {
            printf("Init of %s FAILED\n",
                dwarf_errmsg(error));
            ++failcount;
            continue;
        } else if (res == DW_DLV_NO_ENTRY) {
            printf("Init of %s No Entry\n",base);
            continue;
        }
        printf("Opened objectfile %s\n",base);

        testseta(dbg,&error);

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
