cmake_minimum_required(VERSION 3.24)

project(asmjit_smoke LANGUAGES CXX)

find_package(asmjit REQUIRED CONFIG)

add_executable(asmjit-smoke test.cpp)
target_compile_features(asmjit-smoke PRIVATE cxx_std_17)
target_link_libraries(asmjit-smoke PRIVATE asmjit::asmjit)
