/* Copyright (C) 2007-2017 Jean-Marc Valin
   Copyright (C) 2017 Mozilla

   File: os_support.h
   This is the (tiny) OS abstraction layer. Aside from math.h, this is the
   only place where system headers are allowed.

   Redistribution and use in source and binary forms, with or without
   modification, are permitted provided that the following conditions are
   met:

   1. Redistributions of source code must retain the above copyright notice,
   this list of conditions and the following disclaimer.

   2. Redistributions in binary form must reproduce the above copyright
   notice, this list of conditions and the following disclaimer in the
   documentation and/or other materials provided with the distribution.

   THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
   IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
   OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
   DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT,
   INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
   (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
   SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
   HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
   STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
   ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
   POSSIBILITY OF SUCH DAMAGE.
*/

#ifndef OS_SUPPORT_H
#define OS_SUPPORT_H

#ifdef CUSTOM_SUPPORT
#  include "custom_support.h"
#endif

#include <string.h>
#include <stdlib.h>

/* Platform-specific definitions */
#ifdef _MSC_VER
#define RNNOISE_INLINE static __forceinline
#define RNNOISE_WEAK_ATTR
#else
#define RNNOISE_INLINE static inline
#define RNNOISE_WEAK_ATTR __attribute__((weak))
#endif

/* Check if functions are already defined by testing if we can declare them as extern */
#ifndef RNNOISE_ALLOC_DECLARED
#ifdef __cplusplus
extern "C" {
#endif

/* Declare functions - these may already be defined elsewhere */
#if defined(_MSC_VER)
/* For MSVC, use selectany to allow multiple definitions */
__declspec(selectany) void *rnnoise_alloc(size_t size) {
    return malloc(size);
}

__declspec(selectany) void *rnnoise_realloc(void *ptr, size_t size) {
    return realloc(ptr, size);
}

__declspec(selectany) void rnnoise_free(void *ptr) {
    free(ptr);
}
#else
/* For GCC/Clang, use weak linking */
RNNOISE_WEAK_ATTR void *rnnoise_alloc(size_t size) {
    return malloc(size);
}

RNNOISE_WEAK_ATTR void *rnnoise_realloc(void *ptr, size_t size) {
    return realloc(ptr, size);
}

RNNOISE_WEAK_ATTR void rnnoise_free(void *ptr) {
    free(ptr);
}
#endif

#ifdef __cplusplus
}
#endif

#define RNNOISE_ALLOC_DECLARED
#endif /* RNNOISE_ALLOC_DECLARED */

/** Copy n elements from src to dst. The 0* term provides compile-time type checking  */
#ifndef OVERRIDE_RNNOISE_COPY
#define RNNOISE_COPY(dst, src, n) (memcpy((dst), (src), (n)*sizeof(*(dst)) + 0*((dst)-(src)) ))
#endif

/** Copy n elements from src to dst, allowing overlapping regions. The 0* term
    provides compile-time type checking */
#ifndef OVERRIDE_RNNOISE_MOVE
#define RNNOISE_MOVE(dst, src, n) (memmove((dst), (src), (n)*sizeof(*(dst)) + 0*((dst)-(src)) ))
#endif

/** Set n elements of dst to zero */
#ifndef OVERRIDE_RNNOISE_CLEAR
#define RNNOISE_CLEAR(dst, n) (memset((dst), 0, (n)*sizeof(*(dst))))
#endif

/* Legacy compatibility macros for older RNNoise code - only define if not already defined */
#ifndef opus_alloc
#define opus_alloc rnnoise_alloc
#endif
#ifndef opus_realloc
#define opus_realloc rnnoise_realloc
#endif
#ifndef opus_free
#define opus_free rnnoise_free
#endif
#ifndef OPUS_COPY
#define OPUS_COPY RNNOISE_COPY
#endif
#ifndef OPUS_MOVE
#define OPUS_MOVE RNNOISE_MOVE
#endif
#ifndef OPUS_CLEAR
#define OPUS_CLEAR RNNOISE_CLEAR
#endif

#endif /* OS_SUPPORT_H */