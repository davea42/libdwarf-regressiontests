/*  This test code is hereby placed in the public domain. 2026 */
/*  build_macho_universal.c builds the proof of concept object
    files: 
    test_macho_universal_32.poc
    test_macho_universal_64.poc
    These are input to test_macho_universal during
    regression testing.
    These are saved so there seems no good reason to regenerate them.
    See test_macho_universal.c which runs the actual test


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

#include <stdio.h>  /* fopen fclose fwrite remove printf */
#include <string.h> /* memset */
#if 0
#include "dwarf.h"
#include "libdwarf.h"
#endif

#define FAT_MAGIC     0xcafebabe
#define FAT_MAGIC_64  0xcafebabf
#define MH_MAGIC_64   0xfeedfacf
#define PAYLOAD_OFF   4096
#define PAYLOAD_LEN   232

static void
put_be32(unsigned char *p, unsigned long v)
{
    p[0] = (unsigned char)(v >> 24);
    p[1] = (unsigned char)(v >> 16);
    p[2] = (unsigned char)(v >>  8);
    p[3] = (unsigned char)(v);
}

static void
put_le32(unsigned char *p, unsigned long v)
{
    p[0] = (unsigned char)(v);
    p[1] = (unsigned char)(v >>  8);
    p[2] = (unsigned char)(v >> 16);
    p[3] = (unsigned char)(v >> 24);
}

/*  Writes a one-architecture universal binary.  With FAT_MAGIC_64 the
    arch entry carries 64-bit offset and size fields, so the entry is
    32 bytes instead of 20.  */
static int
write_fat(const char *path, int is64)
{
    unsigned char buf[PAYLOAD_OFF + PAYLOAD_LEN];
    unsigned char *p = buf;
    FILE *f = 0;
    size_t n = 0;

    memset(buf, 0, sizeof(buf));
    put_be32(p, is64 ? FAT_MAGIC_64 : FAT_MAGIC);
    put_be32(p + 4, 1);                    /* nfat_arch */
    p += 8;
    put_be32(p, 0x0100000c);               /* cputype   */
    put_be32(p + 4, 0);                    /* cpusubtype*/
    if (is64) {
        put_be32(p +  8, 0);               /* offset, high word */
        put_be32(p + 12, PAYLOAD_OFF);     /* offset, low word  */
        put_be32(p + 16, 0);               /* size, high word   */
        put_be32(p + 20, PAYLOAD_LEN);     /* size, low word    */
    } else {
        put_be32(p +  8, PAYLOAD_OFF);
        put_be32(p + 12, PAYLOAD_LEN);
    }
    /*  A minimal 64-bit Mach-O so the arch entry points at something
        with a recognizable magic number. */
    p = buf + PAYLOAD_OFF;
    put_le32(p, MH_MAGIC_64);
    put_le32(p + 4, 0x0100000c);

    f = fopen(path, "wb");
    if (!f) {
        return 1;
    }
    n = fwrite(buf, 1, sizeof(buf), f);
    fclose(f);
    return n == sizeof(buf) ? 0 : 1;
}

int
main(void)
{
    const char *f32 = "test_macho_universal_32.poc";
    const char *f64 = "test_macho_universal_64.poc";
    int res32 = 0;
    int res64 = 0;
    int err32 = 0;
    int err64 = 0;
    int failcount = 0;

    if (write_fat(f32, 0) || write_fat(f64, 1)) {
        printf("FAIL test_macho_universal: cannot write "
            "test files\n");
        return 1;
    }
    return 0;
}
