cmake_minimum_required(VERSION 3.15)
project(test_xad LANGUAGES CXX)

find_package(XAD REQUIRED CONFIG)

add_executable(test_xad test_xad.cpp)
target_link_libraries(test_xad PRIVATE XAD::xad)
