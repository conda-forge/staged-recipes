cmake_minimum_required(VERSION 3.17)

project(app LANGUAGES CXX)

find_library(phreeqc4rkt REQUIRED)

add_executable(app main.cpp)

target_link_libraries(app phreeqc4rkt)
