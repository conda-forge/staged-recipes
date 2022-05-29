cmake_minimum_required(VERSION 3.23)

project(lodepng)

add_library(lodepng lodepng.cpp)

target_include_directories(lodepng PUBLIC
  $<INSTALL_INTERFACE:include>
)

set(LODEPNG_CMAKE_INSTALL_DIR lib/cmake/lodepng)

file(WRITE "${CMAKE_BINARY_DIR}/lodepng-config.cmake" 
           "include(\"\${CMAKE_CURRENT_LIST_DIR}/lodepng-targets.cmake\")")
install(FILES "${CMAKE_BINARY_DIR}/lodepng-config.cmake" 
        DESTINATION ${LODEPNG_CMAKE_INSTALL_DIR})

install(TARGETS lodepng 
        EXPORT lodepng-targets)

install(EXPORT lodepng-targets 
        DESTINATION ${LODEPNG_CMAKE_INSTALL_DIR})
