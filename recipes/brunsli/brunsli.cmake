# Copyright (c) Google LLC 2019
#
# Use of this source code is governed by an MIT-style
# license that can be found in the LICENSE file or at
# https://opensource.org/licenses/MIT.


file(GLOB BRUNSLI_COMMON_SOURCES
  c/common/*.cc
)

# TODO(eustas): split public/private headers.
file(GLOB BRUNSLI_COMMON_HEADERS
  c/common/*.h
)

set(BRUNSLI_DEC_SOURCES
  c/dec/ans_decode.cc
  c/dec/brunsli_decode.cc
  c/dec/context_map_decode.cc
  c/dec/histogram_decode.cc
  c/dec/huffman_decode.cc
  c/dec/huffman_table.cc
  c/dec/jpeg_data_writer.cc
)

# TODO(eustas): split public/private headers.
file(GLOB BRUNSLI_DEC_HEADERS
  c/dec/*.h
)

set(BRUNSLI_ENC_SOURCES
  c/enc/ans_encode.cc
  c/enc/brunsli_encode.cc
  c/enc/context_map_encode.cc
  c/enc/histogram_encode.cc
  c/enc/jpeg_data_reader.cc
  c/enc/jpeg_huffman_decode.cc
  c/enc/write_bits.cc
)

# TODO(eustas): split public/private headers.
file(GLOB BRUNSLI_ENC_HEADERS
  c/enc/*.h
)

set(BRUNSLI_INCLUDE_DIRS "${CMAKE_CURRENT_SOURCE_DIR}/c/include")
mark_as_advanced(BRUNSLI_INCLUDE_DIRS)

add_library(brunslicommon
  ${BRUNSLI_COMMON_SOURCES}
  ${BRUNSLI_COMMON_HEADERS}
)

add_library(brunslidec
  ${BRUNSLI_DEC_SOURCES}
  ${BRUNSLI_DEC_HEADERS}
)
target_link_libraries(brunslidec
  brotlidec
  brotlicommon
  brunslicommon
)

add_library(brunslienc
  ${BRUNSLI_ENC_SOURCES}
  ${BRUNSLI_ENC_HEADERS}
)
target_link_libraries(brunslienc
  brotlienc
  brotlicommon
  brunslicommon
)

set(BRUNSLI_LIBRARIES brunslicommon brunslidec brunslienc)

if(NOT BRUNSLI_EMSCRIPTEN)
add_library(brunslidec-c SHARED
  c/dec/decode.cc
)
target_link_libraries(brunslidec-c brunslidec)
add_library(brunslienc-c SHARED
  c/enc/encode.cc
)
target_link_libraries(brunslidec-c
  brotlidec
  brotlicommon
)

target_link_libraries(brunslienc-c brunslienc)
target_link_libraries(brunslienc-c
  brotlienc
  brotlicommon
)
list(APPEND BRUNSLI_LIBRARIES brunslidec-c brunslienc-c)
endif()  # BRUNSLI_EMSCRIPTEN

foreach(lib IN LISTS BRUNSLI_LIBRARIES)
  target_include_directories(${lib} PUBLIC
    "${CMAKE_CURRENT_SOURCE_DIR}/c/include"
    "${CMAKE_CURRENT_SOURCE_DIR}"
  )
  if(NOT BRUNSLI_EMSCRIPTEN)
    set_property(TARGET ${lib} PROPERTY POSITION_INDEPENDENT_CODE ON)
  endif()
endforeach()

if(NOT BRUNSLI_EMSCRIPTEN)
add_executable(cbrunsli c/tools/cbrunsli.cc)
target_link_libraries(cbrunsli
  brunslienc
  brotlienc
  brotlicommon
)
add_executable(dbrunsli c/tools/dbrunsli.cc)
target_link_libraries(dbrunsli
  brunslidec
  brotlidec
  brotlicommon
)
else()  # BRUNSLI_EMSCRIPTEN
set(WASM_MODULES brunslicodec-wasm brunslidec-wasm brunslienc-wasm)
foreach(module IN LISTS WASM_MODULES)
add_executable(${module} wasm/codec.cc)
target_link_libraries(${module} brunslidec brunslienc)
endforeach()
set(WASM_LINK_FLAGS "-O3 --closure 1 -s ALLOW_MEMORY_GROWTH=1 -s MODULARIZE=1")
set(WASM_COMMON_EXPORT "\"_malloc\",\"_free\"")
set(WASM_DEC_EXPORT "\"_BrunsliToJpeg\",\"_GetJpegData\",\"_GetJpegLength\",\"_FreeJpeg\"")
set(WASM_ENC_EXPORT "\"_JpegToBrunsli\",\"_GetBrunsliData\",\"_GetBrunsliLength\",\"_FreeBrunsli\"")
set_target_properties(brunslicodec-wasm PROPERTIES LINK_FLAGS "\
  ${WASM_LINK_FLAGS}\
  -s EXPORT_NAME=\"BrunsliCodecModule\"\
  -s EXPORTED_FUNCTIONS='[${WASM_COMMON_EXPORT},${WASM_DEC_EXPORT},${WASM_ENC_EXPORT}]'\
")
set_target_properties(brunslidec-wasm PROPERTIES LINK_FLAGS "\
  ${WASM_LINK_FLAGS}\
  -s EXPORT_NAME=\"BrunsliDecModule\"\
  -s EXPORTED_FUNCTIONS='[${WASM_COMMON_EXPORT},${WASM_DEC_EXPORT}]'\
")
set_target_properties(brunslienc-wasm PROPERTIES LINK_FLAGS "\
  ${WASM_LINK_FLAGS}\
  -s EXPORT_NAME=\"BrunsliEncModule\"\
  -s EXPORTED_FUNCTIONS='[${WASM_COMMON_EXPORT},${WASM_ENC_EXPORT}]'\
")
endif()  # BRUNSLI_EMSCRIPTEN

# Installation
if(NOT BRUNSLI_EMSCRIPTEN)
  install(
    TARGETS brunslidec-c
    RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}"
    ARCHIVE DESTINATION "${CMAKE_INSTALL_LIBDIR}"
    LIBRARY DESTINATION "${CMAKE_INSTALL_LIBDIR}"
  )

  install(
    TARGETS brunslienc-c
    RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}"
    ARCHIVE DESTINATION "${CMAKE_INSTALL_LIBDIR}"
    LIBRARY DESTINATION "${CMAKE_INSTALL_LIBDIR}"
  )

  install(
    TARGETS cbrunsli dbrunsli
    RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}"
  )

  install(
    DIRECTORY ${BRUNSLI_INCLUDE_DIRS}/brunsli
    DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}"
  )
endif() # BRUNSLI_EMSCRIPTEN
