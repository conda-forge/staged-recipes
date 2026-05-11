include(FindPackageHandleStandardArgs)

if(NOT Filament_ROOT AND DEFINED ENV{PREFIX})
  set(Filament_ROOT "$ENV{PREFIX}")
endif()

set(_Filament_roots ${Filament_ROOT})
set(_Filament_library_path_suffixes lib lib/${CMAKE_SYSTEM_PROCESSOR})
set(_Filament_static_libraries
  filament
  backend
  bluegl
  bluevk
  filabridge
  filaflat
  smol-v
  utils
  zstd
)

find_path(Filament_INCLUDE_DIR
  NAMES filament/Engine.h
  PATHS ${_Filament_roots}
  PATH_SUFFIXES include
  NO_DEFAULT_PATH
)

set(Filament_LIBRARIES)
set(_Filament_required_vars Filament_INCLUDE_DIR)
foreach(_Filament_library_name IN LISTS _Filament_static_libraries)
  string(MAKE_C_IDENTIFIER "${_Filament_library_name}" _Filament_library_var)
  find_library(Filament_${_Filament_library_var}_LIBRARY
    NAMES "${_Filament_library_name}"
    PATHS ${_Filament_roots}
    PATH_SUFFIXES ${_Filament_library_path_suffixes}
    NO_DEFAULT_PATH
  )
  list(APPEND _Filament_required_vars Filament_${_Filament_library_var}_LIBRARY)
  list(APPEND Filament_LIBRARIES "${Filament_${_Filament_library_var}_LIBRARY}")
endforeach()

find_package_handle_standard_args(Filament
  REQUIRED_VARS ${_Filament_required_vars}
)

if(Filament_FOUND AND NOT TARGET Filament::filament)
  add_library(Filament::filament INTERFACE IMPORTED)
  target_include_directories(Filament::filament INTERFACE "${Filament_INCLUDE_DIR}")

  if(LINUX)
    find_package(Threads REQUIRED)
    find_library(Filament_GL_LIBRARY
      NAMES GL
      PATHS ${_Filament_roots}
      PATH_SUFFIXES lib
      NO_DEFAULT_PATH
      REQUIRED
    )
    find_library(Filament_EGL_LIBRARY
      NAMES EGL
      PATHS ${_Filament_roots}
      PATH_SUFFIXES lib
      NO_DEFAULT_PATH
      REQUIRED
    )
    target_link_libraries(Filament::filament INTERFACE
      -Wl,--start-group
      ${Filament_LIBRARIES}
      -Wl,--end-group
      Threads::Threads
      "${Filament_GL_LIBRARY}"
      "${Filament_EGL_LIBRARY}"
      dl
    )
  elseif(APPLE)
    find_library(Filament_COCOA_FRAMEWORK Cocoa REQUIRED)
    find_library(Filament_COREVIDEO_FRAMEWORK CoreVideo REQUIRED)
    find_library(Filament_FOUNDATION_FRAMEWORK Foundation REQUIRED)
    find_library(Filament_METAL_FRAMEWORK Metal REQUIRED)
    find_library(Filament_QUARTZCORE_FRAMEWORK QuartzCore REQUIRED)
    target_link_libraries(Filament::filament INTERFACE
      ${Filament_LIBRARIES}
      "${Filament_COCOA_FRAMEWORK}"
      "${Filament_COREVIDEO_FRAMEWORK}"
      "${Filament_FOUNDATION_FRAMEWORK}"
      "${Filament_METAL_FRAMEWORK}"
      "${Filament_QUARTZCORE_FRAMEWORK}"
    )
  else()
    target_link_libraries(Filament::filament INTERFACE ${Filament_LIBRARIES})
  endif()
endif()
