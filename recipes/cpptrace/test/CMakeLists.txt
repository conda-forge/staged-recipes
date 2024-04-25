cmake_minimum_required(VERSION 3.26)

project(cpptrace-test-program LANGUAGES CXX)
add_executable(program main.cpp)

find_package(cpptrace CONFIG REQUIRED)
target_link_libraries(program PRIVATE cpptrace::cpptrace)
