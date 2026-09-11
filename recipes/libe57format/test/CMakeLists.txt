cmake_minimum_required(VERSION 3.15)

project(e57-test CXX)

find_package(E57Format CONFIG REQUIRED)

add_executable(e57-test test.cpp)
target_link_libraries(e57-test E57Format)
