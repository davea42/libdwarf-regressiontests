#include <stdio.h>
#include "dwarf.h"
#include "libdwarf.h"
int main()
{
    Dwarf_Debug dbg = 0;
    int result = 0;

    printf("test\n");
    result = dwarf_init_path("folly",0,0,0,0,0,&dbg,0);
    printf(" dwarf_init_path returned %d\n",result);
    if (result == DW_DLV_OK) {
        dwarf_finish(dbg);
    } 
    printf("Done\n");
}
