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

static void
insistok(int res,Dwarf_Error error,const char *msg)
{
    if (res == DW_DLV_OK) {
        return;
    }
    if (res == DW_DLV_ERROR) {
         printf("ERROR FAIL: %s\n",dwarf_errmsg(error));
         exit(1);
    }
    printf("NO_ENTRY FAIL: %s\n",dwarf_errmsg(error));
    exit(1);
}

static void
print_tag(Dwarf_Die d, Dwarf_Error *error)
{
    const char *tname = 0;
    Dwarf_Half tag = 0;
    dwarf_tag(d,&tag,error);
    dwarf_get_TAG_name(tag,&tname);
    printf("Tag %x  %s\n",tag,tname);
}

/*  This is only useful when we exactly know the content
    of the object file being read!  Assumes a specific case.
    We do not dealloc (clean up), libdwarf will do
    that for us. 
    The -gdwarf-3 output shows DW_AT_bit_offset
    for the member b as 0x1c which is absurd.
    The -gdwarf-5 output shows DW_AT_bit_offset
    for member b as 1 which makes sense.
*/
static int
try_bitoffset(Dwarf_Debug dbg)
{
    int res = 0;
    Dwarf_Bool is_info = TRUE;
    Dwarf_Unsigned cu_header_length = 0;
    Dwarf_Half     version_stamp = 0;
    Dwarf_Off      abbrev_offset = 0;
    Dwarf_Half     address_size = 0;
    Dwarf_Half     length_size = 0;
    Dwarf_Half     extension_size = 0;
    Dwarf_Sig8     signature;
    Dwarf_Unsigned typeoffset = 0;
    Dwarf_Unsigned next_cu_header_offset = 0;
    Dwarf_Half     header_cu_type = 0;
    Dwarf_Error    error = 0;
    Dwarf_Die      cu_die = 0;
    Dwarf_Die      struct_die = 0;
    Dwarf_Off      struct_die_offset = 0;
    Dwarf_Off      *memberoffsets = 0;
    Dwarf_Unsigned membercount = 0;
    Dwarf_Off      targetdieoffset = 0;
    Dwarf_Die      memberdie = 0;
    Dwarf_Unsigned bitoffset = 0;
    char *         diename = 0;
    Dwarf_Attribute attribute = 0;
    Dwarf_Half     attrnum = 0;
    char *         attrname = 0;
    Dwarf_Off      expected_offset = 0;
    Dwarf_Off      typeoffsetd = 0;
    Dwarf_Die      typedied = 0;
    char *         typedienamed = 0;

    res = dwarf_next_cu_header_d(dbg, is_info,
        &cu_header_length,&version_stamp,&abbrev_offset,
        &address_size,&length_size,&extension_size,
        &signature,&typeoffset,&next_cu_header_offset,
        &header_cu_type, &error);

    /*  Get the CU DIE */
    res = dwarf_siblingof_b(dbg,NULL,is_info,&cu_die,&error);
    insistok(res,error," dwarf_siblingof_b");
    res = dwarf_attr(cu_die,DW_AT_producer,&attribute,&error);
    insistok(res,error,"dwarf_attr");
    res =dwarf_formstring(attribute,&attrname,&error);
    insistok(res,error,"dwarf_formstring");
    printf("Producer:: %s\n",attrname);

    
    /*  Get the DW_TAG_structure_type */
    res = dwarf_child(cu_die,&struct_die,&error);
    insistok(res,error," dwarf_child");
    print_tag(struct_die,&error);

    res = dwarf_dieoffset(struct_die,&struct_die_offset,&error);
    insistok(res,error," dwarf_dieoffset");
    printf("struct die offset 0x%lx\n",(unsigned long)struct_die_offset);
    res = dwarf_offset_list(dbg,struct_die_offset,
          is_info,
          &memberoffsets,&membercount,&error);
    insistok(res,error," dwarf_offset_list");

    targetdieoffset = memberoffsets[1];
    printf("target member offset 0x%lx\n",(unsigned long)targetdieoffset);

    res = dwarf_offdie_b(dbg,targetdieoffset,is_info,
         &memberdie,&error);
    insistok(res,error," dwarf_offdie_b");

    print_tag(memberdie,&error);
    res = dwarf_diename(memberdie,&diename,&error);
    insistok(res,error," dwarf_diename");

    res = dwarf_bitoffset(memberdie,&attrnum,&bitoffset,&error);
    insistok(res,error," dwarf_bitoffset");
    printf("Member name %s bitoffset 0x%lx\n",
        diename,(unsigned long)bitoffset);
    if (attrnum == DW_AT_bit_offset) {
        /*  Offset of high bit of value
            from the high-bit of containing type */
        expected_offset = 0x1c;
    } else {
        /*  attrnum DW_AT_data_bit_offset. Offset from beginning
            of the containing value to the beginning of
            the value. */
        expected_offset = 1;
    }
    if (bitoffset != expected_offset) {
        printf("FAIL expected bit offset 0x%lx, not 0x%lx\n",
            (unsigned long)expected_offset,
            (unsigned long)bitoffset);
        return 1;
    }

    res = dwarf_dietype_offset(memberdie,&typeoffsetd,&error);
    insistok(res,error," dwarf_dietype_offset");
    res = dwarf_offdie_b(dbg,typeoffsetd,is_info,
         &typedied,&error);
    insistok(res,error," dwarf_offdie_b");
    print_tag(typedied,&error);
    res = dwarf_diename(typedied,&typedienamed,&error);
    insistok(res,error," dwarf_diename");
    printf("type die diename  %s\n",typedienamed);

    return 0; 
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
        printf("Opening file %s\n","<name suppressed for full"
            " path compatiblity\n");
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
