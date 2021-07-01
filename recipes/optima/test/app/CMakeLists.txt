cmake_minimum_required(VERSION 3.17)

project(app LANGUAGES CXX)

find_package(Optima REQUIRED)

add_executable(app main.cpp)

target_link_libraries(app Optima::Optima)
