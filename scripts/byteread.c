
/* Looking for improper characters */
/* Copyright 2019, David Anderson.
   This file is hereby put into the public domain. */

#include <stdio.h>

/* compile with "cc byteread.c" 
   Run with "./a.out <../ALLdd"
   
   All in ../ALLdd should be plain ascii as dwarfdump
   calls 'sanitized()' to uri-code non-ascii.
*/

int main()
{
    unsigned line=1;
    unsigned charnum = 1;
    int doprint;

    while(1) { 
       int c = 0;
       c = getc(stdin);
       if (c == EOF) {
           printf("Reached end\n");
           break;
       }
       if (c == '\n') {
           line++;
       }
       if (c <= '~') {
           ++charnum;
           continue;
       }
       printf(" charnum %u line %u char 0x%x\n",charnum,line,c);
       break;
    }
    return 0;
}
