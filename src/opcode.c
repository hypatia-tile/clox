#include "opcode.h"
#include "check.h"

const char *opcodeName(Opcode instruction) {
  switch (instruction) {
  case OP_RETURN:
    return "OP_RETURN";
  }
  ABORT();
}
