cmake_minimum_required (VERSION 3.1.0)
# enable_language(ASM-NASM)

project (OGG)

include(CheckLibraryExists)
include(CheckIncludeFiles)
include(CheckIncludeFile)

set(OGG_SRC
	src/bitwise.c
	src/framing.c
)

set(OGG_SOURCES "${OGG_SRC}")

include_directories("${OGG_SOURCE_DIR}/include")

add_library(OGG SHARED ${OGG_SOURCES})

if(WIN32)
	if(MSVC)
		configure_file(	${CMAKE_CURRENT_SOURCE_DIR}/win32/ogg.def ${CMAKE_CURRENT_BINARY_DIR}/win32/ogg.def @ONLY)
		set_target_properties(OGG PROPERTIES LINK_FLAGS "/DEF:win32/ogg.def")
	endif()
endif()

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY build)
set_target_properties(OGG PROPERTIES PREFIX "" OUTPUT_NAME "libogg")
set_target_properties(OGG PROPERTIES DEFINE_SYMBOL "DLL_EXPORT")

##### Installation targets #####
install(TARGETS OGG
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
  RUNTIME DESTINATION bin)

# Copy .h files to include dir.
install(DIRECTORY ${OGG_SOURCE_DIR}/include/ogg DESTINATION include
	FILES_MATCHING PATTERN "*.h")
