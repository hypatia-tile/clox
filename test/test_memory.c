#include "common.h"
#include "memory.h"
#include <criterion/criterion.h>

Test(dyarr_memory, grow_capacity) {
  clox_count_t c0 = 0, c1 = 0, c2 = 3, c3 = 13, c4 = CLOX_COUNT_MAX;
  cr_assert_eq(false, grow_capacity(&c1, c1));
  cr_assert_eq(8, c1);
  cr_assert_eq(false, grow_capacity(&c2, c2));
  cr_assert_eq(8, c2); // if size < 8 then GROW_CAPACITY(size) = 8
  cr_assert_eq(false, grow_capacity(&c0, c3));
  cr_assert_eq(26, c0);
  cr_assert_eq(true, grow_capacity(&c0, c4));
}
