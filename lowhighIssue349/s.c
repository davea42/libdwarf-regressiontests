extern int g(int);
int f(int a, int b) { int x = a*3; x = g(x); int y = x + b; y = g(y); return y + a; }
