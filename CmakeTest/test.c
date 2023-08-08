#include <stdio.h>
#include "dwarf.h"
#include "libdwarf.h"
int main()
{
    Dwarf_Debug dbg = 0;
    int result = 0;
    const char *pathname = "folly";

    printf("test\n");
    /*  The following call has to fail  as the pathname
        is to a nonexistent file. */
    result = dwarf_init_path(pathname,0,0,0,0,0,&dbg,0);
    if (result == DW_DLV_OK) {
        printf("\ndwarf_init_path succeeded. Impossible"
            " as we expect \'%s\' to be absent or invalid.\n",
            pathname);
        dwarf_finish(dbg);
    } else if (result == DW_DLV_NO_ENTRY) {
        printf("\ndwarf_init_path returned"
            " DW_DLV_NO_ENTRY which is appropriate "
            "as the file named \'%s\' does not exist\n",
            pathname);
    }  else {
        printf("\ndwarf_init_path returned  DW_DLV_ERROR"
            " which means the file \'%s\' existsd but is not the right"
            " file type.\n",pathname);
    }
    printf("Done\n");
}
