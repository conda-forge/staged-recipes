cmake_minimum_required(VERSION 3.4)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR}/cmake_modules)

find_package(SDL REQUIRED)
find_package(ZLIB REQUIRED)
find_package(JPEG REQUIRED)
find_package(PNG REQUIRED)
find_package(TIFF REQUIRED)

set(WebP_NAMES libwebp)
find_package(WebP REQUIRED)

file(
    GLOB SDL_IMAGE_SOURCES
    ${CMAKE_CURRENT_SOURCE_DIR}/*.c
)

add_library(SDL_image ${SDL_IMAGE_SOURCES})
target_include_directories(SDL_image PUBLIC ${CMAKE_CURRENT_SOURCE_DIR} ${SDL_INCLUDE_DIR})
target_link_libraries(SDL_image
  ${SDL_LIBRARY}
  ZLIB::ZLIB
  JPEG::JPEG
  PNG::PNG
  TIFF::TIFF
  WebP::libwebp
)
target_compile_definitions(
  SDL_image PRIVATE
  LOAD_BMP
  LOAD_GIF
  LOAD_JPG
  LOAD_LBM
  LOAD_PCX
  LOAD_PNG
  LOAD_PNM
  LOAD_TGA
  LOAD_TIF
  LOAD_WEBP
  LOAD_XPM
  LOAD_XV
  PNG_USE_DLL
  ZLIB_DLL
  _CRT_SECURE_NO_WARNINGS
)

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
