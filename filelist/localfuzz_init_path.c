
/* Copyright 2021 Google LLC
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
      http://www.apache.org/licenses/LICENSE-2.0
Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <unistd.h>

/*
 * Libdwarf library callers can only use these headers.
 */
#include "dwarf.h"
#include "libdwarf.h"

/*
 * A fuzzer that simulates a small part of the simplereader.c example.
 */
#define MACHO_PATH_LEN 2000
int main(int argc, char **argv)
{
    Dwarf_Ptr errarg = 0;
    Dwarf_Handler errhand = 0;
    Dwarf_Debug dbg = 0;
    Dwarf_Error *errp = NULL;
    char macho_real_path[2000];
    const char *filename = "<fake>";
    int i = 1;
    int res = 0;

    for ( ; i < 2; ++i) {
        const char *v = 0;

        v = argv[i];
        if (!strcmp(v,"--suppress-de-alloc-tree")) {
            /* Skip this */
            continue;
        }
        filename = v;
        break;
    }
    filename = argv[1];
    res = dwarf_init_path(filename, macho_real_path, MACHO_PATH_LEN,
                  DW_GROUPNUMBER_ANY, errhand, errarg, &dbg, errp);
    dwarf_finish(dbg);
    if (res == DW_DLV_OK) {
        printf("localfuzz_init_path returns DW_DLV_OK\n");
    } else if (res == DW_DLV_NO_ENTRY) {
        printf("localfuzz_init_path returns DW_DLV_NO_ENTRY\n");
    } else if (res == DW_DLV_ERROR) {
        printf("localfuzz_init_path returns DW_DLV_ERROR\n");
    } else {
        printf("localfuzz_init_path returns impossible %d\n",
            res);
    }
    return 0;
}
