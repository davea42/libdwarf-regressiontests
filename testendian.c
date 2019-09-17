/*  Copyright (c) 2019  David Anderson
    This code is hereby placed into the public domain.
*/
/*  Checks if the host running the test is little-endian or big-endian.
    prints "L" if little, "B" if big.
    exits with 0 if successful, Exits with 1 if unsuccessful.

    This assumes modern traditional two's complement endianness.
    It does not deal with other forms such as one's complement
    or for an endianness with a 4 byte integer composed
    of byte-swapping by 2 byte pairs.
*/




#include <stdio.h>  /* For printf */
#include <string.h> /* For memcpy */

struct endian {
    unsigned char l2[2];
    unsigned char l4[4];
    unsigned char l8[8];
};

int main()
{
    long l = 0xa;
    struct endian en;

    switch(sizeof(l)) {
    case 2:
        memcpy(&en.l2,&l,2);
        if (en.l2[0] == 0xa) {
            printf("k\n");
        } else if (en.l2[1] == 0xa) {
            printf("B\n");
        } else {
            return 1;
        }
        break;
    case 4:
        memcpy(&en.l4,&l,4);
        if (en.l4[0] == 0xa) {
            printf("L\n");
        } else if (en.l4[3] == 0xa) {
            printf("B\n");
        } else {
            return 1;
        }
        break;
    case 8:
        memcpy(&en.l8,&l,8);
        if (en.l8[0] == 0xa) {
            printf("L\n");
        } else if (en.l8[7] == 0xa) {
            printf("B\n");
        } else {
            return 1;
        }
        break;
    default:
        return 1;
    }
    return 0;
}
