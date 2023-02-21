/*
  Copyright 2023 David Anderson. All rights reserved.

  This program is placed in the PUBLIC DOMAIN so anyone
  can use it for any purpose without restriction.

*/

#include <config.h>

#include <string.h>
#include <stdio.h>
#include "dwarf.h"
#include "libdwarf.h"

#define DW_PR_DUx "llx" 
#define DW_PR_DUu "llu" 
#define ATTR_ARRAY_SIZE 10
#define TRUE 1
#define FALSE 0

int failcount = 0;

static const char *
basename(const char *path)
{
    const char *cp = path;
    int lastslash = -1;
    int i = 0;

    for ( ; *cp ; ++cp,++i) {
        if (*cp == '/') {
            lastslash = i;
        }
    }
    if (lastslash == -1) {
        return path;
    }
    if (!*cp && (lastslash+1) == i) {
        if (i >1) {
            return path+lastslash-1;
        }
        return path+lastslash;
    }
    return path+lastslash+1;
}

static int
print_code_data(Dwarf_Dnames_Head dn,
    Dwarf_Unsigned i,
    Dwarf_Unsigned abbrev_code,
    Dwarf_Half     abbrev_tag,
    Dwarf_Unsigned abb_count,
    Dwarf_Error   *error)
{
    int        res = 0;
    Dwarf_Half tag = 0;
    Dwarf_Unsigned index_of_abb = 0;
    Dwarf_Unsigned number_of_entries= 0;
    Dwarf_Unsigned j = 0;

    res = dwarf_dnames_abbrev_by_code(dn,abbrev_code,
        &tag,&index_of_abb,&number_of_entries);
    if (res != DW_DLV_OK) {
        ++failcount;
        printf("FAIL dwarf_dnames_abbrev_by_code for "
            "code %" DW_PR_DUu "\n",abbrev_code);
        return res;
    }
    printf("Abbrev code  %" DW_PR_DUu ,abbrev_code);
    printf("Abbrev tag   0x%x ",tag);
    printf("Abbrev pairs %" DW_PR_DUu ,number_of_entries);
    if (abb_count != number_of_entries) {
        ++failcount;
        printf("FAIL entry count expected was %" DW_PR_DUu "\n",
            abb_count);
        return DW_DLV_OK;
    }
    if (abbrev_tag != tag) {
        ++failcount;
        printf("FAIL tag expected was 0x%02x\n",
            tag);
    }
    for ( j;j < number_of_entries; ++j) {
        Dwarf_Unsigned idx_attr = 0;
        Dwarf_Unsigned idx_form = 0;
        const char    *aname = "<none>"; 
        const char    *fname = "<none>";


        res = dwarf_dnames_abbrev_form_by_index(dn,
           i,j,&idx_attr,&idx_form,error);
        if (res != DW_DLV_OK) {
           ++failcount;
           printf(" FAIL reading abb for %" DW_PR_DUu
               " %" DW_PR_DUu "\n",i,j);
           return res;
        }
        printf("[%3" DW_PR_DUu ",%3" DW_PR_DUu ,i,j);
        dwarf_get_IDX_name(idx_attr,&aname);
        printf(" 0x%02" DW_PR_DUx  " %s",idx_attr,aname);
        dwarf_get_FORM_name(idx_form,&fname);
        printf(" 0x%02" DW_PR_DUx  " %s\n",idx_form,fname);
    }
    return DW_DLV_OK;
}


static int
print_names_table(unsigned int indent,
    Dwarf_Debug dbg,
    Dwarf_Dnames_Head dn,
    Dwarf_Unsigned name_count,
    Dwarf_Unsigned bucket_count,
    Dwarf_Unsigned local_type_unit_count,
    Dwarf_Bool     has_single_cu_offset,
    Dwarf_Unsigned single_cu_offset,
    Dwarf_Error * error)
{
    Dwarf_Unsigned i = 1;
    int res                  = 0;
    Dwarf_Unsigned bucketnum = 0;
    Dwarf_Unsigned hashval   = 0;
    Dwarf_Unsigned offset_to_debug_str = 0;
    char * ptrtostr          = 0;
    Dwarf_Unsigned offset_in_entrypool = 0;
    Dwarf_Unsigned abbrev_code = 0;
    Dwarf_Half abbrev_tag    = 0;
    Dwarf_Unsigned array_size = ATTR_ARRAY_SIZE;
    static Dwarf_Half nt_idxattr_array[ATTR_ARRAY_SIZE];
    static Dwarf_Half nt_form_array[ATTR_ARRAY_SIZE];
    Dwarf_Unsigned attr_count = 0;

    memset(nt_idxattr_array,0,sizeof(Dwarf_Half) * ATTR_ARRAY_SIZE);
    memset(nt_form_array,0,sizeof(Dwarf_Half) * ATTR_ARRAY_SIZE);
    printf("[] ");
    for ( ; i <= name_count;++i) {
        res = dwarf_dnames_name(dn,i,
            &bucketnum, &hashval,
            &offset_to_debug_str,&ptrtostr,
            &offset_in_entrypool, &abbrev_code,
            &abbrev_tag,
            array_size, nt_idxattr_array,
            nt_form_array,
            &attr_count,error);
        if (res == DW_DLV_ERROR) {
            return res;
        }
        if (res == DW_DLV_NO_ENTRY) {
            printf("[%4" DW_PR_DUu "] ",(unsigned long long)i);
            printf("\nERROR: NO ENTRY on name index "
                "%" DW_PR_DUu " is impossible \n",i);
            printf("\n");
            continue;
        }
        res = print_code_data(dn,i,abbrev_code,abbrev_tag,
            attr_count,
            error);
        if (res != DW_DLV_OK) {
            return res;
        }
    }
    return DW_DLV_OK;
}

static int
print_dname_record(Dwarf_Debug dbg,
    Dwarf_Dnames_Head dn,
    Dwarf_Unsigned offset,
    Dwarf_Unsigned new_offset,
    Dwarf_Error *error)
{
    int res = 0;
    Dwarf_Unsigned comp_unit_count = 0;
    Dwarf_Unsigned local_type_unit_count = 0;
    Dwarf_Unsigned foreign_type_unit_count = 0;
    Dwarf_Unsigned bucket_count = 0;
    Dwarf_Unsigned name_count = 0;
    Dwarf_Unsigned abbrev_table_size = 0;
    Dwarf_Unsigned entry_pool_size = 0;
    Dwarf_Unsigned augmentation_string_size = 0;
    Dwarf_Unsigned section_size = 0;
    Dwarf_Half table_version = 0;
    Dwarf_Half offset_size = 0;
    char * augstring = 0;
    unsigned int indent = 0;
    Dwarf_Bool     has_single_cu_offset;
    Dwarf_Bool     has_single_tu_offset;
    Dwarf_Unsigned single_cu_offset = 0;
    Dwarf_Unsigned single_tu_offset = 0;

    res = dwarf_dnames_sizes(dn,&comp_unit_count,
        &local_type_unit_count,
        &foreign_type_unit_count,
        &bucket_count,
        &name_count,&abbrev_table_size,
        &entry_pool_size,&augmentation_string_size,
        &augstring,
        &section_size,&table_version,
        &offset_size,
        error);
    if (res != DW_DLV_OK) {
        return res;
    }
    res = print_names_table(indent+2,dbg,dn,name_count,
        bucket_count,
        local_type_unit_count,
        has_single_cu_offset,
        single_cu_offset,error);
    if (res == DW_DLV_ERROR) {
        return res;
    }
    return DW_DLV_OK;
}

int
print_debug_names(Dwarf_Debug dbg,Dwarf_Error *error)
{
    Dwarf_Dnames_Head dnhead = 0;
    Dwarf_Unsigned offset = 0;
    Dwarf_Unsigned new_offset = 0;
    int res = 0;

    if (!dbg) {
        printf("\nERROR: Cannot print .debug_names, "
            "no Dwarf_Debug passed in\n");
        return DW_DLV_NO_ENTRY;
    }

    /*  Only print anything if we know it has debug names
        present. And for now there is none. FIXME. */
    res = dwarf_dnames_header(dbg,offset,&dnhead,&new_offset,error);
    if (res == DW_DLV_NO_ENTRY) {
        return res;
    }
    while (res == DW_DLV_OK) {
        res = print_dname_record(dbg,dnhead,offset,new_offset,error);
        if (res != DW_DLV_OK) {
            dwarf_dealloc_dnames(dnhead);
            dnhead = 0;
            return res;
        }
        offset = new_offset;
        dwarf_dealloc_dnames(dnhead);
        dnhead = 0;
        res = dwarf_dnames_header(dbg,offset,&dnhead,
            &new_offset,error);
    }
    return res;
}

int
main(int argc, char ** argv)
{
    Dwarf_Error error;
    Dwarf_Handler errhand = 0;
    Dwarf_Ptr errarg = 0;
    int i = 1;
    int failcount = 0;

    if (i >= argc) {
        printf("test_sectionnames not given file to open\n");
        printf("test_sectionnames exits\n");
        return 1;
    }
    if (!strcmp(argv[i],"--suppress-de-alloc-tree")) {
        dwarf_set_de_alloc_flag(FALSE);
        ++i;
    }
    if (i >= argc) {
        printf("test_sectionnames not given file to open\n");
        printf("test_sectionnames exits\n");
        return 1;
    }
    for ( ; i < argc; ++i) {
        const char *filepath = 0;
        int res2 = 0;
        int res = DW_DLV_ERROR;
        Dwarf_Debug dbg = 0;
        const char *base = 0;

        filepath = argv[i];
        base = basename(filepath);
        res = dwarf_init_path(filepath,
            0,0,
            DW_GROUPNUMBER_ANY,errhand,errarg,&dbg,
            &error);
        if (res == DW_DLV_ERROR) {
            printf("Init of %s FAILED: %s\n",
                base,dwarf_errmsg(error));
            ++failcount;
            continue;
        } else if (res == DW_DLV_NO_ENTRY) {
            printf("Init of %s No Entry\n",base);
            continue;
        }
        printf("Opened objectfile %s\n",base);
        print_debug_names(dbg,&error);
        res2 = dwarf_finish(dbg);
        if (res2 == DW_DLV_ERROR) {
            printf("dwarf_finish of %s FAILED %s\n",
                base,
                dwarf_errmsg(error));
            ++failcount;
            continue;
        }
        if (res2 == DW_DLV_NO_ENTRY) {
            printf("dwarf_finish of %s DW_DLV_NO_ENTRY\n",
                base);
            ++failcount;
            continue;
        }
    }
    if (failcount) {
        return 1;
    }
    printf("PASS test_dnames_codes\n");
    return 0;




}
