cmake_minimum_required(VERSION 3.19)
project(filament_hello_world LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

find_package(Filament CONFIG REQUIRED)

add_executable(hello_world hello_world.cpp)
target_link_libraries(hello_world PRIVATE Filament::filament)

set(material_output "${CMAKE_CURRENT_BINARY_DIR}/bakedColor.filamat")
add_custom_command(
  OUTPUT "${material_output}"
  COMMAND Filament::matc -a opengl -p desktop -o "${material_output}" "${CMAKE_CURRENT_LIST_DIR}/../bakedColor.mat"
  DEPENDS "${CMAKE_CURRENT_LIST_DIR}/../bakedColor.mat"
  VERBATIM
)
add_custom_target(compile_material ALL DEPENDS "${material_output}")
add_dependencies(hello_world compile_material)
