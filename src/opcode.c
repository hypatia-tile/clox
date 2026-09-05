#include "opcode.h"

static char *mnemonic[] = {
    [OP_RETURN] = "OP_RETURN",
};

// Add assertion to catch cases where values outside the mnemonic's range are
// passed.
char *opcodeName(Opcode instruction) { return mnemonic[instruction]; }
