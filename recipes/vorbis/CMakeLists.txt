cmake_minimum_required (VERSION 3.1.0)
project (VORBIS)

FIND_PATH(OGG_INCLUDE_DIR
    ogg.h
    PATH_SUFFIXES include/ogg
)

FIND_LIBRARY(OGG_LIBRARIES
    NAMES ogg libogg
    PATH_SUFFIXES lib
)

message(STATUS Found ogg headers at ${OGG_INCLUDE_DIR})
message(STATUS Found ogg libs at ${OGG_LIBRARIES})

include_directories(OGG_INCLUDE_DIR)
include_directories("${VORBIS_SOURCE_DIR}/include")

#libvorbis

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY build)

set(VORBIS_SRC
    lib/analysis.c
    lib/bitrate.c
    lib/block.c
    lib/codebook.c
    lib/envelope.c
    lib/floor0.c
    lib/floor1.c
    lib/info.c
    lib/lookup.c
    lib/lpc.c
    lib/lsp.c
    lib/mapping0.c
    lib/mdct.c
    lib/psy.c
    lib/registry.c
    lib/res0.c
    lib/sharedbook.c
    lib/smallft.c
    lib/synthesis.c
    lib/vorbisenc.c
    lib/window.c
)

add_library(VORBIS SHARED
	${VORBIS_SRC}
)

target_link_libraries (VORBIS
	${OGG_LIBRARIES}
)

if(WIN32)
	if(MSVC)
		configure_file(	${CMAKE_CURRENT_SOURCE_DIR}/win32/vorbis.def ${CMAKE_CURRENT_BINARY_DIR}/win32/vorbis.def @ONLY)
		set_target_properties(VORBIS PROPERTIES LINK_FLAGS "/DEF:win32/vorbis.def")
	endif()
endif()

set_target_properties(VORBIS 
	PROPERTIES DEFINE_SYMBOL "DLL_EXPORT"
)
set_target_properties(VORBIS
	PROPERTIES PREFIX "" OUTPUT_NAME "libvorbis"
)

#libvorbisfile

set(VORBIS_FILE_SRC
	lib/vorbisfile.c
)

add_library(VORBIS_FILE SHARED
	${VORBIS_FILE_SRC}
)

target_link_libraries (VORBIS_FILE
	VORBIS
	${OGG_LIBRARIES}
)

if(WIN32)
	if(MSVC)
		configure_file(	${CMAKE_CURRENT_SOURCE_DIR}/win32/vorbisfile.def ${CMAKE_CURRENT_BINARY_DIR}/win32/vorbisfile.def @ONLY)
		set_target_properties(VORBIS_FILE PROPERTIES LINK_FLAGS "/DEF:win32/vorbisfile.def")
	endif()
endif()

set_target_properties(VORBIS_FILE 
	PROPERTIES DEFINE_SYMBOL "DLL_EXPORT"
)
set_target_properties(VORBIS_FILE
	PROPERTIES PREFIX "" OUTPUT_NAME "libvorbisfile"
)

##### Installation targets #####
install(TARGETS VORBIS VORBIS_FILE
  LIBRARY DESTINATION "lib${LIB_SUFFIX}"
  ARCHIVE DESTINATION "lib${LIB_SUFFIX}"
  RUNTIME DESTINATION bin)

file(GLOB INCLUDE_FILES ${CMAKE_CURRENT_SOURCE_DIR}/*.h)
# Copy .h files to include dir.
install(DIRECTORY ${VORBIS_SOURCE_DIR}/include/vorbis DESTINATION include
	FILES_MATCHING PATTERN "*.h")