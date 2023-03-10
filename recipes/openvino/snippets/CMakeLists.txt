cmake_minimum_required(VERSION 3.13 FATAL_ERROR)

project(openvino_cmake_conda_build)

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED TRUE)

find_package(OpenVINO REQUIRED)

message(STATUS "OpenVINO library status:")
message(STATUS "    config: ${OpenVINO_DIR}")
message(STATUS "    version: ${OpenVINO_VERSION}")

set(TARGET_NAME openvino_frontends_test)
add_executable(${TARGET_NAME} openvino_available_frontends.cpp)
target_link_libraries(${TARGET_NAME} PRIVATE openvino::runtime)
