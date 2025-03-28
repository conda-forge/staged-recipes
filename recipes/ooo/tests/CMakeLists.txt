cmake_minimum_required(VERSION 3.16)
project(atomtest LANGUAGES CXX)

find_package(Libxc CONFIG REQUIRED)
find_package(IntegratorXX CONFIG REQUIRED)
find_package(nlohmann_json CONFIG REQUIRED)
find_package(OpenOrbitalOptimizer CONFIG REQUIRED)

add_executable(atomtest "atomtest.cpp")
#        target_include_directories(atomtest PRIVATE "../tests/")
target_link_libraries(
  atomtest
    OpenOrbitalOptimizer::OpenOrbitalOptimizer
    Libxc::xc
    IntegratorXX::IntegratorXX
    nlohmann_json::nlohmann_json
  )

