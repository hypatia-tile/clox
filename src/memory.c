#include "memory.h"
#include "check.h"
#include <stdckdint.h>
#include <stdlib.h>

void *reallocate(size_t size, void *pointer,
                 [[maybe_unused]] clox_count_t oldCount,
                 clox_count_t newCount) {
  if (newCount == 0) {
    free(pointer);
    return NULL;
  }
  size_t newSize;
  bool overflow = ckd_mul(&newSize, newCount, size);
  CHECK(!overflow, "newSize must be in the range of size_t");
  void *result = realloc(pointer, newSize);
  if (result == NULL) {
    exit(1);
  }

  return result;
}
