/* This written by DavidA based on a sketch by Pedro Navarro. 
   May 25, 2018 */
#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <elf.h>
#include <dwarf.h>
#include <libdwarf.h>
#include <stddef.h>
#include <stdlib.h>


int main()
{
    Dwarf_Arange *arange = 0;
    Dwarf_Signed arange_count = 0;
    Dwarf_Error error = DW_DLE_NE;
    Dwarf_Global *globs = 0;
    Dwarf_Debug dbg = 0;
    int fd = 0;
    char *name = "./compressed_aranges_test"; 
    int res = 0;
    
    fd = open(name, O_RDONLY);
    if (fd < 2) {
        printf("Failed open %s\n",name);
        exit(1);
    }
    res = dwarf_init(fd,0,0,0,&dbg,&error);
    if (res == DW_DLV_OK) {
       printf("dwarf_init_b ok\n");
    } else {
       printf("dwarf_init_b FAIL \n");
       exit(1);
    }
    if (dwarf_get_globals(dbg, &globs, &arange_count, &error) == DW_DLV_OK) {
        printf("globals!\n");
    } else {
        printf("FAIL in dwarf_get_globals: %llu %s\n", dwarf_errno(error), dwarf_errmsg(error));
       exit(1);
    }
    if (dwarf_get_aranges(dbg, &arange, &arange_count, &error) == DW_DLV_OK) {
        printf("ok!\n");
    } else {
        printf("FAIL in dwarf_get_aranges: %llu %s\n", dwarf_errno(error), dwarf_errmsg(error));
       exit(1);
    }
    res = dwarf_finish(dbg);
    if (res == DW_DLV_OK) {
       printf("done ok\n");
    } else {
       printf("finish FAIL \n");
       exit(1);
    }
}
