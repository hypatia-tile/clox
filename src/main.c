#include "opcode.h"
#include <stdio.h>

int main(void) {
  printf("hello, clox\n");
  printf("%s\n", opcodeName(OP_RETURN));
  return 0;
}
