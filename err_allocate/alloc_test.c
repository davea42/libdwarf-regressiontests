
#include <stdio.h>
#include "libdwarf.h"


int 
main(void)
{
    int res = 0;
    Dwarf_Debug dbg = 0;
    Dwarf_Unsigned offset = 0;
    Dwarf_Abbrev returned_abbrev = 0;
    Dwarf_Unsigned  length = 0;
    Dwarf_Unsigned  abbr_count = 0; 
    Dwarf_Error  error = 0;


    res = dwarf_get_abbrev(dbg,
        offset,
        &returned_abbrev,
        &length,
        &abbr_count, 
        &error);

    if (res == DW_DLV_OK) {
        printf("FAIL alloc_test got DW_DLV_NO_ENTRY which is crazy.\n");
        fflush(stdout);
        return 1;
    }
    if (res == DW_DLV_ERROR) {
        char * errmsg = 0;
        int  errnum = 0;
        printf("alloc_test got DW_DLV_ERROR which is to be expected.\n");
        errmsg = dwarf_errmsg(error);
        errnum = dwarf_errno(error);
        printf("Alloc test error string : %s\n",errmsg);
        if (errnum == DW_DLE_DBG_NULL) {
            dwarf_dealloc(dbg,error, DW_DLA_ERROR);
            fflush(stdout);
            return 0;
        }
        printf("FAIL alloc_test got wrong error code, "
            "expected DW_DLE_DBG_NULL\n");
        fflush(stdout);
        return 1;
 
    }
    printf("FAIL alloc_test got DW_DLV_NO_ENTRY which is crazy.\n");
    fflush(stdout);
    return 1;
}
