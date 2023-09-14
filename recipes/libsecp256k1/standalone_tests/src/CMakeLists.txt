cmake_minimum_required(VERSION 3.13)

if(CMAKE_VERSION VERSION_GREATER_EQUAL 3.15)
  # MSVC runtime library flags are selected by the CMAKE_MSVC_RUNTIME_LIBRARY abstraction.
  cmake_policy(SET CMP0091 NEW)
  # MSVC warning flags are not in CMAKE_<LANG>_FLAGS by default.
  cmake_policy(SET CMP0092 NEW)
endif()

project(dummy_standalone_tests LANGUAGES C)

if(NOT BUILD_SHARED_LIBS)
  set(MY_PROJECT_NAME libsecp256k1-static)
else ()
  set(MY_PROJECT_NAME libsecp256k1)
endif()

find_package(${MY_PROJECT_NAME} CONFIG REQUIRED)

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

if (${MY_PROJECT_NAME}_FOUND)
  add_executable(stda_noverify_tests tests.c)
  target_link_libraries(stda_noverify_tests ${MY_PROJECT_NAME}::secp256k1)
  add_test(NAME stda_noverify_tests COMMAND stda_noverify_tests)

  add_executable(stda_tests tests.c)
  target_compile_definitions(stda_tests PRIVATE VERIFY)
  target_link_libraries(stda_tests PRIVATE ${MY_PROJECT_NAME}::secp256k1)
  add_test(NAME stda_tests COMMAND stda_tests)

  # Note: do not include secp256k1_precomputed in exhaustive_tests (it uses runtime-generated tables).
  add_executable(stda_exhaustive_tests tests_exhaustive.c)
  target_link_libraries(stda_exhaustive_tests ${MY_PROJECT_NAME}::secp256k1)
  target_compile_definitions(stda_exhaustive_tests PRIVATE $<$<NOT:$<CONFIG:Coverage>>:VERIFY>)
  add_test(NAME stda_exhaustive_tests COMMAND stda_exhaustive_tests)
endif()

# Ask CTest to create a "check" target (e.g., make check) as alias for the "test" target.
# CTEST_TEST_TARGET_ALIAS is not documented but supposed to be user-facing.
# See: https://gitlab.kitware.com/cmake/cmake/-/commit/816c9d1aa1f2b42d40c81a991b68c96eb12b6d2
set(CTEST_TEST_TARGET_ALIAS check)
include(CTest)
enable_testing()

option(SECP256K1_BUILD_TESTS "Build tests." ON)
option(SECP256K1_BUILD_EXHAUSTIVE_TESTS "Build exhaustive tests." ON)

