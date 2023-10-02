cmake_minimum_required(VERSION 3.8)
project(sample)
find_package(Einsums REQUIRED)
include(CMakePrintHelpers)
cmake_print_properties(
  TARGETS
    Einsums::einsums
    HDF5::HDF5
    tgt::lapack
    OpenMP::OpenMP_CXX
  PROPERTIES
    IMPORTED_LINK_DEPENDENT_LIBRARIES
    INTERFACE_LOCATION
    INTERFACE_LINK_LIBRARIES
    INTERFACE_INCLUDE_DIRECTORIES
    INTERFACE_COMPILE_DEFINITIONS
    INTERFACE_COMPILE_OPTIONS
    INTERFACE_SYSTEM_INCLUDE_DIRECTORIES
  )
add_executable(timings "main.cpp")
target_link_libraries(timings Einsums::einsums)

