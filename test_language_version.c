/*  Copyright (c) 2025  David Anderson
    This code is hereby placed into the public domain.
*/
/* Test code to verify the correct functioning of the
   dwarf_language_version_string() function.
   In libdwarf since version 0.12.0

*/

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#if 0
#include <fcntl.h>
#include <sys/types.h> /* For open */
#include <sys/stat.h>  /* For open */
#include <fcntl.h>     /* For open */
#endif
#include <dwarf.h>
#include <libdwarf.h>

#define TRUE  1
#define FALSE 0

struct tv_s {
    int   return_v;
    unsigned int   compile_name;
    int   expected_low_bound;
    char *expected_version; /* meaning "YYMMPP" etc */
};

static struct tv_s t[] = {
    {DW_DLV_OK,DW_LNAME_Ada,1,"YYYY"},
    {DW_DLV_OK,DW_LNAME_BLISS,0,0},
    {DW_DLV_OK,DW_LNAME_C,0,"YYYYMM"},
    {DW_DLV_OK,DW_LNAME_Nim,0,"VVMMPP"},
    {DW_DLV_NO_ENTRY,500,0,0},
    {0,0,0,0}
};

int
main(int argc, char **argv)
{

    int k = 0;
    int res = 0;
    int fail = FALSE;

    for (  ; ; k++) {
        int low_bound = 0;
        const char *ver = 0;

        if (!t[k].compile_name &&
            !t[k].expected_low_bound &&
            !t[k].return_v &&
            !t[k].expected_version) {
            break;
        }
        res = dwarf_language_version_data(
            t[k].compile_name,&low_bound,&ver);
        if (res != t[k].return_v) {
            printf("k %d name 0x%x\n",k,t[k].compile_name);
            printf("FAIL expected ret %d, got %d\n",
                t[k].return_v,res);
            fail = TRUE;
            continue;
        } else {
            /* pass */
        }
        if (res == DW_DLV_NO_ENTRY) {
            /* pass, nothing else to check */
            continue;
        }
        if (low_bound != t[k].expected_low_bound) {
            printf("FAIL expected lower bound %d, got %d\n",
                t[k].expected_low_bound,low_bound);
            printf("k %d\n",k);
            fail = TRUE;
            continue;
        }
        if (t[k].expected_version) {
            if (ver) {
                if (strcmp(t[k].expected_version,ver)) {
                    printf("k %d\n",k);
                    printf("FAIL expected version %s, got %s\n",
                        t[k].expected_version,ver);
                    fail = TRUE;
                    continue;
                } else {
                    /* pass */
                }
            } else {
                printf("k %d\n",k);
                printf("FAIL expected version %s, got NULL\n",
                    t[k].expected_version);
                fail = TRUE;
                continue;
            }
        }  else {
            if (ver) {
                printf("k %d\n",k);
                printf("FAIL expected version MULL, got %s\n",
                    ver);
                fail = TRUE;
                continue;
            } else {
                /* pass */
            }
        }
    }
    if (fail) {
        return 1;
    }
    printf("PASS\n");
    return 0;
}
