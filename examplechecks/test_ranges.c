/*  Copyright (C) 2024 David Anderson
    test_ranges.c contains what user code might look like.
    The code in this file is PUBLIC DOMAIN
    and may be copied, used, and altered without any
    restrictions.
*/

#include <stdio.h> /* for printf */
#include <stdlib.h> /* for free() */
#include <string.h> /* for memcmp() */
#include "dwarf.h"
#include "libdwarf.h"
#include "checkexamples.h"

#define TRUE  1
#define FALSE 0

static void
loop_on_CUs(Dwarf_Debug dbg,int maxcount)
{
    int count = 0;
    Dwarf_Unsigned abbrev_offset = 0;
    Dwarf_Half     address_size = 0;
    Dwarf_Half     version_stamp = 0;
    Dwarf_Half     offset_size = 0;
    Dwarf_Half     extension_size = 0;
    Dwarf_Sig8     signature;
    Dwarf_Unsigned typeoffset = 0;
    Dwarf_Unsigned next_cu_header = 0;
    Dwarf_Half     header_cu_type = 0;
    Dwarf_Bool     is_info = TRUE;
    int            res = 0;
    Dwarf_Error    error = 0;

    for ( ; count < maxcount; ++count) {
        Dwarf_Die cu_die = 0;
        Dwarf_Unsigned cu_header_length = 0;

        if (count > maxcount) {
            printf("Stopping on count");
            return;
        }
        memset(&signature,0, sizeof(signature));
        printf("Open CU %d\n",count);
        res = dwarf_next_cu_header_e(dbg,is_info,
            &cu_die,
            &cu_header_length,
            &version_stamp, &abbrev_offset,
            &address_size, &offset_size,
            &extension_size,&signature,
            &typeoffset, &next_cu_header,
            &header_cu_type,&error);
        if (res == DW_DLV_ERROR) {
            printf("FAIL opening CU %d\n",count);
            printf("error %s\n",dwarf_errmsg(error));
            return;
        }
        if (res == DW_DLV_NO_ENTRY) {
            printf("End of CUs\n");
            /*  No more CUs to read! Never found
                what we were looking for in either
                .debug_info or .debug_types. */
            return;
        }
        /*  Calling code in doc/checkexamples.c
            which prints something of interest */
        res = examplev(dbg,0,cu_die,&error);
        if (res == DW_DLV_ERROR) {
            printf("FAIL examplev CU %d\n",count);
            printf("error %s\n",dwarf_errmsg(error));
            dwarf_dealloc_die(cu_die);
            return;
        }
        if (res == DW_DLV_NO_ENTRY) {
            printf("SKIP CU %d\n",count);
            count = count + maxcount;
        }
        dwarf_dealloc_die(cu_die);
    }
}
int
main(int argc, char **argv) {
    int           res = 0;
    Dwarf_Handler errhand = 0;
    Dwarf_Ptr     errarg = 0;
    Dwarf_Error   error = 0;
    Dwarf_Debug   dbg = 0;
    int           maxcucount = 1000;
    char         *filename = 0;
    int           groupnumber = DW_GROUPNUMBER_ANY;
    int           i = 0;
    static char   truebuffer[500];
    static int    truebufferlen = sizeof(truebuffer);
    int           universalbinary = 0;

    for (i = 1; i< argc; ++i)  {
        if (!strcmp(argv[i],"--suppress-de-alloc-tree")) {
            dwarf_set_de_alloc_flag(FALSE);
            continue;
        }
        if (!strncmp(argv[i],"--format-universalnumber=",25)) {
            if (!argv[i][25]) {
                printf("Empty universal number for %s\n",argv[i]);
                exit(EXIT_FAILURE);
            }
            universalbinary = atoi(&argv[i][25]);
            continue;
        }
        if (!strncmp(argv[i],"--maxcucount=",13)) {
            if (!argv[i][13]) {
                printf("Empty maxcucounttestobj for %s\n",argv[i]);
                exit(EXIT_FAILURE);
            }
            maxcucount = atoi(&argv[i][13]);
            continue;
        }
        if (!strncmp(argv[i],"--testobj=",10)) {
            if (!argv[i][10]) {
                printf("Empty testobj for %s\n",argv[i]);
                exit(EXIT_FAILURE);
            }
            filename = &argv[i][10];
            continue;
        }
        if (argv[i][0] == '-') {
            /* ignore other options for now */
            continue;
        }
        break;
    }
    if (!filename) {
        printf("No test object name provided\n");
        exit(EXIT_FAILURE);
    }

    res = dwarf_init_path_a(filename,truebuffer,
        truebufferlen,groupnumber, universalbinary,
        errhand, errarg,&dbg, &error);
    if (res == DW_DLV_ERROR) {
        printf(" Fail init %s error %s\n",
            filename,dwarf_errmsg(error));
        dwarf_dealloc_error(dbg,error);
        exit(EXIT_FAILURE);
    }
    if (res == DW_DLV_NO_ENTRY) {
        printf("nothing we can do for %s \n",filename);
        exit(EXIT_FAILURE);
    }
    loop_on_CUs(dbg,maxcucount);
    /* Call libdwarf functions here */
    dwarf_finish(dbg);
}
