cmake_minimum_required(VERSION 3.13)

if(CMAKE_VERSION VERSION_GREATER_EQUAL 3.15)
  # MSVC runtime library flags are selected by the CMAKE_MSVC_RUNTIME_LIBRARY abstraction.
  cmake_policy(SET CMP0091 NEW)
  # MSVC warning flags are not in CMAKE_<LANG>_FLAGS by default.
  cmake_policy(SET CMP0092 NEW)
endif()

project(dummy_standalone_tests LANGUAGES C)

if(CMAKE_VERSION VERSION_LESS 3.21)
  get_directory_property(parent_directory PARENT_DIRECTORY)
  if(parent_directory)
    set(PROJECT_IS_TOP_LEVEL OFF CACHE INTERNAL "Emulates CMake 3.21+ behavior.")
    set(${PROJECT_NAME}_IS_TOP_LEVEL OFF CACHE INTERNAL "Emulates CMake 3.21+ behavior.")
  else()
    set(PROJECT_IS_TOP_LEVEL ON CACHE INTERNAL "Emulates CMake 3.21+ behavior.")
    set(${PROJECT_NAME}_IS_TOP_LEVEL ON CACHE INTERNAL "Emulates CMake 3.21+ behavior.")
  endif()
  unset(parent_directory)
endif()

set(CMAKE_C_STANDARD 90)
set(CMAKE_C_EXTENSIONS OFF)

list(APPEND CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/cmake)

# Redefine configuration flags.
# We leave assertions on, because they are only used in the examples, and we want them always on there.
if(MSVC)
  string(REGEX REPLACE "/DNDEBUG[ \t\r\n]*" "" CMAKE_C_FLAGS_RELWITHDEBINFO "${CMAKE_C_FLAGS_RELWITHDEBINFO}")
  string(REGEX REPLACE "/DNDEBUG[ \t\r\n]*" "" CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE}")
  string(REGEX REPLACE "/DNDEBUG[ \t\r\n]*" "" CMAKE_C_FLAGS_MINSIZEREL "${CMAKE_C_FLAGS_MINSIZEREL}")
else()
  string(REGEX REPLACE "-DNDEBUG[ \t\r\n]*" "" CMAKE_C_FLAGS_RELWITHDEBINFO "${CMAKE_C_FLAGS_RELWITHDEBINFO}")
  string(REGEX REPLACE "-DNDEBUG[ \t\r\n]*" "" CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE}")
  string(REGEX REPLACE "-DNDEBUG[ \t\r\n]*" "" CMAKE_C_FLAGS_MINSIZEREL "${CMAKE_C_FLAGS_MINSIZEREL}")
  # Prefer -O2 optimization level. (-O3 is CMake's default for Release for many compilers.)
  string(REGEX REPLACE "-O3[ \t\r\n]*" "-O2" CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE}")
endif()

include(TryAppendCFlags)
if(MSVC)
  # Keep the following commands ordered lexicographically.
  try_append_c_flags(/W3) # Production quality warning level.
  try_append_c_flags(/wd4146) # Disable warning C4146 "unary minus operator applied to unsigned type, result still unsigned".
  try_append_c_flags(/wd4244) # Disable warning C4244 "'conversion' conversion from 'type1' to 'type2', possible loss of data".
  try_append_c_flags(/wd4267) # Disable warning C4267 "'var' : conversion from 'size_t' to 'type', possible loss of data".
  # Eliminate deprecation warnings for the older, less secure functions.
  add_compile_definitions(_CRT_SECURE_NO_WARNINGS)
else()
  # Keep the following commands ordered lexicographically.
  try_append_c_flags(-pedantic)
  try_append_c_flags(-Wall) # GCC >= 2.95 and probably many other compilers.
  try_append_c_flags(-Wcast-align) # GCC >= 2.95.
  try_append_c_flags(-Wcast-align=strict) # GCC >= 8.0.
  try_append_c_flags(-Wconditional-uninitialized) # Clang >= 3.0 only.
  try_append_c_flags(-Wextra) # GCC >= 3.4, this is the newer name of -W, which we don't use because older GCCs will warn about unused functions.
  try_append_c_flags(-Wnested-externs)
  try_append_c_flags(-Wno-long-long) # GCC >= 3.0, -Wlong-long is implied by -pedantic.
  try_append_c_flags(-Wno-overlength-strings) # GCC >= 4.2, -Woverlength-strings is implied by -pedantic.
  try_append_c_flags(-Wno-unused-function) # GCC >= 3.0, -Wunused-function is implied by -Wall.
  try_append_c_flags(-Wreserved-identifier) # Clang >= 13.0 only.
  try_append_c_flags(-Wshadow)
  try_append_c_flags(-Wstrict-prototypes)
  try_append_c_flags(-Wundef)
endif()

# Note: do not include secp256k1_precomputed in exhaustive_tests (it uses runtime-generated tables).
add_executable(stda_exhaustive_tests tests_exhaustive.c)
target_compile_definitions(stda_exhaustive_tests PRIVATE $<$<NOT:$<CONFIG:Coverage>>:VERIFY>)
add_test(NAME stda_exhaustive_tests COMMAND stda_exhaustive_tests)

if(NOT BUILD_SHARED_LIBS)
  find_package(secp256k1_library NAMES libsecp256k1-static REQUIRED)
else ()
  find_package(secp256k1_library NAMES libsecp256k1 REQUIRED)
endif()

if(secp256k1_library_FOUND)
  message(STATUS "Found Shared SECP256K1: ${secp256k1_library_VERSION}")
  target_link_libraries(stda_exhaustive_tests ${secp256k1_library})
else()
  message(FATAL_ERROR "libsecp256k1 not found")
endif()

# Ask CTest to create a "check" target (e.g., make check) as alias for the "test" target.
# CTEST_TEST_TARGET_ALIAS is not documented but supposed to be user-facing.
# See: https://gitlab.kitware.com/cmake/cmake/-/commit/816c9d1aa1f2b42d40c81a991b68c96eb12b6d2
set(CTEST_TEST_TARGET_ALIAS check)
include(CTest)
enable_testing()

