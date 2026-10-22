cmake_minimum_required(VERSION 3.10)
project(lcm_conda_test C CXX)

find_package(lcm REQUIRED)
include(${LCM_USE_FILE})
message(STATUS "Found lcm ${LCM_VERSION}")

lcm_wrap_types(
  C_SOURCES c_sources C_HEADERS c_headers
  CPP_HEADERS cpp_headers
  ${CMAKE_CURRENT_SOURCE_DIR}/example_t.lcm)

lcm_add_library(example_types-c C STATIC ${c_sources} ${c_headers})
target_include_directories(example_types-c INTERFACE
  $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}>)

lcm_add_library(example_types-cpp CPP ${cpp_headers})
target_include_directories(example_types-cpp INTERFACE
  $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}>)

add_executable(test_c test_c.c)
lcm_target_link_libraries(test_c example_types-c ${LCM_NAMESPACE}lcm)

add_executable(test_cpp test_cpp.cpp)
lcm_target_link_libraries(test_cpp example_types-cpp ${LCM_NAMESPACE}lcm)
