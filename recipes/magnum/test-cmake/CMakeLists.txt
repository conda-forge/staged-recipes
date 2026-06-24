cmake_minimum_required(VERSION 3.16)
project(magnum_consumer LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

find_package(Magnum REQUIRED Primitives Trade)

add_executable(magnum_consumer main.cpp)
target_link_libraries(magnum_consumer PRIVATE
  Magnum::Magnum
  Magnum::Primitives
  Magnum::Trade
)
