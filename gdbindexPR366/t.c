/* t.c Testcase for the pull request*/
int counter;
int add(int a, int b) { return a + b + counter; }
int main(void) { return add(1, 2); }
