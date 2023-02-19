/*  Copyright (c) 2023 David Anderson

    This test code is hereby placed in the PUBLIC DOMAIN
    for anyone to copy/alter/use in any way.

*/

#include <config.h>
#include <string.h> /* for strcmp */
#include <stdlib.h> /* for exit() */
#include <stdio.h> /* for printf() */
#include <dwarf.h>
#include <libdwarf.h>

static long checkcount = 0;

static void
check_valid(int res,
    const char *funname,
    const char *expectedname,
    int         value,
    const char *returnedname)
{
    ++checkcount;
    if (res != DW_DLV_OK) {
        printf("FAIL call %s res %d (%s %d %s)\n",
            funname,res,expectedname,value,returnedname);
        exit(EXIT_FAILURE);
    }
    if (strcmp(expectedname,returnedname)) {
        printf("FAIL call \"%s\"  expected \"%s\" "
            "for %d but got \"%s\"\n",
            funname,expectedname,value,returnedname);
        exit(EXIT_FAILURE);
    }
}
 
static void
run_tests(void) {
    int res = 0;
    const char *ret_name = 0;

#include "dwnames_all.h"
}

int main(void) {
    run_tests();
    printf("PASS dwnames_all, %ld checks\n",checkcount);
    return 0;
}
