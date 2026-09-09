#ifndef clox_check_h
#define clox_check_h

#include <stdio.h>
#include <stdlib.h>

#define ABORT()                                                                \
  do {                                                                         \
    fprintf(stderr,                                                            \
            "Assertion failed: Unreachable code\n"                             \
            "    at %s:%d\n"                                                   \
            "    in %s\n",                                                     \
            __FILE__, __LINE__, __func__);                                     \
    abort();                                                                   \
  } while (false)

#define CHECK(cond, fmt, ...)                                                  \
  do {                                                                         \
    if (!(cond)) {                                                             \
      fprintf(stderr,                                                          \
              "Assertion failed: " fmt "\n    at %s:%d"                        \
              "\n    in %s\n" __VA_OPT__(, ) __VA_ARGS__,                      \
              __FILE__, __LINE__, __func__);                                   \
      abort();                                                                 \
    }                                                                          \
  } while (false)

#endif // clox_check_h
