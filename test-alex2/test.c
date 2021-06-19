#include <stdlib.h>
#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <stdlib.h>
#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include "dwarf.h"
#include "libdwarf.h"


void print_type_name(Dwarf_Debug dbg, 
  Dwarf_Bool is_info, Dwarf_Off offset) {
  Dwarf_Error err = 0;
  Dwarf_Die new_die = 0;
  Dwarf_Bool res = 0;
  Dwarf_Attribute attr = 0;
  Dwarf_Half form = 0;
  Dwarf_Half version = 2;
  Dwarf_Half offset_size = 4;

  if (dwarf_offdie_b(dbg, offset, is_info, &new_die, &err) !=
    DW_DLV_OK) {
    printf("Failed\n");
    exit(1);
  }
  if (dwarf_attr(new_die, DW_AT_name, &attr, &err) == DW_DLV_OK) {
    res = dwarf_whatform(attr,&form, &err);
    if(res != DW_DLV_OK) {
       printf("Oops, no AT_name\n");
    }
    enum Dwarf_Form_Class cl = dwarf_get_form_class(version,DW_AT_name,
        offset_size, form); 
    if(cl != DW_FORM_CLASS_STRING) {
       printf("Oops, not right class\n");
    }
    printf("Found DW_FORM_CLASS_STRING\n");
  } else {
    printf("0x%llx die has NO DW_AT_name\n", offset);
  }
}

int main() {
  int fd;
  Dwarf_Debug dbg;
  Dwarf_Error err;
  Dwarf_Die new_die;
  Dwarf_Unsigned next_cu_hdr;
  Dwarf_Unsigned cu_hdr_len;
  Dwarf_Half version_stamp, address_size;
  Dwarf_Off abbrev_offset;
  int c_res;
  Dwarf_Error dwarf_err;
  Dwarf_Bool is_info = 1;
  
  fd = open("orig.a.out", O_RDONLY);
  if (dwarf_init_b(fd, DW_DLC_READ,
    DW_GROUPNUMBER_ANY,NULL, NULL, &dbg, &err) != DW_DLV_OK) {
    printf("Error\n");
    return 1;
  }
  print_type_name(dbg,is_info,0x72); 
  print_type_name(dbg,is_info,0xb5);
  print_type_name(dbg,is_info,0x14b);
  print_type_name(dbg,is_info,0x1b1);
  print_type_name(dbg,is_info,0x219);


  return 0;
}
