/* Copyright (C) 2021 David Anderson
   This test program is placed in the public domain so anyone
   can use it for any purpose without restriction. */

/*  Compiled twice for a good test of 
    libdwarf function dwarf_bitoffset.
    DWARF4 introduced DW_AT_data_bit_offset,
    while DWARF2,3 had DW_AT_bit_offset.
    cc -gdwarf-3 -c bitoffsetexample.c -o bitoffsetexampledw3.o
    cc -gdwarf-5 -c bitoffsetexample.c -o bitoffsetexampledw5.o
*/
    

struct mystr {
    int a:1;
    int b:3;
    int c:2;
}; 
struct mystr globalex = {1,5,2};

int f(struct mystr *y)
{
    int res = 4;
    res += y->a;
    res += y->c;
    res += y->b;
    return res;
}

int main()
{
    int z = 0;
    z = f(&globalex);
    return z; 
}
