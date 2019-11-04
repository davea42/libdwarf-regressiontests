
/*  Copyright 2019 David Anderson
    This code is hereby placed into the public domain.
    It is meant to be compiled and linked
    And if that suceeds we declare zlib available. */

#include <stdio.h>
#include <zlib.h>

int main()
{
    int res = 0;
    Bytef *dest = 0;
    Bytef *src = 0;
    uLongf destlen = 0;
    uLong srclen = 0;

    res = uncompress(dest,&destlen,src,srclen);
    return 0;
}
