# cmake/Findnauty.cmake
if(NOT TARGET "nauty")
  find_package("nauty" CONFIG)
endif()

if(NOT TARGET "nauty")
  find_library(NAUTY_LIBRARY "nauty")
  find_path(NAUTY_INCLUDE_DIR "include/nauty")

  add_library("nauty" INTERFACE IMPORTED)
  target_include_directories(
    "nauty"
    INTERFACE
    "${NAUTY_INCLUDE_DIR}"
  )
  target_link_libraries(
    "nauty"
    INTERFACE
    "${NAUTY_LIBRARY}"
  )
endif()
