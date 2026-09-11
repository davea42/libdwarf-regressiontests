/*  This test source is hereby PUBLIC DOMAIN and may be
    used by anyone in any way. */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include "dwarf.h"
#include "libdwarf.h"
int main(int argc, char **argv)
{

    Dwarf_Debug dbg = 0;
    Dwarf_Error err = 0;
    char *path = 0;
    int i = 1;

    if (argc < 3) {
        printf("ERROR: path name of test object is"
            " required\n");
        return 1;
    }
    for (; i < argc;++i) {
        char *p = argv[i];
        if ( p[0] == '-') {
            continue;
        }
        if (!path) {
            path = p;
            break;
        }
        break;
    }
    int res = dwarf_init_path(path, 0, 0, DW_GROUPNUMBER_ANY,
        0, 0, &dbg, &err);
    if (res == DW_DLV_ERROR)  {
        printf("Error compress64: %s\n",dwarf_errmsg(err));
        dwarf_dealloc_error(dbg, err);
    }
    if (res == DW_DLV_OK) {
        dwarf_finish(dbg);
    }
    return 0;
}
