cmake_minimum_required(VERSION 3.18)
project(
   e3sm-tools
   VERSION $ENV{PKG_VERSION}
   LANGUAGES C Fortran)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)

include("${CMAKE_SOURCE_DIR}/cmake_macros/gnu.cmake")

find_package(NETCDF REQUIRED)

message(STATUS "netcdf_f_incdir=${netcdf_f_incdir}")
message(STATUS "netcdf_f_libs=${netcdf_f_libs}")

add_subdirectory(${CMAKE_SOURCE_DIR}/tools/cube_to_target cube_to_target)
add_subdirectory(${CMAKE_SOURCE_DIR}/tools/interpinic interpinic)
add_subdirectory(${CMAKE_SOURCE_DIR}/tools/mksurfdata_map mksurfdata_map)
