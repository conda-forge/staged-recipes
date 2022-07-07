# cmake/FindRingDecomposerLib.cmake
if(NOT TARGET "RingDecomposerLib")
  find_package("RingDecomposerLib" CONFIG)
endif()

if(NOT TARGET "RingDecomposerLib")
  find_library(RingDecomposerLib_LIBRARY "RingDecomposerLib")
  find_path(RingDecomposerLib_HEADER "include/RingDecomposerLib.h")
  get_filename_component(RingDecomposerLib_INCLUDE_DIR "${RingDecomposerLib_HEADER}" DIRECTORY)

  add_library("RingDecomposerLib" INTERFACE IMPORTED)
  target_include_directories(
    "RingDecomposerLib"
    INTERFACE
    "${RingDecomposerLib_INCLUDE_DIR}"
  )
  target_link_libraries(
    "RingDecomposerLib"
    INTERFACE
    "${RingDecomposerLib_LIBRARY}"
  )
endif()
