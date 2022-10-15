// Copyright David Anderson October 15 2022
// This meaningless source is hereby placed in the PUBLIC DOMAIN
//

#include <list>
#include <vector>
#include <string>
#include <iostream>

using std::string;
using std::cout;
using std::cerr;
using std::endl;
using std::vector;
using std::list;

class mysym {
public:
   mysym() {
       baseval = 2;
       mypubsymvec.push_back(55);
       mysymvec.push_back(13);
   };
   ~mysym() {
   };
   std::vector <unsigned int> mypubsymvec;
   static int pubmysym;
private:
   int baseval;
   std::vector <unsigned int> mysymvec;
};

class multisym {
public:
   multisym(mysym &x) {
       mslist.push_back(x);
       pubmslist.push_back(x);
       mslistpub.push_back(x);
       ++msval;
   };
   ~multisym() {
   };
   static int msfunc(float f);
   std::list<mysym> mslistpub;
   static int msval;
   std::list<mysym> pubmslist;
private:
   std::list<mysym> mslist;
};

int multisym::msval = 8;
int multisym::msfunc(float f)
{
       int y = (int)f;
       return y + multisym::msval;
}

static int
simpleintreturn(int j)
{
    return j +3;
}

multisym *pubmulti = 0;

int
main(int argc, char **argv)
{
    int rval = 0;
    mysym myrec;
    multisym multi(myrec);

    pubmulti = &multi;
    rval += multi.msval;

    for( std::list<mysym>::iterator it =
        multi.mslistpub.begin();
        it != multi.mslistpub.end();
        ++it) {
            rval += multisym::msval;
    }
    rval += simpleintreturn(15);
    return rval;
}
