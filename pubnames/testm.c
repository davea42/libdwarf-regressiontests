#include <stdio.h> 
#include "tests.h"

int globalint;
int testv = 3;

float myfloat = 0.3f;

int
globalfunc(int j)
{
     int res = 3;
     return res+j;
}


int main(int argc, char **argv) 
{
    int y = 0;
    int z = 0;

    testv += argc;
    y = globalfunc(testv);
    z = globalfunc(y);
    y = tests_func(y,z);
    return z;  
}
