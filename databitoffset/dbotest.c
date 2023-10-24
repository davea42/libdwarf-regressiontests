#include <stdio.h>

struct struct_A {
        void            *p0;
        void            *p1;

        int             a: 1;
        int             b: 1;

        unsigned        c;
} a = {
        .p0 = NULL,
        .p1 = NULL,
        .a = 1,
        .b = 1,
        .c = 7,
};

int main(int argc, char *argv[])
{
        return 0;
}
