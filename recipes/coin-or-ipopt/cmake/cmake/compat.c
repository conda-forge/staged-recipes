#include <stddef.h>
#include <sys/select.h>

#ifdef __cplusplus
extern "C" {
#endif
  
// Prior to GLIBC_2.14, memcpy was aliased to memmove.
void* memmove(void* a, const void* b, size_t c);
void* memcpy(void* a, const void* b, size_t c);
void* memcpy(void* a, const void* b, size_t c) {
  return memmove(a, b, c);
}

#ifdef __cplusplus
}
#endif
