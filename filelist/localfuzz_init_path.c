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
 * A small part of the simplereader.c example.
 * Here intentionally badly written.
 */
int 
main(int argc, const char **argv)
{
  Dwarf_Ptr errarg = 0;
  Dwarf_Handler errhand = 0;
  Dwarf_Debug dbg = 0;
  Dwarf_Error *errp = NULL;
#define MACHO_PATH_LEN 2000
  char macho_real_path[2000];
  const char *filename = 0;

  if (argc < 2) {
      printf("FAIL, argument required, a pathname\n");
      exit(1);
  }
  filename = argv[1];
  dwarf_init_path(filename, macho_real_path, MACHO_PATH_LEN,
                  DW_GROUPNUMBER_ANY, errhand, errarg, &dbg, errp);
  dwarf_finish(dbg);
  return 0;
}
