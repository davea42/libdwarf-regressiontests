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
printresval(const char *prefix,const char *msg,int res,int line)
{
#if 0
    if (res == DW_DLV_OK) {
        return;
    }
#endif
    const char *rn = (res==DW_DLV_OK)?"DW_DLV_OK":
        (res==DW_DLV_ERROR)?"DW_DLV_ERROR":
        (res==DW_DLV_NO_ENTRY)?"DW_DLV_NO_ENTRY":
        "unknown";
    printf("%sRes val %s: %d %s  line %d\n",prefix,msg,res,rn,line);
}

int main(int argc, char **argv)
{
    const char *filename = 0;
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
    Dwarf_Bool is_info = 1;

    if (argc != 2) {
        printf("Requires one argument, path to test source.\n");
        exit(1);
    }
    filename = argv[1];

    res = dwarf_init_path(filename,
        true_path, true_path_bufferlen,
        DW_GROUPNUMBER_ANY,
        errhand,errarg,
        &dbg,&error);
    printresval("","init",res,__LINE__);
    if (res != DW_DLV_OK) {
        printf("FAIL bad status\n");
        exit(1);
    }
    {
        Dwarf_Global *glob = 0;
        Dwarf_Signed globcount = 0;

        res = dwarf_get_globals(dbg,&glob,&globcount,&error);
        printresval("","get globals",res,__LINE__);
        if (res == DW_DLV_ERROR) {
          dwarf_dealloc(dbg,error,DW_DLA_ERROR);
        }
        if (res != DW_DLV_OK) {
            printf("FAIL bad status\n");
            exit(1);
        }
        dwarf_globals_dealloc(dbg,glob,globcount);
    }
    res = dwarf_offdie_b(dbg,dieoff,is_info,&funcdie,&error);
    printresval("","offdie",res,__LINE__);
    if (res == DW_DLV_ERROR) {
        dwarf_dealloc(dbg,error,DW_DLA_ERROR);
        printf("FAIL bad status\n");
        exit(1);
    }
    res = dwarf_diename(funcdie,&diename,&error);
    printresval("","diename",res,__LINE__);
    if (res == DW_DLV_ERROR) {
        dwarf_dealloc(dbg,error,DW_DLA_ERROR);
    }
    if (res != DW_DLV_OK) {
        printf("FAIL bad status\n");
        exit(1);
    }
    printf("Function name: %s\n",diename);

    res = dwarf_child(funcdie,&childdie,&error);
    printresval("","child",res,__LINE__);
    if (res == DW_DLV_ERROR) {
        dwarf_dealloc(dbg,error,DW_DLA_ERROR);
    }
    if (res != DW_DLV_OK) {
        printf("FAIL bad status\n");
        exit(1);
    }

    for(;;) {
        Dwarf_Die diesib = 0;

        res = dwarf_tag(childdie,&dietag,&error);
        printresval("  ","dwarf_tag",res,__LINE__);
        if (res == DW_DLV_ERROR) {
            dwarf_dealloc(dbg,error,DW_DLA_ERROR);
        }
        if (res != DW_DLV_OK) {
            printf("FAIL bad status\n");
            exit(1);
        }
        res = dwarf_get_TAG_name(dietag,&tagname);
        if (res == DW_DLV_ERROR) {
            dwarf_dealloc(dbg,error,DW_DLA_ERROR);
        }
        printresval("  ","get tag name",res,__LINE__);
        if (res != DW_DLV_OK) {
            printf("FAIL bad status\n");
            exit(1);
        }
        printf("  tag %d %s\n",dietag,tagname);
        if (dietag == DW_TAG_formal_parameter) {
            Dwarf_Attribute attr = 0;
            Dwarf_Half aform = 0;
            const char *formname = 0;
            Dwarf_Off typeoffset = 0;
            Dwarf_Die typedie = 0;
             

            res = dwarf_dieoffset(childdie,&offarg,&error);
            printresval("  ","get arg die offset",res,__LINE__);
            if (res == DW_DLV_ERROR) {
               dwarf_dealloc(dbg,error,DW_DLA_ERROR);
            }
            if (res != DW_DLV_OK) {
                printf("FAIL bad status\n");
                exit(1);
            }
            printf("  die offset of formal: 0x%lu\n",
                (unsigned long)offarg);

            res = dwarf_attr(childdie,DW_AT_type,&attr,&error);
            if (res == DW_DLV_ERROR) {
                dwarf_dealloc(dbg,error,DW_DLA_ERROR);
            }
            printresval("  ","get child DW_AT_type",res,__LINE__);
            if (res != DW_DLV_OK) {
                printf("FAIL bad status\n");
                exit(1);
            }
            res = dwarf_whatform(attr,&aform,&error);
            printresval("  ","Form",res,__LINE__);
            if (res == DW_DLV_ERROR) {
                dwarf_dealloc(dbg,error,DW_DLA_ERROR);
            }
            if (res != DW_DLV_OK) {
                printf("FAIL bad status\n");
                exit(1);
            }
            res =   dwarf_get_FORM_name(aform,&formname);
            printresval("  ","Formname",res,__LINE__);
            printf("  Form %d %s\n",aform,formname);
            res = dwarf_global_formref(attr,&typeoffset,&error);
            printresval("  ","global formref",res,__LINE__);
            if (res == DW_DLV_ERROR) {
                dwarf_dealloc(dbg,error,DW_DLA_ERROR);
            }
            if (res != DW_DLV_OK) {
                printf("FAIL bad status\n");
                exit(1);
            }
            printf("   Type die offset 0x%lu\n",
                (unsigned long)typeoffset);
            res = dwarf_offdie_b(dbg,typeoffset,is_info,
                &typedie,&error);
            printresval("   ","offdie for type die",res,__LINE__);
            if (res == DW_DLV_ERROR) {
                dwarf_dealloc(dbg,error,DW_DLA_ERROR);
            }
            if (res != DW_DLV_OK) {
                printf("FAIL bad status\n");
                exit(1);
            }
            res = dwarf_tag(typedie,&dietag,&error);
            printresval("   ","dwarf_tag of typedie",res,__LINE__);
            if (res == DW_DLV_ERROR) {
                dwarf_dealloc(dbg,error,DW_DLA_ERROR);
            }
            if (res != DW_DLV_OK) {
                printf("FAIL bad status\n");
                exit(1);
            }
            res = dwarf_get_TAG_name(dietag,&tagname);
            printresval("   ","get  tag name",res,__LINE__);
            if (res == DW_DLV_ERROR) {
                dwarf_dealloc(dbg,error,DW_DLA_ERROR);
            }
            if (res != DW_DLV_OK) {
                printf("FAIL bad status\n");
                exit(1);
            }
            printf("   type die %d %s\n",dietag,tagname);  
            res = dwarf_diename(typedie,&diename,&error);
            printresval("   ","type-diename",res,__LINE__);
            if (res == DW_DLV_ERROR) {
                dwarf_dealloc(dbg,error,DW_DLA_ERROR);
            }
            if (res == DW_DLV_ERROR) {
                printf("FAIL bad status\n");
                exit(1);
            }
            if (res == DW_DLV_OK) {
                printf("   type diename %s\n",diename);
            }
            dwarf_dealloc(dbg,typedie,DW_DLA_DIE);
            
        }
        printf("  Now do siblingof call line %d\n",__LINE__);
        res = dwarf_siblingof_b(dbg,childdie,is_info,&diesib,&error);
        printresval("  ","child sibling",res,__LINE__);
        if (res == DW_DLV_ERROR) {
            dwarf_dealloc(dbg,error,DW_DLA_ERROR);
        }
        if (res == DW_DLV_NO_ENTRY) {
            break;
        }
        if (res != DW_DLV_OK) {
            printf("FAIL bad status\n");
            exit(1);
        }
        dwarf_dealloc(dbg,childdie,DW_DLA_DIE);
        childdie = diesib;
    }
    res = dwarf_finish(dbg,&error);
    printresval("","finish",res,__LINE__);
    return 0;
}
