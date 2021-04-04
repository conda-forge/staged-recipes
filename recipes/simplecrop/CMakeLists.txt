cmake_minimum_required(VERSION 3.0)

enable_language(Fortran)
project(simplecrop Fortran)
set(CMAKE_Fortran_FLAGS "-Wall -Wextra -Wpedantic -std=f2003 -Wimplicit-interface")
set(CMAKE_Fortran_MODULE_DIRECTORY ${CMAKE_BINARY_DIR}/mod)

set(CMAKE_MACOSX_RPATH 1)
set(CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/lib")

add_executable(
  simplecrop
  Main.f90
  PlantCLI.f90
  PlantComponent.f90
  SoilCLI.f90
  SoilComponent.f90
  WeatherCLI.f90
)

install(
  TARGETS simplecrop
  RUNTIME DESTINATION bin
)
