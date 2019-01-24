cmake_minimum_required(VERSION 2.8.10)
project(blosc_hdf5)

SET(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_CURRENT_SOURCE_DIR}/cmake/Modules")

# sources
set(SOURCES blosc_filter.c blosc_plugin.c)

# dependencies
if(MSVC)
    # FindHDF5.cmake does not find Windows installations. Try to
    # use an environment variable instead until the official "find"
    # file can be updated for Windows.
    #
    # Note that you have to set this environment variable by hand.
    file(TO_CMAKE_PATH "$ENV{HDF5_DIR}" HDF5_HINT)
    set(HDF5_DIR ${HDF5_HINT} CACHE STRING "Path to HDF5 CMake config directory.")
    find_package(HDF5 REQUIRED HINTS ${HDF5_DIR})
else(MSVC)
    find_package(HDF5 REQUIRED)
endif(MSVC)
include_directories(${HDF5_INCLUDE_DIRS})

find_package(blosc REQUIRED)

add_library(blosc_filter_shared SHARED ${SOURCES})
set_target_properties(
  blosc_filter_shared PROPERTIES OUTPUT_NAME blosc_filter)
target_link_libraries(blosc_filter_shared ${BLOSC_LIBRARIES} ${HDF5_LIBRARIES})

# install
install(FILES blosc_filter.h DESTINATION include COMPONENT HDF5_FILTER_DEV)
install(TARGETS blosc_filter_shared DESTINATION lib COMPONENT HDF5_FILTER_DEV)


