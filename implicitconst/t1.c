

int myfunc(int y);

int myfunc4(int y)
{
     const int z = 12;

     return myfunc(y+z);
}

int myfunc3(int y)
{
     const int z = 12;

     return myfunc4(y+z);
}



int main()
{
    const int cint = 12;

    return myfunc3(cint);
}
