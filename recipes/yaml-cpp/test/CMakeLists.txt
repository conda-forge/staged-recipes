cmake_minimum_required(VERSION 3.0)

project(test LANGUAGES CXX)

find_package(yaml-cpp REQUIRED)

include_directories(${CMAKE_PREFIX_PATH}/lib)

add_executable(test main.cpp)

target_link_libraries(test yaml-cpp)
