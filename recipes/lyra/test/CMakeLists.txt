cmake_minimum_required(VERSION 3.0)

project(program-using-lyra LANGUAGES CXX)
add_executable(program main.cpp)

find_package(lyra CONFIG REQUIRED)
target_link_libraries(program PRIVATE bfg::lyra)
