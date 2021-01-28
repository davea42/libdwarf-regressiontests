
static int glx = 44;
int foo(int x, int y)
{
    int total = 8;

    return total +x + (y*total);
}

int main()
{
    int v = 0;
  
    v = foo(7,21);

    v += foo(13,3) +glx;
    
    return v;
}
