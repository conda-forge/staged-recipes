cmake_minimum_required(VERSION 3.20)
project(fb303_test CXX)

set(CMAKE_CXX_STANDARD 20)

find_package(fb303 CONFIG REQUIRED)

add_executable(fb303_test main.cpp)
target_link_libraries(fb303_test PRIVATE fb303::fb303)
