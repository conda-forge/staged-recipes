cmake_minimum_required(VERSION 3.26)

project(program-using-trompeloeil LANGUAGES CXX)
add_executable(program main.cpp)

find_package(trompeloeil CONFIG REQUIRED)
target_link_libraries(program PRIVATE trompeloeil::trompeloeil)
