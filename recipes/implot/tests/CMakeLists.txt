cmake_minimum_required(VERSION 3.7)

project(implot_test)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

find_package(imgui CONFIG REQUIRED)
find_package(implot CONFIG REQUIRED)

add_executable(implot_test main.cpp)
target_link_libraries(implot_test PRIVATE imgui::imgui implot::implot)
