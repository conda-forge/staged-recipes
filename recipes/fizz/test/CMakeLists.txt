cmake_minimum_required(VERSION 3.20)
project(fizz_test CXX)

set(CMAKE_CXX_STANDARD 20)

find_package(fizz CONFIG REQUIRED)

add_executable(fizz_test main.cpp)
target_link_libraries(fizz_test PRIVATE fizz::fizz)
