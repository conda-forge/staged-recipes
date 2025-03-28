cmake_minimum_required(VERSION 3.16)
project(atomtest LANGUAGES CXX)

find_package(Libxc CONFIG REQUIRED)
find_package(IntegratorXX CONFIG REQUIRED)
find_package(nlohmann_json CONFIG REQUIRED)
find_package(OpenOrbitalOptimizer CONFIG REQUIRED)

include(CMakePrintHelpers)
cmake_print_properties(
  TARGETS
    armadillo
    IntegratorXX::IntegratorXX
    OpenOrbitalOptimizer::OpenOrbitalOptimizer
  PROPERTIES
    IMPORTED_LINK_DEPENDENT_LIBRARIES
    IMPORTED_LOCATION
    INTERFACE_LOCATION
    INTERFACE_LINK_LIBRARIES
    INTERFACE_INCLUDE_DIRECTORIES
    INTERFACE_COMPILE_DEFINITIONS
    INTERFACE_COMPILE_OPTIONS
    INTERFACE_SYSTEM_INCLUDE_DIRECTORIES
  )

add_executable(atomtest "atomtest.cpp")
#        target_include_directories(atomtest PRIVATE "../tests/")
target_link_libraries(
  atomtest
    OpenOrbitalOptimizer::OpenOrbitalOptimizer
    Libxc::xc
    IntegratorXX::IntegratorXX
    nlohmann_json::nlohmann_json
  )

