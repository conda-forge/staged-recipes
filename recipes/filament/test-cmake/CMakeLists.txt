cmake_minimum_required(VERSION 3.19)
project(filament_consumer LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

if(NOT DEFINED ENV{PREFIX})
  message(FATAL_ERROR "PREFIX must be set by the conda-build test environment")
endif()

set(FILAMENT_PREFIX "$ENV{PREFIX}")
set(FILAMENT_LIBRARY_DIRS
    "${FILAMENT_PREFIX}/lib"
    "${FILAMENT_PREFIX}/lib/${CMAKE_SYSTEM_PROCESSOR}"
)

find_path(FILAMENT_INCLUDE_DIR
  NAMES filament/Engine.h
  PATHS "${FILAMENT_PREFIX}/include"
  NO_DEFAULT_PATH
  REQUIRED
)

find_library(FILAMENT_LIBRARY
  NAMES filament
  PATHS ${FILAMENT_LIBRARY_DIRS}
  NO_DEFAULT_PATH
  REQUIRED
)

add_library(Filament::filament STATIC IMPORTED)
set_target_properties(Filament::filament PROPERTIES
  IMPORTED_LOCATION "${FILAMENT_LIBRARY}"
  INTERFACE_INCLUDE_DIRECTORIES "${FILAMENT_INCLUDE_DIR}"
)

add_executable(filament_consumer main.cpp)
target_link_libraries(filament_consumer PRIVATE Filament::filament)
