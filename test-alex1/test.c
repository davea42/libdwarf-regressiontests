#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include "dwarf.h"
#include "libdwarf.h"

/*#define WORKING 1 */

void print_type_name(Dwarf_Debug dbg, Dwarf_Off offset) {
  Dwarf_Error err;
  Dwarf_Die new_die;
  Dwarf_Bool res;

  if (dwarf_offdie(dbg, offset, &new_die, &err) != DW_DLV_OK) {
    printf("Failed\n");
  }
  if (dwarf_hasattr(new_die, DW_AT_name, &res, &err) == DW_DLV_OK && res) {
    printf("0x%llx die has DW_AT_name!\n", offset);
  } else {
    printf("0x%llx die has NO DW_AT_name\n", offset);
  }
}

int main() {
    int fd  = 0;
    Dwarf_Debug dbg  = 0;
    Dwarf_Error err  = 0;
    Dwarf_Die new_die  = 0;
    Dwarf_Unsigned cu_hdr_len = 0;
    Dwarf_Half version_stamp        = 0;
    Dwarf_Off abbrev_offset    = 0;
    Dwarf_Half address_size         = 0;
    Dwarf_Unsigned next_cu_header   = 0;
    int cu_number                   = 0;
    Dwarf_Bool is_info              = 1;
    int c_res;
  
  fd = open("orig.a.out", O_RDONLY);
  if (dwarf_init(fd, DW_DLC_READ, NULL, NULL, &dbg, &err) != DW_DLV_OK) {
    printf("Error\n");
    return 1;
  }
#if WORKING
  print_type_name(dbg,0x5e);
  print_type_name(dbg,0xb5);
  print_type_name(dbg,0x14b);
  print_type_name(dbg,0x1b1);
  print_type_name(dbg,0x219);
#else
  if (dwarf_offdie(dbg, 0x5e, &new_die, &err) != DW_DLV_OK) {
    printf("Failed\n");
  }
  c_res = dwarf_next_cu_header_d(dbg,is_info,&cu_hdr_len, 
    &version_stamp, &abbrev_offset,
       &address_size, 
       0,0,0,0,
       &next_cu_header, 
       0,
       &err);
  c_res = dwarf_next_cu_header_d(dbg,is_info, &cu_hdr_len,
       &version_stamp, &abbrev_offset,
       &address_size, 
       0,0,0,0,
       &next_cu_header, 
       0,
       &err);
  c_res = dwarf_next_cu_header_d(dbg,is_info, &cu_hdr_len,
       &version_stamp, &abbrev_offset,
       &address_size, 
       0,0,0,0,
       &next_cu_header, 
       0,
       &err);
  if (dwarf_offdie(dbg, 0x219, &new_die, &err) != DW_DLV_OK) {
    printf("Failed\n");
  }
  print_type_name(dbg,0x5e);
  print_type_name(dbg,0xb5);
  print_type_name(dbg,0x14b);
  print_type_name(dbg,0x1b1);
  print_type_name(dbg,0x219);
#endif
  return 0;
}

