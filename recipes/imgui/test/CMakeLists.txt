cmake_minimum_required(VERSION 3.15)

# The entire purpose of this project is to test a correct installation of
# imgui, by linking a simple executable against it.
project(ImguiTestConda)

find_package(imgui REQUIRED)

add_executable(TestExe test.cpp)
target_link_libraries(TestExe PUBLIC imgui::imgui)
