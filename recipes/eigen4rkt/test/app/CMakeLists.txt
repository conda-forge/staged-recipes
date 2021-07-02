cmake_minimum_required(VERSION 3.0)

project(app LANGUAGES CXX)

find_package(Eigen3 REQUIRED)

add_executable(app main.cpp)

target_link_libraries(app Eigen3::Eigen)
