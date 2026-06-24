cmake_minimum_required(VERSION 3.16)
project(magnum_bindings_consumer LANGUAGES NONE)

find_package(Magnum REQUIRED)
find_package(MagnumBindings REQUIRED Python)

if(NOT TARGET MagnumBindings::Python)
  message(FATAL_ERROR "MagnumBindings::Python target was not exported")
endif()
