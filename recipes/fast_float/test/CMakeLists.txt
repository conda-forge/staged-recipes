cmake_minimum_required(VERSION 3.26)

project(program-using-fast-float LANGUAGES CXX)
add_executable(program main.cpp)

find_package(FastFloat CONFIG REQUIRED)
target_link_libraries(program PRIVATE FastFloat::fast_float)
