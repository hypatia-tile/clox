#include "memory.h"
#include <criterion/criterion.h>

Test(dyarr_memory, grow_capacity) {
  cr_assert_eq(8, GROW_CAPACITY(0));
  cr_assert_eq(8, GROW_CAPACITY(3)); // if size < 8 then GROW_CAPACITY(size) = 8
  cr_assert_eq(26, GROW_CAPACITY(13));
}
