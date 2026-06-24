cmake_minimum_required(VERSION 3.16)
project(corrade_consumer LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

find_package(Corrade REQUIRED Utility)

add_executable(corrade_consumer main.cpp)
target_link_libraries(corrade_consumer PRIVATE Corrade::Utility)
