include(CMakeFindDependencyMacro)

get_filename_component(PACKAGE_PREFIX_DIR "${CMAKE_CURRENT_LIST_DIR}/../../.." ABSOLUTE)

find_dependency(Threads)
find_dependency(zstd CONFIG REQUIRED)

set(_filament_zstd_target)
foreach(_filament_zstd_candidate IN ITEMS
    zstd::libzstd
    zstd::libzstd_shared
    zstd::libzstd_static
    zstd)
  if(TARGET "${_filament_zstd_candidate}")
    set(_filament_zstd_target "${_filament_zstd_candidate}")
    break()
  endif()
endforeach()

if(NOT _filament_zstd_target)
  set(Filament_FOUND FALSE)
  set(Filament_NOT_FOUND_MESSAGE "zstd CMake package did not define a known zstd target")
  return()
endif()

set(_filament_platform_libraries)
if(APPLE)
  find_library(_filament_cocoa_framework Cocoa REQUIRED)
  find_library(_filament_corevideo_framework CoreVideo REQUIRED)
  find_library(_filament_foundation_framework Foundation REQUIRED)
  find_library(_filament_metal_framework Metal REQUIRED)
  find_library(_filament_quartzcore_framework QuartzCore REQUIRED)
  list(APPEND _filament_platform_libraries
    "${_filament_cocoa_framework}"
    "${_filament_corevideo_framework}"
    "${_filament_foundation_framework}"
    "${_filament_metal_framework}"
    "${_filament_quartzcore_framework}"
  )
else()
  set(OpenGL_GL_PREFERENCE LEGACY)
  find_dependency(OpenGL REQUIRED COMPONENTS EGL)
  list(APPEND _filament_platform_libraries OpenGL::GL OpenGL::EGL ${CMAKE_DL_LIBS})
endif()

set(_filament_archive_targets)
foreach(_filament_library IN ITEMS
    filament
    backend
    bluegl
    bluevk
    filabridge
    filaflat
    geometry
    shaders
    smol-v
    utils)
  string(MAKE_C_IDENTIFIER "${_filament_library}" _filament_target_suffix)
  set(_filament_archive_path "${PACKAGE_PREFIX_DIR}/lib/lib${_filament_library}.a")
  if(NOT EXISTS "${_filament_archive_path}")
    set(Filament_FOUND FALSE)
    set(Filament_NOT_FOUND_MESSAGE "Missing Filament static archive: ${_filament_archive_path}")
    return()
  endif()
  set(_filament_archive_target "Filament::${_filament_target_suffix}_archive")
  if(NOT TARGET "${_filament_archive_target}")
    add_library("${_filament_archive_target}" STATIC IMPORTED)
    set_target_properties("${_filament_archive_target}" PROPERTIES
      IMPORTED_LOCATION "${_filament_archive_path}"
    )
  endif()
  list(APPEND _filament_archive_targets "${_filament_archive_target}")
endforeach()

if(NOT TARGET Filament::filament)
  add_library(Filament::filament INTERFACE IMPORTED)
  target_include_directories(Filament::filament INTERFACE "${PACKAGE_PREFIX_DIR}/include")
  if(APPLE)
    target_link_libraries(Filament::filament INTERFACE
      ${_filament_archive_targets}
      "${_filament_zstd_target}"
      Threads::Threads
      ${_filament_platform_libraries}
    )
  else()
    target_link_libraries(Filament::filament INTERFACE
      -Wl,--start-group
      ${_filament_archive_targets}
      -Wl,--end-group
      "${_filament_zstd_target}"
      Threads::Threads
      ${_filament_platform_libraries}
    )
  endif()
endif()

if(NOT TARGET Filament::matc)
  add_executable(Filament::matc IMPORTED)
  set_target_properties(Filament::matc PROPERTIES
    IMPORTED_LOCATION "${PACKAGE_PREFIX_DIR}/bin/matc"
  )
endif()
