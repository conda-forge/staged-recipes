cmake_minimum_required(VERSION 3.20)
project(mvfst_test CXX)

set(CMAKE_CXX_STANDARD 20)

find_package(mvfst CONFIG REQUIRED)

add_executable(mvfst_test main.cpp)
target_link_libraries(mvfst_test PRIVATE mvfst::mvfst)
