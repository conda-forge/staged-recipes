
cmake_minimum_required(VERSION 3.18)

project(TestCompile LANGUAGES C)

# FIXME: REQUIRED check is broken when COMPONENTS are specified
find_package(nvcomp COMPONENTS nvcomp_static nvcomp_cpu_static nvcomp_device_static)

add_library(test test_load_elf.c)

target_link_libraries(test PRIVATE nvcomp::nvcomp_static nvcomp::nvcomp_cpu_static nvcomp::nvcomp_device_static)
