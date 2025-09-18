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
#define RNNOISE_INLINE __forceinline
#else
#define RNNOISE_INLINE static inline
#endif

/* Only define allocation functions if not already defined elsewhere */
#ifndef CUSTOM_ALLOC_DEFINED

/** RNNoise wrapper for malloc(). To do your own dynamic allocation replace this function, rnnoise_realloc, and rnnoise_free */
#ifndef OVERRIDE_RNNOISE_ALLOC
RNNOISE_INLINE void *rnnoise_alloc(size_t size)
{
   return malloc(size);
}
#endif

#ifndef OVERRIDE_RNNOISE_REALLOC
RNNOISE_INLINE void *rnnoise_realloc(void *ptr, size_t size)
{
   return realloc(ptr, size);
}
#endif

/** RNNoise wrapper for free(). To do your own dynamic allocation replace this function, rnnoise_realloc, and rnnoise_free */
#ifndef OVERRIDE_RNNOISE_FREE
RNNOISE_INLINE void rnnoise_free(void *ptr)
{
   free(ptr);
}
#endif

#endif /* CUSTOM_ALLOC_DEFINED */

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

/* Legacy compatibility macros for older RNNoise code */
#define opus_alloc rnnoise_alloc
#define opus_realloc rnnoise_realloc
#define opus_free rnnoise_free
#define OPUS_COPY RNNOISE_COPY
#define OPUS_MOVE RNNOISE_MOVE
#define OPUS_CLEAR RNNOISE_CLEAR

#endif /* OS_SUPPORT_H */