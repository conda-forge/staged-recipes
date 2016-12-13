cmake_minimum_required (VERSION 3.1.0)

project (SMPEG)

include(CheckLibraryExists)
include(CheckIncludeFiles)
include(CheckIncludeFile)

set(CMAKE_MODULE_PATH "${SMPEG_SOURCE_DIR}/cmake")

FIND_PATH(SDL2_INCLUDE_DIR
    SDL.h
    PATH_SUFFIXES include/SDL2 include
)

FIND_LIBRARY(SDL2_LIBRARIES
    NAMES SDL2
    PATH_SUFFIXES lib64 lib lib/x64 lib/x86
)

include_directories(${SDL2_INCLUDE_DIR})

set(SMPEG_AUDIO_SRC
    audio/MPEGaudio.cpp
    audio/bitwindow.cpp
    audio/filter.cpp
    audio/filter_2.cpp
    audio/hufftable.cpp
    audio/mpeglayer1.cpp
    audio/mpeglayer2.cpp
    audio/mpeglayer3.cpp
    audio/mpegtable.cpp
    audio/mpegtoraw.cpp
)

set(SMPEG_VIDEO_SRC
    video/MPEGvideo.cpp
    video/decoders.cpp
    video/floatdct.cpp
    video/gdith.cpp
    video/jrevdct.cpp
    video/motionvec.cpp
    video/parseblock.cpp
    video/readfile.cpp
    video/util.cpp
    video/video.cpp
)

set(SMPEG_SRC
    MPEG.cpp
    MPEGlist.cpp
    MPEGring.cpp
    MPEGstream.cpp
    MPEGsystem.cpp
    smpeg.cpp
)

set(PLAYMPEG_SOURCES
    plaympeg.c
)

set(SMPEG_SOURCES
    ${SMPEG_SRC}
    ${SMPEG_AUDIO_SRC}
    ${SMPEG_VIDEO_SRC}
)

set(SMPEG_CONTROLS OFF CACHE BOOL "Embeed media player controls")

if(NOT SMPEG_CONTROLS)
    add_definitions(-DNOCONTROLS)
endif()

include_directories("${SMPEG_SOURCE_DIR}")

add_library(SMPEG SHARED
    ${SMPEG_SOURCES}
)

set_target_properties(SMPEG
    PROPERTIES
    ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib"
    LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib"
    RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin"
)

target_link_libraries(SMPEG
    ${SDL2_LIBRARIES}
)

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY build)
set_target_properties(SMPEG
    PROPERTIES PREFIX "" OUTPUT_NAME "smpeg2"
)
set_target_properties(SMPEG PROPERTIES DEFINE_SYMBOL "DLL_EXPORT")

##### Installation targets #####
install(TARGETS SMPEG # plaympeg
  LIBRARY DESTINATION "lib${LIB_SUFFIX}"
  ARCHIVE DESTINATION "lib${LIB_SUFFIX}"
  RUNTIME DESTINATION bin)

# Copy .h files to include dir.
file(GLOB SMPEG_INCLUDE_FILES ${SMPEG_SOURCE_DIR}/*.h)
install(FILES ${SMPEG_INCLUDE_FILES} DESTINATION include/smpeg2)
