cmake_minimum_required(VERSION 3.16)
project(basisu_consumer LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

find_package(basisu REQUIRED)

add_executable(basisu_consumer main.cpp)
target_link_libraries(basisu_consumer PRIVATE BasisUniversal::Transcoder)
