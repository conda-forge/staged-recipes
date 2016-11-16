cmake_minimum_required(VERSION 3.3)
project(use-backward CXX)

find_package(Backward REQUIRED)

add_executable(main test_main.cpp)
target_link_libraries(main PUBLIC Backward::Backward)
