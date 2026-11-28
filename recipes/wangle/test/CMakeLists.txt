cmake_minimum_required(VERSION 3.20)
project(wangle_test CXX)

set(CMAKE_CXX_STANDARD 20)

find_package(wangle CONFIG REQUIRED)

add_executable(wangle_test main.cpp)
target_link_libraries(wangle_test PRIVATE wangle::wangle)
