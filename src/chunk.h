#ifndef clox_chunk_h
#define clox_chunk_h

#include "common.h"

typedef struct {
  clox_count_t count;
  clox_count_t capacity;
  uint8_t *code;
} Chunk;

void initChunk(Chunk *chunk);
void writeChunk(Chunk *chunk, uint8_t byte);
void freeChunk(Chunk *chunk);

#endif // clox_chunk_h
