int i = 0;
int foo()
{
       return 12;
}
int main()
{
    int j = 3;
    j += foo();
    return j;
}

