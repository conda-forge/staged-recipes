cmake_minimum_required(VERSION 3.18)
project(
   cime_gen_domain
   VERSION $ENV{PKG_VERSION}
   LANGUAGES Fortran)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)

include("${CMAKE_SOURCE_DIR}/cmake_macros/gnu.cmake")

find_package(NETCDF REQUIRED)

message(STATUS "netcdf_f_incdir=${netcdf_f_incdir}")
message(STATUS "netcdf_f_libs=${netcdf_f_libs}")

SET(SRC ${CMAKE_SOURCE_DIR}/tools/mapping/gen_domain_files/src)

include_directories(${netcdf_f_incdir})
add_definitions(-DLINUX)
add_executable(gen_domain ${SRC}/gen_domain.F90)
target_link_libraries(gen_domain ${netcdf_f_libs})

install(TARGETS gen_domain DESTINATION bin)
