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

/*
 * Libdwarf library callers can only use these headers.
 */
#include "dwarf.h"
#include "libdwarf.h"

/*
 * Fuzzer function targeting dwarf_crc32
 */
int main(int argc, char **argv)
{
  char *filename = 0;
  Dwarf_Debug dbg = 0;
  int fuzz_fd = 0;
  Dwarf_Handler errhand = 0;
  Dwarf_Ptr errarg = 0;
  int i = 0;
  Dwarf_Error error;
#if 0
  off_t size_left = 0;
  off_t fsize = 0;
#endif
  unsigned char *crcbuf = 0;

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
#if 0
  fsize = size_left = 
#endif
  lseek(fuzz_fd, 0L, SEEK_END);
  if (fuzz_fd != -1) {
    dwarf_init_b(fuzz_fd, DW_GROUPNUMBER_ANY, errhand, errarg, &dbg, &error);
    dwarf_crc32(dbg, crcbuf, &error);
    dwarf_finish(dbg);
  }
  close(fuzz_fd);
  return 0;
}
