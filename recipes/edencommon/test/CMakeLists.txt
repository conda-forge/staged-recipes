cmake_minimum_required(VERSION 3.20)
project(edencommon_test CXX)

set(CMAKE_CXX_STANDARD 20)

find_package(edencommon CONFIG REQUIRED)

add_executable(edencommon_test main.cpp)
target_link_libraries(edencommon_test PRIVATE edencommon::edencommon_utils)
