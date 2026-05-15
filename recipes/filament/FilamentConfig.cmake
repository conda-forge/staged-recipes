get_filename_component(PACKAGE_PREFIX_DIR "${CMAKE_CURRENT_LIST_DIR}/../../.." ABSOLUTE)

if(APPLE)
  set(_filament_library "${PACKAGE_PREFIX_DIR}/lib/libfilament.1.dylib")
else()
  set(_filament_library "${PACKAGE_PREFIX_DIR}/lib/libfilament.so.1")
endif()

if(NOT EXISTS "${_filament_library}")
  set(Filament_FOUND FALSE)
  set(Filament_NOT_FOUND_MESSAGE "Missing Filament shared library: ${_filament_library}")
  return()
endif()

if(NOT TARGET Filament::filament)
  add_library(Filament::filament SHARED IMPORTED)
  set_target_properties(Filament::filament PROPERTIES
    IMPORTED_LOCATION "${_filament_library}"
    INTERFACE_INCLUDE_DIRECTORIES "${PACKAGE_PREFIX_DIR}/include"
  )
endif()

if(NOT TARGET Filament::matc)
  add_executable(Filament::matc IMPORTED)
  set_target_properties(Filament::matc PROPERTIES
    IMPORTED_LOCATION "${PACKAGE_PREFIX_DIR}/bin/matc"
  )
endif()
