cmake_minimum_required(VERSION 3.14)
project(immer_smoke LANGUAGES CXX)

find_package(Immer 0.9.1 EXACT CONFIG REQUIRED)
add_executable(immer-smoke smoke.cpp)
target_compile_features(immer-smoke PRIVATE cxx_std_14)
target_link_libraries(immer-smoke PRIVATE immer)
