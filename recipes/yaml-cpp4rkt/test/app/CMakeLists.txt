cmake_minimum_required(VERSION 3.0)

project(app LANGUAGES CXX)

find_package(yaml-cpp REQUIRED PATHS ${CMAKE_PREFIX_PATH}/lib)

include_directories(${CMAKE_PREFIX_PATH}/include)
link_directories(${CMAKE_PREFIX_PATH}/lib)

add_executable(app main.cpp)

target_link_libraries(app yaml-cpp)
