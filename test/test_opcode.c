#include <criterion/criterion.h>
#include "opcode.h"

Test(opcode_name, opcode_return) {
  const char *nm_return = opcodeName(OP_RETURN);

  cr_assert_not_null(nm_return, "opcode name should not be Null");
  cr_assert_str_eq(nm_return, "OP_RETURN", "Expected 'OP_RETURN', but got '%s'", nm_return);
}
