cmake_minimum_required(VERSION 3.4)

find_path(SDL_INCLUDE_DIRS
  NAMES "SDL.h"
  PATH_SUFFIXES SDL)

find_library(SDL_LIBRARIES
  NAMES "SDL")

file(
    GLOB SDL_IMAGE_SOURCES
    ${CMAKE_CURRENT_SOURCE_DIR}/*.c
)

add_library(SDL_image ${SDL_IMAGE_SOURCES})
target_include_directories(SDL_image PUBLIC ${CMAKE_CURRENT_SOURCE_DIR} ${SDL_INCLUDE_DIRS})
target_link_libraries(SDL_image ${SDL_LIBRARIES})

install(TARGETS SDL_image
  ARCHIVE DESTINATION lib
  LIBRARY DESTINATION lib
  RUNTIME DESTINATION bin
)

file(
    GLOB SDL_IMAGE_HEADERS
    ${CMAKE_CURRENT_SOURCE_DIR}/*.h
)

install(FILES ${SDL_IMAGE_HEADERS}
  DESTINATION include/SDL
)
