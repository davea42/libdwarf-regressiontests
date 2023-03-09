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
#include <fcntl.h> /* open() O_RDONLY */
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <unistd.h>

#define O_BINARY 0 /* So it does nothing in Linux/Unix */

/*
 * Libdwarf library callers can only use these headers.
 */
#include "dwarf.h"
#include "libdwarf.h"

/*
 * A fuzzer that simulates a small part of the simplereader.c example.
 * This fuzzer targets dwarf_init_b.
 */
int main(int argc, char **argv)
{
  char *filename = 0;
  Dwarf_Debug dbg = 0;
  int res = DW_DLV_ERROR;
  Dwarf_Handler errhand = 0;
  Dwarf_Ptr errarg = 0;
  int i = 0;
  Dwarf_Error error = 0; /* davea fixed original */
  int fd = -1;

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
  fd = open(filename, O_RDONLY | O_BINARY);
  if (fd < 0) {
    exit(EXIT_FAILURE);
  }

  res = dwarf_init_b(fd, DW_GROUPNUMBER_ANY, errhand, errarg, &dbg, &error);

  if (res != DW_DLV_OK) {
    if (res == DW_DLV_ERROR) {
        dwarf_dealloc_error(dbg, error);
        error = 0;
    }
  } else {
    Dwarf_Bool dw_which_section = 0;
    Dwarf_Gnu_Index_Head dw_head;
    Dwarf_Unsigned dw_index_block_count;

    res = dwarf_get_gnu_index_head(dbg, dw_which_section, &dw_head,
                                   &dw_index_block_count, &error);
    if (res == DW_DLV_NO_ENTRY) {
        printf("No gnu_index blocks\n");
    } else if (res == DW_DLV_ERROR) {
      printf("ERROR dwarf_get_gnu_index_head %s\n",
         dwarf_errmsg(error));
      dwarf_dealloc_error(dbg, error);
      error = 0;
    } else {
      Dwarf_Unsigned dw_block_length;
      Dwarf_Half dw_version;
      Dwarf_Unsigned dw_offset_into_debug_info;
      Dwarf_Unsigned dw_size_of_debug_info_area;
      Dwarf_Unsigned dw_count_of_index_entries;
      for (Dwarf_Unsigned block_number = 0; block_number < dw_index_block_count;
           block_number++) {
        res = dwarf_get_gnu_index_block(dw_head, block_number,
          &dw_block_length,
          &dw_version, &dw_offset_into_debug_info,
          &dw_size_of_debug_info_area,
          &dw_count_of_index_entries, &error);

        if (res == DW_DLV_NO_ENTRY) {
          printf("NO ENTRY block num %llu\n",block_number);
          continue;
        } else if (res == DW_DLV_ERROR) {
          printf("error dwarf_get_gnu_index_block() num %llu\n",
              block_number);
          printf("ERROR: %s\n",dwarf_errmsg(error));
          dwarf_dealloc_error(dbg,error);
          error = 0;
          break;
        }
        for (Dwarf_Unsigned entry_number = 0;
             entry_number < dw_count_of_index_entries; entry_number++) {
          Dwarf_Unsigned dw_offset_in_debug_info;
          const char *dw_name_string;
          unsigned char dw_flagbyte;
          unsigned char dw_staticorglobal;
          unsigned char dw_typeofentry;
          res = dwarf_get_gnu_index_block_entry(
              dw_head, block_number, entry_number, &dw_offset_in_debug_info,
              &dw_name_string, &dw_flagbyte, &dw_staticorglobal,
              &dw_typeofentry, &error);
          if (res == DW_DLV_NO_ENTRY) {
              printf("NO ENTRY entry num %llu\n",entry_number);
          }
          if (res == DW_DLV_ERROR) {
              printf("error entry num %llu\n",entry_number);
              printf("ERROR: %s\n",dwarf_errmsg(error));
              dwarf_dealloc_error(dbg,error);
              error = 0;
              break;
          }
        }
      }
      dwarf_gnu_index_dealloc(dw_head);
    }
  }
  dwarf_finish(dbg);
  close(fd);
  return 0;
}
