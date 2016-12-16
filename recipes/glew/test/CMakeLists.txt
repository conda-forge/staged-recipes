cmake_minimum_required(VERSION 3.3)
project(use-glew CXX)

find_package(GLEW REQUIRED)

add_executable(main main.cpp)
target_link_libraries(main PUBLIC GLEW::GLEW)