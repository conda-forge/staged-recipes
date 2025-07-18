
cmake_minimum_required(VERSION 3.18)

project(TestCompile LANGUAGES C)

# FIXME: REQUIRED check is broken when COMPONENTS are specified
find_package(nvcomp COMPONENTS nvcomp nvcomp_cpu nvcomp_device_static)

add_library(test test_load_elf.c)

target_link_libraries(test PRIVATE nvcomp::nvcomp nvcomp::nvcomp_cpu nvcomp::nvcomp_device_static)
