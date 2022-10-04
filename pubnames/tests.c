#include "tests.h"

static int
g(int i)
{
     int h = 0;
     h = i*2;
     return h;
}

int
tests_func(int f, int gv)
{

    int z = 4;
    z += f +gv;
    z += 3*g(3);
    return z;
}


