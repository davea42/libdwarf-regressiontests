These examples are not meant to be compiled,
this will not compile as presented here.
As trivial examples of libdwarf use these are
hereby placed in the Public Domain.

#include "dwarf.h"
#include "libdwarf.h"

/*  This is what the ossfuzz test cases do, regardless
    which libdwarf init function is called. 
    This use is formally correct (in a sense of being
    legal C calls) but useless in practice. */
int alpha(const char *filename)
{   /*  NOT USEFUL. DO NOT DO THIS. */
    Dwarf_Debug dbg = 0;

    dwarf_init_path(filename, 0, 0,
        DW_GROUPNUMBER_ANY, 0, 0, &dbg, 0);
    dwarf_finish(dbg);
    return 0;
}


/*  An application coder of a real program would do
    the following instead.
    The author of a toy program might use the errhand and
    errarg arguments, but lets ignore that case.  
    The return values */
int zed(const char *filename)
{   /* PROPER USAGE. */
    Dwarf_Error err = 0;
    Dwarf_Debug dbg = 0;
    int res = 0;

    res = dwarf_init_path(filename, 0, 0,
        DW_GROUPNUMBER_ANY, 0, 0, &dbg, &err);
    if (res == DW_DLV_ERROR) {
        /* Take some error action */
        printf("FAIL. error is %s, take some action.\n",
            dwarf_errmsg(err));
        return DW_DLV_ERROR;
    }
    if (res == DW_DLV_NO_ENTRY) {
        printf("File %s does not exist\n");
        return DW_DLV_NO_ENTRY;
    }
    /*  Else res is DW_DLV_OK */
    /*  Maybe do something with the dbg? */
    dwarf_finish(dbg);
    return DW_DLV_OK;
}

