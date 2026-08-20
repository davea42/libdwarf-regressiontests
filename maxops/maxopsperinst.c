

int foo = 2; 

int
max(int a, int b)
{
    if (a >= b) return a;
    return b;
}

int main(void)
{
     int c = max(3,4);
     return c;
}
