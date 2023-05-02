cmake_minimum_required(VERSION 3.26)

project(program-using-ms-gsl LANGUAGES CXX)
add_executable(program main.cpp)

find_package(Microsoft.GSL CONFIG REQUIRED)
target_link_libraries(program PRIVATE Microsoft.GSL::GSL)
