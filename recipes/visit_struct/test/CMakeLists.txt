cmake_minimum_required(VERSION 3.12)

project(visit_struct_example)

find_package(visit_struct REQUIRED)

add_executable(visit_struct_example visit_struct_example.cpp)

target_link_libraries(visit_struct_example PRIVATE visit_struct::visit_struct)
