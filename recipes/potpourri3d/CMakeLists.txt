cmake_minimum_required(VERSION 3.1.0)
project(potpourri3d_bindings)

find_package(pybind11 REQUIRED)

# for geometry-central
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

pybind11_add_module(potpourri3d_bindings
  src/cpp/core.cpp
  src/cpp/io.cpp
  src/cpp/mesh.cpp
  src/cpp/point_cloud.cpp
)

include_directories(potpourri3d_bindings ${CMAKE_CURRENT_SOURCE_DIR}/src/cpp)

find_package(Eigen3 REQUIRED)
target_link_libraries(potpourri3d_bindings PRIVATE Eigen3::Eigen)
target_link_libraries(potpourri3d_bindings PRIVATE geometry-central)