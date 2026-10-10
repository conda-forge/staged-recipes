cmake_minimum_required(VERSION 3.24)
project(materialx_consumer CXX)

find_package(MaterialX REQUIRED)

add_executable(load_stdlib load_stdlib.cpp)
target_link_libraries(load_stdlib PRIVATE MaterialXCore MaterialXFormat MaterialXGenGlsl)
target_compile_features(load_stdlib PRIVATE cxx_std_17)
