cmake_minimum_required(VERSION 3.10)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

project(adaptivecpp-example)

find_package(AdaptiveCpp CONFIG REQUIRED)

if(WIN32)
  add_definitions(-D_USE_MATH_DEFINES)
endif()

add_executable(${PROJECT_NAME} main.cpp)
add_sycl_to_target(TARGET ${PROJECT_NAME} SOURCES main.cpp)
