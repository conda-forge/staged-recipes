cmake_minimum_required(VERSION 3.16)
project(kissfft_test LANGUAGES C)

# Without components: both datatype targets, no kissfft::kissfft.
find_package(kissfft CONFIG REQUIRED)
foreach(_t kissfft::kissfft-float kissfft::kissfft-double)
  if(NOT TARGET ${_t})
    message(FATAL_ERROR "${_t} missing")
  endif()
endforeach()

add_executable(test_float test.c)
target_link_libraries(test_float PRIVATE kissfft::kissfft-float)
add_executable(test_double test.c)
target_link_libraries(test_double PRIVATE kissfft::kissfft-double)
if(UNIX AND NOT APPLE)
  target_link_libraries(test_float PRIVATE m)
  target_link_libraries(test_double PRIVATE m)
endif()
