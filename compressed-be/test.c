
#include <stdio.h>
#include <time.h>

struct b_s {
unsigned f;
unsigned g;
};
struct a_s {
int v;
int x;
struct b_s bs;
};

static void
mfunc(struct a_s *p)
{
    printf(" %d %d %u %u\n",
        p->v,p->x,
        p->bs.f,p->bs.g);
}

int main()
{
     struct a_s ax;

     time_t now = time(0);
     
     ax.v = now+1;
     ax.x = now +2;
     ax.bs.f = ax.x  -27;
     ax.bs.g = ax.bs.g -100;
     return ax.v;
}
