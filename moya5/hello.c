// build with: clang -gdwarf-5 -gsplit-dwarf -o hello hello.c
#include <stdio.h>

int main() {
  printf("hello world\n");
  return 0;
}
