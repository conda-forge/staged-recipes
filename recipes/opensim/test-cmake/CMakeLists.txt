cmake_minimum_required(VERSION 3.15)
project(opensim_consumer LANGUAGES CXX)

find_package(OpenSim CONFIG REQUIRED)

add_executable(opensim_consumer main.cpp)
target_compile_features(opensim_consumer PRIVATE cxx_std_17)
target_link_libraries(opensim_consumer PRIVATE ${OpenSim_LIBRARIES})
