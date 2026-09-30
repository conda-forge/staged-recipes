cmake_minimum_required(VERSION 3.22)
project(dawn_test LANGUAGES C CXX)

find_package(Dawn CONFIG REQUIRED)

add_executable(dawn_test main.c)
target_link_libraries(dawn_test PRIVATE dawn::webgpu_dawn)
