cmake_minimum_required(VERSION 2.8.10)
project(blosc_hdf5)

# find local blosc install
SET(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_CURRENT_SOURCE_DIR}/cmake/Modules")
find_package(blosc REQUIRED)

message("BLOSC lib: ${BLOSC_LIBRARY}")
message("BLOSC include: ${BLOSC_INCLUDE_DIRS}")

# TODO: set these paths for OSX and Windoze
set(PLUGIN_INSTALL_PATH "${CMAKE_INSTALL_PREFIX}/lib/hdf5/plugin" CACHE PATH
            "Where to install the dynamic HDF5-plugin")

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

# TODO: below block only needed for internal blosc build.
# add blosc libraries
add_library(blosc_shared SHARED IMPORTED)
#set_property(TARGET blosc_shared PROPERTY IMPORTED_LOCATION ${BLOSC_INSTALL_DIR}/lib/${CMAKE_SHARED_LIBRARY_PREFIX}blosc${CMAKE_SHARED_LIBRARY_SUFFIX})
#add_dependencies(blosc_shared project_blosc)
#include_directories(${BLOSC_INSTALL_DIR}/include)
###

add_library(blosc_filter_shared SHARED ${SOURCES})
set_target_properties(blosc_filter_shared PROPERTIES OUTPUT_NAME blosc_filter)
target_link_libraries(blosc_filter_shared
        ${BLOSC_LIBRARY}
        ${HDF5_LIBRARIES})

# install
install(TARGETS blosc_filter_shared DESTINATION ${PLUGIN_INSTALL_PATH} COMPONENT HDF5_FILTER_DEV)
