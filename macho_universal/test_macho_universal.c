/*   This test code is hereby placed in the public domain. */

/*  Regression test for the Mach-O universal ("fat") binary header
    reader.

    _dwarf_object_detector_universal_head_fd() read the 64-bit arch
    table with sizeof(fa), the size of the pointer, rather than
    sizeof(*fa), the 32 bytes of struct fat_arch_64.  Only the first
    quarter of the table was filled, offset and size came back as the
    zeros calloc left, and no FAT_MAGIC_64 universal binary could be
    read at all.

    The two files written here describe the same inner object at the
    same offset with the same size, once with FAT_MAGIC and 32-bit
    entries and once with FAT_MAGIC_64 and 64-bit ones, so
    dwarf_init_path_a() has to answer the same way for both.  */

#include <config.h>
#include <stdio.h>  /* fopen fclose fwrite remove printf */
#if 0
#include <string.h> /* memset */
#endif
#include "dwarf.h"
#include "libdwarf.h"

#define FAT_MAGIC     0xcafebabe
#define FAT_MAGIC_64  0xcafebabf
#define MH_MAGIC_64   0xfeedfacf
#define PAYLOAD_OFF   4096
#define PAYLOAD_LEN   232

static int
open_it(const char *path, int *errnum,const char *ver)
{
    Dwarf_Debug dbg = 0;
    Dwarf_Error err = 0;
    char tp[2048];
    int res = 0;

    *errnum = 0;
    res = dwarf_init_path_a(path, tp, sizeof(tp), DW_GROUPNUMBER_ANY,
        0, 0, 0, &dbg, &err);
    if (res == DW_DLV_ERROR) {
        *errnum = dwarf_errno(err);
        printf("Dwarf init fails on %s: %s\n",
            ver,dwarf_errmsg(err));
        dwarf_dealloc_error(dbg, err);
    }
    if (res == DW_DLV_OK) {
        dwarf_finish(dbg);
    }
    return res;
}

int
main(int argc, char **argv)
{
    char *f32 = 0;
    char *f64 = 0;
    int res32 = 0;
    int res64 = 0;
    int err32 = 0;
    int err64 = 0;
    int failcount = 0;
    if (argc < 3) {
        printf("ERROR Argc %d less than 3  improper test"
            " absolute paths to the proof of concept "
            " binary objects should be present\n",argc);
        return 1;
    }
    f32 = argv[1];
    f64 = argv[2];

    res32 = open_it(f32, &err32,"macho-universal 32");
    res64 = open_it(f64, &err64,"macho-universal 64");

    if (res32 != res64 || err32 != err64) {
        printf("FAIL test_macho_universal: FAT_MAGIC gives res %d err %d "
            "but FAT_MAGIC_64 gives res %d err %d. "
            "The 64-bit arch table was misread.\n",
            res32, err32, res64, err64);
        ++failcount;
    }
    if (failcount) {
        return 1;
    }
    printf("PASS test_macho_universal\n");
    return 0;
}
