/*  This is a hello-world sort of executable
    that will be our vehicle to copy to construct
    a valid Elf exectable (with lots of unused 
    space. */
#include <stdio.h>

static int
specialfunc(int x) 
{
     double d = x;
     int y = 12;

     y = y + (int)d;
     return y;
}

int main()
{
    long objectz = 3;    

    objectz += specialfunc(objectz);
    printf("Hello, this is %ld\n",objectz); 
    return objectz;
}
