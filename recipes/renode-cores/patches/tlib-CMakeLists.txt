cmake_minimum_required(VERSION 3.12)

project (tlib LANGUAGES C)

if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    set(DEBUG_DEFS "-DDEBUG -DDEBUG_ON")
endif()

option (HOST_BIG_ENDIAN "Host big endian" OFF)

if(NOT DEFINED HOST_ARCH)
    message(STATUS "'HOST_ARCH' isn't set; analyzing the CPU (${CMAKE_SYSTEM_PROCESSOR})...")
    if(${CMAKE_SYSTEM_PROCESSOR} MATCHES "(AMD64|amd64|86)")
        set (HOST_ARCH "i386" CACHE STRING "Host architecture")
    elseif(${CMAKE_SYSTEM_PROCESSOR} MATCHES "(aarch64|arm64)")
        set (HOST_ARCH "aarch64" CACHE STRING "Host architecture")
    # Has to come last to not match arm macs arm64, while still matching a cpu like armv7l
    elseif(${CMAKE_SYSTEM_PROCESSOR} MATCHES "(arm)")
        set (HOST_ARCH "arm" CACHE STRING "Host architecture")
    else()
        message(FATAL_ERROR "CMAKE_SYSTEM_PROCESSOR '${CMAKE_SYSTEM_PROCESSOR}' doesn't seem to be supported. Supported host architectures are: 'arm', 'i386', 'aarch64/arm64'. Please set 'HOST_ARCH' manually.")
    endif()
endif()
message(VERBOSE "Using HOST_ARCH: ${HOST_ARCH}")

# Detect whether the host is 32- or 64-bit
math (EXPR WORD_SIZE_FOUND "${CMAKE_SIZEOF_VOID_P} * 8")
set (HOST_WORD_SIZE "${WORD_SIZE_FOUND}" CACHE STRING "Host word size")
message(VERBOSE "Using HOST_WORD_SIZE: ${HOST_WORD_SIZE}")

if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
    set(CMAKE_BUILD_TYPE "Release" CACHE
          STRING "Choose the type of build." FORCE)
    set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS
        "Debug" "Release" "RelWithDebInfo")
endif()

option (PROFILING_BUILD "Build optimized for profiling" OFF)
if(PROFILING_BUILD)
    message(STATUS "Profiling enhancements are enabled")
    add_definitions (
        # Forcing not to omit frame pointer can have negative impact on performance,
        # so the end profiling result will not exactly be equal to running on live system.
        # Unfortunately without frame pointers perf might have problem with unwinding stack
        # and call traces in reports will become less readable if using frame pointers for stack unwinding.
        -fno-omit-frame-pointer
        -DGENERATE_PERF_MAP
        -g3
    )
elseif(CMAKE_BUILD_TYPE STREQUAL "Release")
        add_definitions(-fomit-frame-pointer)
endif()

if (HOST_ARCH MATCHES "(arm|aarch64)" AND CMAKE_BUILD_TYPE STREQUAL "Release" AND NOT CMAKE_C_COMPILER_ID STREQUAL "AppleClang")
    # gcc emits a clobber error for unwind.h DECLARE_ENV_PTR() in release mode on arm targets
    # so demote it to a warning in this case, but not on arm mac clang, because this flag does not exsist
    add_definitions(-Wno-error=clobbered)
    add_definitions(-Wno-clobbered)
endif()

option (TARGET_BIG_ENDIAN "Target big endian" OFF)
set (TARGET_ARCH "" CACHE STRING "Target architecture")
set (TARGET_WORD_SIZE "32" CACHE STRING "Target word size")
message(VERBOSE "Target is: ${TARGET_WORD_SIZE}-bit ${TARGET_ARCH}")

set_property (CACHE HOST_ARCH PROPERTY STRINGS i386 arm aarch64)
set_property (CACHE TARGET_ARCH PROPERTY STRINGS i386 x86_64 arm arm-m arm64 sparc ppc ppc64 riscv riscv64 xtensa)

if(NOT HOST_ARCH)
    message (FATAL_ERROR "Host architecture not set")
endif()

if(NOT TARGET_ARCH)
    message (FATAL_ERROR "Target architecture not set")
endif()

if(TARGET_BIG_ENDIAN)
    set (BIG_ENDIAN_DEF -DTARGET_WORDS_BIGENDIAN=1)
endif()

# Let's make 'TARGET_ACTUAL_ARCH' a lowercase 'TARGET_ARCH'.
string (TOLOWER "${TARGET_ARCH}" TARGET_ACTUAL_ARCH)

if("${TARGET_ACTUAL_ARCH}" STREQUAL "arm-m")
    set (TARGET_ACTUAL_ARCH "arm")
    set (ARM_M_DEF -DTARGET_PROTO_ARM_M=1)
elseif("${TARGET_ACTUAL_ARCH}" STREQUAL "ppc64")
    set (TARGET_ACTUAL_ARCH "ppc")
elseif("${TARGET_ACTUAL_ARCH}" STREQUAL "riscv64")
    set (TARGET_ACTUAL_ARCH "riscv")
elseif("${TARGET_ACTUAL_ARCH}" STREQUAL "x86_64")
    set (TARGET_ACTUAL_ARCH "i386")
endif()

# Let's make TARGET_ACTUAL_ARCH available in CMakes adding tlib subdirectory. Using PARENT_SCOPE
# in the top project triggers warnings though so the if below prevents them in tlib built directly.
if(NOT ${CMAKE_PROJECT_NAME} STREQUAL tlib)
    set (TARGET_ACTUAL_ARCH "${TARGET_ACTUAL_ARCH}" PARENT_SCOPE)
endif()

set(TARGET_INSN_START_EXTRA_WORDS 0)
if("${TARGET_ACTUAL_ARCH}" MATCHES "^(arm|i386|sparc)$")
    set(TARGET_INSN_START_EXTRA_WORDS 1)
elseif("${TARGET_ACTUAL_ARCH}" STREQUAL "arm64")
    set(TARGET_INSN_START_EXTRA_WORDS 2)
endif()

if("${TARGET_ACTUAL_ARCH}" STREQUAL "arm64" AND NOT "${TARGET_WORD_SIZE}" STREQUAL "64")
    message (FATAL_ERROR "ERROR: arm64 target has to be built with TARGET_WORD_SIZE=64")
endif()

string (TOUPPER "${HOST_ARCH}" HOST_ARCH_U)
string (TOUPPER "${TARGET_ACTUAL_ARCH}" TARGET_ACTUAL_ARCH_U)

set(TLIB_COMMIT_SHA "" CACHE STRING "Current tlib commit SHA")
if(NOT TLIB_COMMIT_SHA)
    execute_process(COMMAND git rev-parse --short HEAD RESULT_VARIABLE GIT_RESULT OUTPUT_VARIABLE GIT_OUTPUT OUTPUT_STRIP_TRAILING_WHITESPACE WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
    if(NOT GIT_RESULT EQUAL 0)
        set(GIT_OUTPUT "undefined")
    endif()

    set(TLIB_COMMIT_SHA "${GIT_OUTPUT}" CACHE STRING "Current tlib commit SHA" FORCE)
endif()

add_subdirectory(tcg)

if("${TARGET_ACTUAL_ARCH}" STREQUAL "riscv" OR "${TARGET_ACTUAL_ARCH}" STREQUAL "riscv64")
    set(SOFTFLOAT_SPECIALIZED_ARCHITECTURE "RISCV")
    add_subdirectory(softfloat-3)
    set(SOFTFLOAT3 softfloat-3)

    if(CMAKE_BUILD_TYPE STREQUAL "Release" AND NOT PROFILING_BUILD)
        target_compile_definitions(softfloat-3 PRIVATE
            INLINE_LEVEL=5
        )
    endif()
endif()

if (NOT CMAKE_C_COMPILER_ID MATCHES "(clang)" AND NOT "${TARGET_ACTUAL_ARCH}" STREQUAL "arm64")
    # Clang throws warnings from the arm64 target's function stubs
    # so do not enable -Werror in that case until that is fixed
    add_definitions(-Werror)
endif()


add_definitions (
    -fPIC
    -Wall
    -Wextra
    -Wno-unused-parameter
    -Wno-sign-compare

    -DHOST_BITS_${HOST_WORD_SIZE}
    -DHOST_${HOST_ARCH_U}=1
    -DHOST_LONG_BITS=${HOST_WORD_SIZE}

    -DTARGET_${TARGET_ACTUAL_ARCH_U}=1

    -DTARGET_SHORT_ALIGNMENT=2
    -DTARGET_INT_ALIGNMENT=4
    -DTARGET_LONG_ALIGNMENT=4
    -DTARGET_LLONG_ALIGNMENT=4

    -DTARGET_LONG_BITS=${TARGET_WORD_SIZE}
    -DTARGET_INSN_START_EXTRA_WORDS=${TARGET_INSN_START_EXTRA_WORDS}
    ${ARM_M_DEF}

    -DTCG_TARGET_${HOST_ARCH_U}
    -DTLIB_COMMIT=${TLIB_COMMIT_SHA}
    ${BIG_ENDIAN_DEF}
    ${DEBUG_DEFS}
    )

if("${TARGET_ACTUAL_ARCH}" STREQUAL "arm" OR "${TARGET_ACTUAL_ARCH}" STREQUAL "arm64")
    file (GLOB ARM_COMMON_SRC "arch/arm_common/*.c")
    set (ARM_COMMON_INCL "arch/arm_common")
endif()

include_directories (
    tcg
    softfloat-2
    include
    tcg/${HOST_ARCH}
    arch/${TARGET_ACTUAL_ARCH}
    ${ARM_COMMON_INCL}
    )

file (GLOB SOURCES
    "*.c"
    "softfloat-2/*.c"
    "arch/*.c"
    "external/*.c"
    "arch/${TARGET_ACTUAL_ARCH}/*.c"
    ${ARM_COMMON_SRC}
    )

add_library (tlib SHARED ${SOURCES})
add_dependencies (tlib tcg)

if("${TARGET_ACTUAL_ARCH}" STREQUAL "i386")
    set (MATH_LIB_LINK_ARG "-lm" CACHE STRING
      "Argument pointing linker to a math functions library. It's required to translate i386 code.")
endif()

# On windows, make sure the winpthread gets linked statically
if(${CMAKE_HOST_SYSTEM_NAME} MATCHES "(Windows|CYGWIN)")
    set(PTREAD_OPT -static winpthread -dynamic)
else()
    set(PTREAD_OPT pthread)
endif()

# On x86_64 Linux, the memcpy function was modified in GNU libc v2.14.
# It'd be impossible to run tlib without this wrapping with older libc.
if(${CMAKE_HOST_SYSTEM_NAME} STREQUAL Linux AND ${HOST_ARCH} STREQUAL i386 AND ${HOST_WORD_SIZE} EQUAL 64)
    set(WRAP_MEMCPY_OPT -Wl,--wrap=memcpy)
endif()

# -z flag does not work on Windows
if ((NOT (${CMAKE_HOST_SYSTEM_NAME} MATCHES "(Windows|CYGWIN)" )) AND ("${C_COMPILER_ID}" STREQUAL "GNU"))
    set (Z_OPTS -zdefs)
endif()

target_link_libraries (tlib
    ${WRAP_MEMCPY_OPT}
    -fPIC
    ${Z_OPTS}

    ${MATH_LIB_LINK_ARG}
    ${PTREAD_OPT}
    ${SOFTFLOAT3}
    tcg
    )
