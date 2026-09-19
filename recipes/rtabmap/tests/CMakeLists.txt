cmake_minimum_required(VERSION 3.14)
project(rtabmap_consumer LANGUAGES CXX)

find_package(RTABMap 0.23.8 CONFIG REQUIRED COMPONENTS core gui)

add_executable(rtabmap_core_consumer core.cpp)
target_link_libraries(rtabmap_core_consumer PRIVATE rtabmap::core)

add_executable(rtabmap_gui_consumer gui.cpp)
target_link_libraries(rtabmap_gui_consumer PRIVATE rtabmap::gui)

enable_testing()
add_test(NAME rtabmap_core_consumer COMMAND rtabmap_core_consumer)
add_test(NAME rtabmap_gui_consumer COMMAND rtabmap_gui_consumer)
