cmake_minimum_required(VERSION 3.7)

project(vsghelloworld)

find_package(vsg CONFIG REQUIRED)
find_package(vsgXchange CONFIG REQUIRED)

add_executable(vsghelloworld vsghelloworld.cpp)
target_link_libraries(vsghelloworld PRIVATE vsg::vsg vsgXchange::vsgXchange)
