
/*  Copyright 2019 David Anderson
    This code is hereby placed into the public domain.
    It is meant to be compiled and linked
    And if that suceeds we declare zstd library available. */

#include <stdio.h>
#include <stddef.h>
#include <zstd.h>

int main()
{
    size_t res = 0;
    char *dest = 0;
    char *src = 0;
    size_t destlen = 0;
    size_t srclen = 0;

    res = ZSTD_decompress(dest,destlen,src,srclen);
    return 0;
}
