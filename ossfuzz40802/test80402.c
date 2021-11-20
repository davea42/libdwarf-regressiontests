/* This testcase is adapted from an oss-fuzz testcase, whose
copyright follows.
Copyright 2021 Google LLC
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
      http://www.apache.org/licenses/LICENSE-2.0
Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
either express or implied .
See the License for the specific language governing permissions and
limitations under the License.
*/

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <unistd.h>
#include "dwarf.h"
#include "libdwarf.h"

/*  This is what the ossfuzz test cases do, regardless
    which libdwarf init function is called. 
    This use is formally correct (in a sense of being
    legal C calls) but useless in practice. */
int alpha(const char *filename)
{
    Dwarf_Debug dbg = 0;
    dwarf_init_path(filename, 0, 0,
        DW_GROUPNUMBER_ANY, 0, 0, &dbg, 0);
    dwarf_finish(dbg);
    return 0;
}


/*  An application coder of a real program would do
    the following instead.
    The author of a toy program might use the errhand and
    errarg arguments, but lets ignore that case.  */
int zed(const char *filename)
{
    Dwarf_Error err = 0;
    Dwarf_Debug dbg = 0;
    int res = 0;
    res = dwarf_init_path(filename, 0, 0,
        DW_GROUPNUMBER_ANY, 0, 0, &dbg, &err);
    if (res == DW_DLV_ERROR) {
        /* Take some error action */
        printf("FAIL. error is %s, take some action.\n",
            dwarf_errmsg(err));
        exit(1);
    }
    if (res == DW_DLV_NO_ENTRY) {
        printf("File %s does not exist\n");
        exit(0);
    }
    /*  Else res is DW_DLV_OK */
    /*  Maybe do something with the dbg? */
    dwarf_finish(dbg);
    exit(0);
}

