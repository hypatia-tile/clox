#ifndef clox_opcode_h
#define clox_opcode_h

#include <stdint.h>

typedef enum : uint8_t {
  OP_RETURN,
} Opcode;

/** lookup opcode mnemonic for debugging */
const char *opcodeName(Opcode instruction);

#endif // clox_opcode_h
