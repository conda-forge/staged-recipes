cmake_minimum_required(VERSION 3.15)
project(stduuid_smoke LANGUAGES CXX)

find_package(stduuid 1.2.3 EXACT CONFIG REQUIRED)
enable_testing()
foreach(standard IN ITEMS 17 20)
  add_executable(stduuid-cxx${standard} smoke.cpp)
  set_target_properties(stduuid-cxx${standard} PROPERTIES
    CXX_STANDARD ${standard} CXX_STANDARD_REQUIRED YES CXX_EXTENSIONS NO)
  target_link_libraries(stduuid-cxx${standard} PRIVATE stduuid)
  add_test(NAME cxx${standard} COMMAND stduuid-cxx${standard})
endforeach()
