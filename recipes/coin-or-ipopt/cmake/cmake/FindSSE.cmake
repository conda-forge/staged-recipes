# Check if SSE/AVX instructions are available on the machine where
# the project is compiled.

# -mmmx
# 
# -msse
# -msse2
# -msse3
# -mssse3
# -msse4
# -msse4.1
# -msse4.2
# -msse4a
# -mfpmath=sse
# 
# -mavx
# -mavx2
# -mavx512f
# -mavx512pf
# -mavx512er
# -mavx512cd
# -mavx512vl
# -mavx512bw
# -mavx512dq
# -mavx512ifma
# -mavx512vbmi
# 
# -m3dnow

if (CMAKE_SYSTEM_NAME MATCHES "Linux")
  execute_process(COMMAND cat /proc/cpuinfo OUTPUT_VARIABLE CPUINFO)

  string(REGEX REPLACE "^.*(mmx).*$" "\\1" MMX_THERE ${CPUINFO})
  string(COMPARE EQUAL "mmx" "${MMX_THERE}" MMX_TRUE)
  if (MMX_TRUE)
    set(MMX_FOUND true CACHE BOOL "MMX available on host")
  else ()
    set(MMX_FOUND false CACHE BOOL "MMX available on host")
  endif ()
  
  string(REGEX REPLACE "^.*(sse2).*$" "\\1" SSE_THERE ${CPUINFO})
  string(COMPARE EQUAL "sse2" "${SSE_THERE}" SSE2_TRUE)
  if (SSE2_TRUE)
    set(SSE2_FOUND true CACHE BOOL "SSE2 available on host")
  else ()
    set(SSE2_FOUND false CACHE BOOL "SSE2 available on host")
  endif ()
  
  # /proc/cpuinfo apparently omits sse3 :(
  string(REGEX REPLACE "^.*[^s](sse3).*$" "\\1" SSE_THERE ${CPUINFO})
  string(COMPARE EQUAL "sse3" "${SSE_THERE}" SSE3_TRUE)
  if (NOT SSE3_TRUE)
    string(REGEX REPLACE "^.*(T2300).*$" "\\1" SSE_THERE ${CPUINFO})
    string(COMPARE EQUAL "T2300" "${SSE_THERE}" SSE3_TRUE)
  endif ()
  
  string(REGEX REPLACE "^.*(ssse3).*$" "\\1" SSE_THERE ${CPUINFO})
  string(COMPARE EQUAL "ssse3" "${SSE_THERE}" SSSE3_TRUE)
  if (SSE3_TRUE OR SSSE3_TRUE)
    set(SSE3_FOUND true CACHE BOOL "SSE3 available on host")
  else ()
    set(SSE3_FOUND false CACHE BOOL "SSE3 available on host")
  endif ()
  
  if (SSSE3_TRUE)
    set(SSSE3_FOUND true CACHE BOOL "SSSE3 available on host")
  else ()
    set(SSSE3_FOUND false CACHE BOOL "SSSE3 available on host")
  endif ()

  string(REGEX REPLACE "^.*(sse4_1).*$" "\\1" SSE_THERE ${CPUINFO})
  string(COMPARE EQUAL "sse4_1" "${SSE_THERE}" SSE41_TRUE)
  if (SSE41_TRUE)
    set(SSE4_1_FOUND true CACHE BOOL "SSE4.1 available on host")
  else ()
    set(SSE4_1_FOUND false CACHE BOOL "SSE4.1 available on host")
  endif ()

  string(REGEX REPLACE "^.*(sse4_2).*$" "\\1" SSE_THERE ${CPUINFO})
  string(COMPARE EQUAL "sse4_2" "${SSE_THERE}" SSE42_TRUE)
  if (SSE42_TRUE)
    set(SSE4_2_FOUND true CACHE BOOL "SSE4.2 available on host")
  else ()
    set(SSE4_2_FOUND false CACHE BOOL "SSE4.2 available on host")
  endif ()
  
  string(REGEX REPLACE "^.*(avx).*$" "\\1" SSE_THERE ${CPUINFO})
  string(COMPARE EQUAL "avx" "${SSE_THERE}" AVX_TRUE)
  if (AVX_TRUE)
    set(AVX_FOUND true CACHE BOOL "AVX available on host")
  else ()
    set(AVX_FOUND false CACHE BOOL "AVX available on host")
  endif ()
  
  string(REGEX REPLACE "^.*(avx2).*$" "\\1" SSE_THERE ${CPUINFO})
  string(COMPARE EQUAL "avx2" "${SSE_THERE}" AVX2_TRUE)
  if (AVX2_TRUE)
    set(AVX2_FOUND true CACHE BOOL "AVX2 available on host")
  else ()
    set(AVX2_FOUND false CACHE BOOL "AVX2 available on host")
  endif ()
elseif (CMAKE_SYSTEM_NAME MATCHES "Darwin")
  execute_process(COMMAND /usr/sbin/sysctl -n machdep.cpu.features OUTPUT_VARIABLE CPUINFO)
  
  string(REGEX REPLACE "^.*(mmx).*$" "\\1" MMX_THERE ${CPUINFO})
  string(COMPARE EQUAL "mmx" "${MMX_THERE}" MMX_TRUE)
  if (MMX_TRUE)
    set(MMX_FOUND true CACHE BOOL "MMX available on host")
  else ()
    set(MMX_FOUND false CACHE BOOL "MMX available on host")
  endif ()
  
  string(REGEX REPLACE "^.*[^S](SSE2).*$" "\\1" SSE_THERE ${CPUINFO})
  string(COMPARE EQUAL "SSE2" "${SSE_THERE}" SSE2_TRUE)
  if (SSE2_TRUE)
    set(SSE2_FOUND true CACHE BOOL "SSE2 available on host")
  else ()
    set(SSE2_FOUND false CACHE BOOL "SSE2 available on host")
  endif ()
  
  string(REGEX REPLACE "^.*[^S](SSE3).*$" "\\1" SSE_THERE ${CPUINFO})
  string(COMPARE EQUAL "SSE3" "${SSE_THERE}" SSE3_TRUE)
  if (SSE3_TRUE)
    set(SSE3_FOUND true CACHE BOOL "SSE3 available on host")
  else ()
    set(SSE3_FOUND false CACHE BOOL "SSE3 available on host")
  endif ()
  
  string(REGEX REPLACE "^.*(SSSE3).*$" "\\1" SSE_THERE ${CPUINFO})
  string(COMPARE EQUAL "SSSE3" "${SSE_THERE}" SSSE3_TRUE)
  if (SSSE3_TRUE)
    set(SSSE3_FOUND true CACHE BOOL "SSSE3 available on host")
  else ()
    set(SSSE3_FOUND false CACHE BOOL "SSSE3 available on host")
  endif ()
  
  string(REGEX REPLACE "^.*(SSE4.1).*$" "\\1" SSE_THERE ${CPUINFO})
  string(COMPARE EQUAL "SSE4.1" "${SSE_THERE}" SSE41_TRUE)
  if (SSE41_TRUE)
    set(SSE4_1_FOUND true CACHE BOOL "SSE4.1 available on host")
  else ()
    set(SSE4_1_FOUND false CACHE BOOL "SSE4.1 available on host")
  endif ()
  
  string(REGEX REPLACE "^.*(SSE4.2).*$" "\\1" SSE_THERE ${CPUINFO})
  string(COMPARE EQUAL "SSE4.2" "${SSE_THERE}" SSE42_TRUE)
  if (SSE42_TRUE)
    set(SSE4_2_FOUND true CACHE BOOL "SSE4.2 available on host")
  else ()
    set(SSE4_2_FOUND false CACHE BOOL "SSE4.2 available on host")
  endif ()
  
  string(REGEX REPLACE "^.*(AVX).*$" "\\1" SSE_THERE ${CPUINFO})
  string(COMPARE EQUAL "AVX" "${SSE_THERE}" AVX_TRUE)
  if (AVX_TRUE)
    set(AVX_FOUND true CACHE BOOL "AVX available on host")
  else ()
    set(AVX_FOUND false CACHE BOOL "AVX available on host")
  endif ()
  
  string(REGEX REPLACE "^.*(AVX2).*$" "\\1" SSE_THERE ${CPUINFO})
  string(COMPARE EQUAL "AVX2" "${SSE_THERE}" AVX2_TRUE)
  if (AVX2_TRUE)
    set(AVX2_FOUND true CACHE BOOL "AVX2 available on host")
  else ()
    set(AVX2_FOUND false CACHE BOOL "AVX2 available on host")
  endif ()
elseif (CMAKE_SYSTEM_NAME MATCHES "Windows")
  # TODO
  set(MMX_FOUND    false CACHE BOOL "MMX available on host")
  set(SSE2_FOUND   true  CACHE BOOL "SSE2 available on host")
  set(SSE3_FOUND   false CACHE BOOL "SSE3 available on host")
  set(SSSE3_FOUND  false CACHE BOOL "SSSE3 available on host")
  set(SSE4_1_FOUND false CACHE BOOL "SSE4.1 available on host")
  set(SSE4_2_FOUND false CACHE BOOL "SSE4.2 available on host")
  set(AVX_FOUND    false CACHE BOOL "AVX available on host")
  set(AVX2_FOUND   false CACHE BOOL "AVX2 available on host")
else ()
  set(MMX_FOUND    true  CACHE BOOL "MMX available on host")
  set(SSE2_FOUND   true  CACHE BOOL "SSE2 available on host")
  set(SSE3_FOUND   false CACHE BOOL "SSE3 available on host")
  set(SSSE3_FOUND  false CACHE BOOL "SSSE3 available on host")
  set(SSE4_1_FOUND false CACHE BOOL "SSE4.1 available on host")
  set(SSE4_2_FOUND false CACHE BOOL "SSE4.2 available on host")
  set(AVX_FOUND    false CACHE BOOL "AVX available on host")
  set(AVX2_FOUND   false CACHE BOOL "AVX2 available on host")
endif ()

if (NOT MMX_FOUND)
  message(STATUS "Could not find hardware support for MMX on this machine.")
endif ()

if (NOT SSE2_FOUND)
  message(STATUS "Could not find hardware support for SSE2 on this machine.")
endif ()

if (NOT SSE3_FOUND)
  message(STATUS "Could not find hardware support for SSE3 on this machine.")
endif ()

if (NOT SSSE3_FOUND)
  message(STATUS "Could not find hardware support for SSSE3 on this machine.")
endif ()

if (NOT SSE4_1_FOUND)
  message(STATUS "Could not find hardware support for SSE4.1 on this machine.")
endif ()

if (NOT SSE4_2_FOUND)
  message(STATUS "Could not find hardware support for SSE4.2 on this machine.")
endif ()

if (NOT AVX_FOUND)
  message(STATUS "Could not find hardware support for AVX on this machine.")
endif ()

if (NOT AVX2_FOUND)
  message(STATUS "Could not find hardware support for AVX2 on this machine.")
endif ()

set(SSE_COMPILER_FLAGS )

if ((CMAKE_SYSTEM_NAME MATCHES "Darwin") OR (CMAKE_SYSTEM_NAME MATCHES "Linux"))
  if (MMX_FOUND)
    set(SSE_COMPILER_FLAGS "${SSE_COMPILER_FLAGS} -mmmx")
  endif ()
  
  if (SSE2_FOUND)
    set(SSE_COMPILER_FLAGS "${SSE_COMPILER_FLAGS} -mfpmath=sse -msse -msse2")
  endif ()
  
  if (SSE3_FOUND)
    set(SSE_COMPILER_FLAGS "${SSE_COMPILER_FLAGS} -msse3")
  endif ()
  
  if (SSSE3_FOUND)
    set(SSE_COMPILER_FLAGS "${SSE_COMPILER_FLAGS} -mssse3")
  endif ()
  
  if (SSE4_1_FOUND)
    set(SSE_COMPILER_FLAGS "${SSE_COMPILER_FLAGS} -msse4 -msse4.1")
  endif ()
  
  if (SSE4_2_FOUND)
    set(SSE_COMPILER_FLAGS "${SSE_COMPILER_FLAGS} -msse4.2")
  endif ()
  
  if (AVX_FOUND)
    set(SSE_COMPILER_FLAGS "${SSE_COMPILER_FLAGS} -mavx")
  endif ()
  
  if (AVX2_FOUND)
    set(SSE_COMPILER_FLAGS "${SSE_COMPILER_FLAGS} -mavx2")
  endif ()
endif ()

if (CMAKE_SYSTEM_NAME MATCHES "Windows")
  if (MMX_FOUND)
    set(SSE_COMPILER_FLAGS "${SSE_COMPILER_FLAGS} /QMMX")
  endif ()
  
  if (SSE2_FOUND)
    set(SSE_COMPILER_FLAGS "${SSE_COMPILER_FLAGS} /QSSE /QSSE2")
  endif ()
  
  if (SSE3_FOUND)
    set(SSE_COMPILER_FLAGS "${SSE_COMPILER_FLAGS} /QSSE3")
  endif ()
  
  if (SSSE3_FOUND)
    set(SSE_COMPILER_FLAGS "${SSE_COMPILER_FLAGS} /QSSSE3")
  endif ()
  
  if (SSE4_1_FOUND)
    set(SSE_COMPILER_FLAGS "${SSE_COMPILER_FLAGS} /QSSE4 /QSSE4.1")
  endif ()
  
  if (SSE4_2_FOUND)
    set(SSE_COMPILER_FLAGS "${SSE_COMPILER_FLAGS} /QSSE4.2")
  endif ()
  
  if (AVX_FOUND)
    set(SSE_COMPILER_FLAGS "${SSE_COMPILER_FLAGS} /QAVX")
  endif ()
  
  if (AVX2_FOUND)
    set(SSE_COMPILER_FLAGS "${SSE_COMPILER_FLAGS} /QAVX2")
  endif ()
endif ()

mark_as_advanced(MMX_FOUND SSE2_FOUND SSE3_FOUND SSSE3_FOUND SSE4_1_FOUND SSE4_2_FOUND AVX_FOUND AVX2_FOUND SSE_COMPILER_FLAGS)
  
