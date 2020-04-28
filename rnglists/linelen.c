#include <stdio.h>
int main()
{
    int linenum = 1;
    int linelen = 0;
    int maxlinelen = 0;
    int maxlinenum = 0;
    for(;;) {
        int c = fgetc(stdin);
        if(c == EOF) {
             break;
        }
        if (c == '\n') {
            printf("Line %d, len %d\n",linenum,linelen);
            if(linelen >maxlinelen) {
                 maxlinelen = linelen;
                 maxlinenum = linenum;
            }
            linelen = 0;
            ++linenum;
        } else {
            ++linelen;
        }
        
    }
    printf("Max line len %d, on line %d\n",maxlinelen,maxlinenum);
    return 0;
}
