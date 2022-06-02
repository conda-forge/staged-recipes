set( CMAKE_VERBOSE_MAKEFILE on )
cmake_minimum_required(VERSION 3.0)
project(test-ufcx)
find_package(ufcx REQUIRED CONFIG)
add_executable(test-ufcx test-ufcx.cpp)
target_link_libraries(test-ufcx PUBLIC ufcx::ufcx)

install(TARGETS test-ufcx)
