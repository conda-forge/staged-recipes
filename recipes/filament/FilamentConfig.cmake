get_filename_component(PACKAGE_PREFIX_DIR "${CMAKE_CURRENT_LIST_DIR}/../../.." ABSOLUTE)

if(APPLE)
  set(_filament_shared_suffix "dylib")
else()
  set(_filament_shared_suffix "so")
endif()

set(Filament_FOUND TRUE)

function(_filament_import_library target_name library_name)
  set(_filament_library "${PACKAGE_PREFIX_DIR}/lib/lib${library_name}.${_filament_shared_suffix}")

  if(NOT EXISTS "${_filament_library}")
    set(Filament_FOUND FALSE PARENT_SCOPE)
    set(Filament_NOT_FOUND_MESSAGE "Missing Filament shared library: ${_filament_library}" PARENT_SCOPE)
    return()
  endif()

  if(NOT TARGET Filament::${target_name})
    add_library(Filament::${target_name} SHARED IMPORTED)
    set_target_properties(Filament::${target_name} PROPERTIES
      IMPORTED_LOCATION "${_filament_library}"
      INTERFACE_INCLUDE_DIRECTORIES "${PACKAGE_PREFIX_DIR}/include"
    )
  endif()
endfunction()

_filament_import_library(bluegl bluegl)
_filament_import_library(bluevk bluevk)
_filament_import_library(utils utils)
_filament_import_library(filabridge filabridge)
_filament_import_library(filaflat filaflat)
_filament_import_library(backend backend)
_filament_import_library(geometry geometry)
_filament_import_library(filament filament)

if(Filament_FOUND)
  set_target_properties(Filament::bluevk PROPERTIES
    INTERFACE_LINK_LIBRARIES "Filament::utils"
  )
  set_target_properties(Filament::filabridge PROPERTIES
    INTERFACE_LINK_LIBRARIES "Filament::utils"
  )
  set_target_properties(Filament::filaflat PROPERTIES
    INTERFACE_LINK_LIBRARIES "Filament::filabridge;Filament::utils"
  )
  set_target_properties(Filament::backend PROPERTIES
    INTERFACE_LINK_LIBRARIES "Filament::bluegl;Filament::bluevk;Filament::utils"
  )
  set_target_properties(Filament::geometry PROPERTIES
    INTERFACE_LINK_LIBRARIES "Filament::utils"
  )
  set_target_properties(Filament::filament PROPERTIES
    INTERFACE_LINK_LIBRARIES "Filament::backend;Filament::filaflat;Filament::filabridge;Filament::utils"
  )
endif()

if(NOT TARGET Filament::matc)
  add_executable(Filament::matc IMPORTED)
  set_target_properties(Filament::matc PROPERTIES
    IMPORTED_LOCATION "${PACKAGE_PREFIX_DIR}/bin/matc"
  )
endif()
