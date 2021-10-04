#include "dwarf.h"
#include "libdwarf.h"
#include <stdlib.h>
#include <assert.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <stdio.h>
#include <string.h>
#include <errno.h>

#define FILENAME "./libmpich.so.1.0"
#define ADDR 0x5c183
#define REG 12

static  const char *
value_type_name(unsigned value_type)
{
    switch(value_type){
    case DW_EXPR_OFFSET: return "DW_EXPR_OFFSET";
    case DW_EXPR_VAL_OFFSET: return "DW_EXPR_VAL_OFFSET";
    case DW_EXPR_EXPRESSION: return "DW_EXPR_EXPRESSION";
    case DW_EXPR_VAL_EXPRESSION: return "DW_EXPR_VAL_EXPRESSION";
    }
    return "DW_EXPR unknown! ERROR!";
}


/**
 * With libdwarf-20090510 and latter this produces the output:
 *  Got reg value 0
 * With libdwarf-20090330 and earlier this produces the output:
 *  Got reg value 1036
 *
 * I believe the 1036 value is the correct one, as it leads to a
 * proper stack recipe for the function.
 **/
int main(int argc, char *argv[])
{
   Dwarf_Error err = 0;
   Dwarf_Debug dbg = 0;
   Dwarf_Cie *cie_data = 0;
   Dwarf_Signed cie_count = 0;
   Dwarf_Fde *fde_data, fde = 0;
   Dwarf_Signed fde_count = 0;
   Dwarf_Small value_type = 0;
   Dwarf_Signed offset_relevant=0; 
   Dwarf_Signed register_num = 0;
   Dwarf_Signed offset =0;
   Dwarf_Block block;
   Dwarf_Ptr block_ptr = 0;
   Dwarf_Addr row_pc = 0;
   Dwarf_Bool has_more_rows = 0;
   Dwarf_Addr subsequent_pc = 0;
   int result;
   int fd;

   memset(&block,0,sizeof(Dwarf_Block));
   fd = open("./libmpich.so.1.0", O_RDONLY);
   if (fd == -1) {
      perror("Could not open ./libmpich.so.1.0 for test");
      return -1;
   }
   result = dwarf_init_b(fd,
        DW_GROUPNUMBER_ANY,NULL, NULL, &dbg, &err);
   assert(result == DW_DLV_OK);

   result = dwarf_get_fde_list(dbg, &cie_data,
       &cie_count, &fde_data, &fde_count,
       &err);
   assert(result == DW_DLV_OK);

   result = dwarf_get_fde_at_pc(fde_data, ADDR, &fde, 
       NULL, NULL, &err);
   assert (result == DW_DLV_OK);
     
   result = dwarf_get_fde_info_for_reg3_b(fde, REG, 
       ADDR, &value_type, 
       &offset_relevant, &register_num,
       &offset,
       &block, &row_pc, 
       &has_more_rows,&subsequent_pc,&err);
   assert(result == DW_DLV_OK);
   printf("value type      %ld %s\n", (long int) value_type,
       value_type_name(value_type));
   printf("Register num    %ld\n", (long int) register_num);
   printf("offset relevant %ld\n", (long int) offset_relevant);
   printf("offset          %ld (0x%lx)\n", (long int) offset,
       (unsigned long int)offset);
   printf("bl ptr          %lu (0x%lx)\n", 
       (unsigned long int) block.bl_data,
       (unsigned long int) block.bl_data);
   printf("bl len          %lu (0x%lx)\n", 
       (unsigned long int) block.bl_len,
       (unsigned long int) block.bl_len);
   printf("row_pc          %ld (0x%lx)\n", (long int) row_pc,
       (unsigned long int)row_pc);
   assert(register_num == DW_FRAME_CFA_COL3);
   /* This just shows we really test something. */
   assert(DW_FRAME_CFA_COL3 != DW_FRAME_CFA_COL);
   return 0;
}
