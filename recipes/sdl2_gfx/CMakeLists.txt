# Written by Daniel Schreij (dschreij@gmail.com) on 1 Nov 2016
# This procedure is configured to work in an Anaconda build environment (contiuum.io)
# In this environment, it should be called like 
# 
#    %LIBRARY_BIN%\cmake -G "NMake Makefiles" -DCMAKE_INSTALL_PREFIX:PATH="%LIBRARY_PREFIX%" ..
# 
# to be correctly configured
# 
# This file is intended to be used for Windows only!


set(PROJECT_NAME "SDL2_gfx")
project(${PROJECT_NAME})
CMAKE_MINIMUM_REQUIRED(VERSION 3.0.0)

set(IS_LIBRARY true)
set(CMAKE_INCLUDE_CURRENT_DIR TRUE)

include(GenerateExportHeader)
message(STATUS "Search prefix: ${CMAKE_PREFIX_PATH}")

FIND_PATH(SDL2_INCLUDE_DIR
    SDL.h
    PATH_SUFFIXES include/SDL2 include
)

FIND_LIBRARY(SDL2_LIBRARIES
    NAMES SDL2
    PATH_SUFFIXES lib64 lib lib/x64 lib/x86
)

message(STATUS "Include dir: ${SDL2_INCLUDE_DIR}")
message(STATUS "Library location: ${SDL2_LIBRARIES}")

set(SRCS
    SDL2_framerate.c
    SDL2_gfxPrimitives.c
    SDL2_imageFilter.c
    SDL2_rotozoom.c
)

include_directories(${SDL2_INCLUDE_DIR})

# Dynamic libraries
add_library(${PROJECT_NAME} SHARED ${SRCS})
set_target_properties(${PROJECT_NAME} PROPERTIES DEFINE_SYMBOL "DLL_EXPORT")
target_link_libraries(${PROJECT_NAME} ${SDL2_LIBRARIES})

##### Installation targets #####
install(TARGETS ${PROJECT_NAME}
  LIBRARY DESTINATION "lib${LIB_SUFFIX}"
  ARCHIVE DESTINATION "lib${LIB_SUFFIX}"
  RUNTIME DESTINATION bin)

file(GLOB INCLUDE_FILES ${CMAKE_CURRENT_SOURCE_DIR}/*.h)
install(FILES ${INCLUDE_FILES} DESTINATION include/SDL2)