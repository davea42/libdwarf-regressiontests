
int toplevel()
{
    int x = 0;

    { int innerx = 12;
        { int innery = 15;
          int dval = 0;
          x = 12;
          dval = x *innerx + 15;
          return dval +1;
        }
    }
}
