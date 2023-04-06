cmake_minimum_required(VERSION 3.26)

project(program-using-seasocks LANGUAGES CXX)
add_executable(program main.cpp)

find_package(Seasocks CONFIG REQUIRED)
target_link_libraries(program PRIVATE Seasocks::seasocks)
