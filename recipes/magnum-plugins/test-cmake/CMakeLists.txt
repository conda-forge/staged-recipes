cmake_minimum_required(VERSION 3.16)
project(magnum_plugins_consumer LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

find_package(Corrade REQUIRED PluginManager)
find_package(Magnum REQUIRED Trade)
find_package(MagnumPlugins REQUIRED StbImageImporter UfbxImporter)

add_executable(magnum_plugins_consumer main.cpp)
target_link_libraries(magnum_plugins_consumer PRIVATE
  Corrade::PluginManager
  Magnum::Trade
)

if(TARGET MagnumPlugins::StbImageImporter)
  target_link_libraries(magnum_plugins_consumer PRIVATE MagnumPlugins::StbImageImporter)
endif()

if(TARGET MagnumPlugins::UfbxImporter)
  target_link_libraries(magnum_plugins_consumer PRIVATE MagnumPlugins::UfbxImporter)
endif()
