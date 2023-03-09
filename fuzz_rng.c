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
#include <fcntl.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>
#include "dwarf.h"
#include "libdwarf.h"

int main(int argc, char **argv)
{
  char *filename = 0;
  Dwarf_Debug dbg = 0;
  int fuzz_fd = 0;
  Dwarf_Handler errhand = 0;
  Dwarf_Ptr errarg = 0;
  int i = 0;
  Dwarf_Error *errp = NULL;

  for (i = 1; i< argc; ++i)  {
      if (argv[i][0] == '-') {
           /* ignore options for now */
           continue;
      }
      break;
  }
  if (i >= argc) {
        printf("fuzz_die_cu_offset.c not given file to open\n");
        printf("fuzz_die_cu_offset.c exits\n");
        exit(EXIT_FAILURE);
  }
  filename = argv[i];

  fuzz_fd = open(filename, O_RDONLY);
  if (fuzz_fd != -1) {
    dwarf_init_b(fuzz_fd, DW_GROUPNUMBER_ANY, errhand, errarg, &dbg, errp);
    Dwarf_Unsigned count = 0;
    int res = 0;
    Dwarf_Unsigned i = 0;

    res = dwarf_load_rnglists(dbg, &count, errp);
    if (res == DW_DLV_OK) {
      for (i = 0; i < count; ++i) {
        Dwarf_Unsigned header_offset = 0;
        Dwarf_Small offset_size = 0;
        Dwarf_Small extension_size = 0;
        unsigned version = 0;
        Dwarf_Small address_size = 0;
        Dwarf_Small segment_selector_size = 0;
        Dwarf_Unsigned offset_entry_count = 0;
        Dwarf_Unsigned offset_of_offset_array = 0;
        Dwarf_Unsigned offset_of_first_rangeentry = 0;
        Dwarf_Unsigned offset_past_last_rangeentry = 0;

        res = dwarf_get_rnglist_context_basics(
            dbg, i, &header_offset, &offset_size, &extension_size, &version,
            &address_size, &segment_selector_size, &offset_entry_count,
            &offset_of_offset_array, &offset_of_first_rangeentry,
            &offset_past_last_rangeentry, errp);

        Dwarf_Unsigned e = 0;
        unsigned colmax = 4;
        unsigned col = 0;
        Dwarf_Unsigned global_offset_of_value = 0;

        for (; e < offset_entry_count; ++e) {
          Dwarf_Unsigned value = 0;
          int resc = 0;

          resc = dwarf_get_rnglist_offset_index_value(
              dbg, i, e, &value, &global_offset_of_value, errp);
          if (resc != DW_DLV_OK) {
            return resc;
          }
          col++;
          if (col == colmax) {
            col = 0;
          }
        }

        Dwarf_Unsigned curoffset = offset_of_first_rangeentry;
        Dwarf_Unsigned endoffset = offset_past_last_rangeentry;
        int rese = 0;
        Dwarf_Unsigned ct = 0;

        for (; curoffset < endoffset; ++ct) {
          unsigned entrylen = 0;
          unsigned code = 0;
          Dwarf_Unsigned v1 = 0;
          Dwarf_Unsigned v2 = 0;
          rese = dwarf_get_rnglist_rle(dbg, i, curoffset, endoffset, &entrylen,
                                       &code, &v1, &v2, errp);
          if (rese != DW_DLV_OK) {
            return rese;
          }
          curoffset += entrylen;
          if (curoffset > endoffset) {
            return DW_DLV_ERROR;
          }
        }
      }
    }
    dwarf_finish(dbg);
    close(fuzz_fd);
  }
  return 0;
}
