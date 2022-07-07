#if defined(__linux) && !defined(DISABLE_SYMVER)
__asm__(".symver memcpy, memcpy@GLIBC_2.2.5");
__asm__(".symver omp_set_lock, omp_set_lock@OMP_1.0");
__asm__(".symver omp_unset_lock, omp_unset_lock@OMP_1.0");
__asm__(".symver omp_init_lock, omp_init_lock@OMP_1.0");
#endif

#ifdef _MSC_VER
#  define stricmp _stricmp
#  define inline __inline
#endif
