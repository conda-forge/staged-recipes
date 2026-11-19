cmake_minimum_required(VERSION 3.16)
project(tigl_consumer CXX)

find_package(tigl3 CONFIG REQUIRED)

add_executable(tigl_consumer main.cpp)
target_link_libraries(tigl_consumer PRIVATE tigl3)
