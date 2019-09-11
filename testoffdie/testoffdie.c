/*  Based, vaguely, on a problem Steve Kaufmann
    noticed in the September 9,2019 libdwarf.
    An application crash in libdwarf.

    Copyright 2019 David Anderson.
    This is hereby placed into the public domain.
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "dwarf.h"
#include "libdwarf.h"

/*  We will use ../irixn32/dwarfdump
    as the object file to read.

global die-in-sect 0x000069d4, cu-in-sect 0x00005f96, die-in-cu 0x00000a49, cu-header-in-sect 0x00005f8b 'print_die_and_children'
*/

static void
printresval(const char *msg,int res,int line)
{
    const char *rn = (res==DW_DLV_OK)?"DW_DLV_OK":
        (res==DW_DLV_ERROR)?"DW_DLV_ERROR":
        (res==DW_DLV_NO_ENTRY)?"DW_DLV_NO_ENTRY":
        "unknown";
    printf("Res val %s: %d %s  line %d\n",msg,res,rn,line);
}

int main()
{
    const char *filename = "../irixn32/dwarfdump";
    int      res = 0;
    char     true_path[200];
    unsigned true_path_bufferlen = sizeof(true_path);
    Dwarf_Error error =0;
    Dwarf_Debug dbg = 0;
    Dwarf_Handler errhand = 0;
    Dwarf_Ptr errarg = 0;
    Dwarf_Unsigned dieoff = 0x000069d4;
    Dwarf_Die funcdie = 0;
    Dwarf_Die childdie = 0;
    char  *diename = 0;
    Dwarf_Half dietag = 0;
    const char *tagname = 0;
    Dwarf_Unsigned offarg = 0;



    res = dwarf_init_path(filename,
        true_path, true_path_bufferlen,
        DW_DLC_READ, DW_GROUPNUMBER_ANY,
        errhand,errarg,
        &dbg,0,0,0,&error);
    printresval("init",res,__LINE__);
    if (res != DW_DLV_OK) {
        printf("FAIL bad status\n");
        exit(1);
    }
    {
        Dwarf_Global *glob = 0;
        Dwarf_Signed globcount = 0;

        res = dwarf_get_globals(dbg,&glob,&globcount,&error);
        printresval("get globals",res,__LINE__);
        if (res != DW_DLV_OK) {
            printf("FAIL bad status\n");
            exit(1);
        }
        dwarf_globals_dealloc(dbg,glob,globcount);
    }
    res = dwarf_offdie(dbg,dieoff,&funcdie,&error);
    printresval("offdie",res,__LINE__);
    if (res != DW_DLV_OK) {
        printf("FAIL bad status\n");
        exit(1);
    }
    res = dwarf_diename(funcdie,&diename,&error);
    printresval("diename",res,__LINE__);
    if (res != DW_DLV_OK) {
        printf("FAIL bad status\n");
        exit(1);
    }
    printf("Function name: %s\n",diename);

    res = dwarf_child(funcdie,&childdie,&error);
    printresval("child",res,__LINE__);
    if (res != DW_DLV_OK) {
        printf("FAIL bad status\n");
        exit(1);
    }

    for(;;) {
        Dwarf_Die diesib = 0;

        res = dwarf_tag(childdie,&dietag,&error);
        printresval("dwarf_tag",res,__LINE__);
        if (res != DW_DLV_OK) {
            printf("FAIL bad status\n");
            exit(1);
        }
        res = dwarf_get_TAG_name(dietag,&tagname);
        printresval("get tag name",res,__LINE__);
        if (res != DW_DLV_OK) {
            printf("FAIL bad status\n");
            exit(1);
        }
        printf("tag %d %s\n",dietag,tagname);
        if (dietag == DW_TAG_formal_parameter) {
            res = dwarf_dieoffset(childdie,&offarg,&error);
            printresval("get arg die offset",res,__LINE__);
            if (res != DW_DLV_OK) {
                printf("FAIL bad status\n");
                exit(1);
            }
            printf("die offset of formal: 0x%lu\n",
                (unsigned long)offarg);
        }
        res = dwarf_siblingof(dbg,childdie,&diesib,&error);
        printresval("child sibling",res,__LINE__);
        if (res == DW_DLV_NO_ENTRY) {
            break;
        }
        if (res != DW_DLV_OK) {
            printf("FAIL bad status\n");
            exit(1);
        }
        childdie = diesib;
    }

    res = dwarf_finish(dbg,&error);
    printresval("finish",res,__LINE__);
    return 0;
}
