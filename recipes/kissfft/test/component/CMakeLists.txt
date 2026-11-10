cmake_minimum_required(VERSION 3.16)
project(kissfft_component_test LANGUAGES C)

# With a datatype component, kissfft::kissfft is defined as well.
find_package(kissfft CONFIG REQUIRED COMPONENTS float)
add_executable(test_component ../test.c)
target_link_libraries(test_component PRIVATE kissfft::kissfft)
if(UNIX AND NOT APPLE)
  target_link_libraries(test_component PRIVATE m)
endif()
