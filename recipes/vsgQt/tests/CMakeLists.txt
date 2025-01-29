cmake_minimum_required(VERSION 3.7)

project(vsgqtviewer)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

find_package(Qt5 COMPONENTS Widgets REQUIRED)
find_package(vsgQt CONFIG REQUIRED)
find_package(vsgXchange CONFIG REQUIRED)

add_executable(vsgqtviewer main.cpp)
target_link_libraries(vsgqtviewer PRIVATE vsgQt::vsgQt vsgXchange::vsgXchange)
