cmake_minimum_required(VERSION 3.16)

set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreadedDLL")

project(test-metatensor-torch CXX)

find_package(metatomic_torch)

add_executable(main main.cpp)
target_link_libraries(main metatomic_torch)

enable_testing()
add_test(NAME main COMMAND main)
