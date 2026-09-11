#ifndef clox_memory_h
#define clox_memory_h

#include "common.h"
#include <limits.h>
#include <stdckdint.h>

static inline bool grow_capacity(clox_count_t *newCap, clox_count_t oldCap) {
  return oldCap < 8 ? (*newCap = 8, false) : ckd_mul(newCap, oldCap, 2);
}

#define GROW_ARRAY(type, pointer, oldCount, newCount)                          \
  (type *)reallocate(sizeof(type), pointer, oldCount, newCount)

#define FREE_ARRAY(type, pointer, oldCount)                                    \
  reallocate(sizeof(type), pointer, oldCount, 0)

void *reallocate(size_t size, void *pointer, clox_count_t oldCount,
                 clox_count_t newCount);

#endif // clox_memory_h
