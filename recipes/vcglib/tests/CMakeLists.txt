cmake_minimum_required(VERSION 3.13)

project(vcglib_test)

find_package(vcglib CONFIG REQUIRED)
add_executable(${CMAKE_PROJECT_NAME} main.cpp)
target_link_libraries(${CMAKE_PROJECT_NAME} PRIVATE vcglib)
