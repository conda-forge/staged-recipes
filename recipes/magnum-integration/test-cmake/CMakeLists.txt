cmake_minimum_required(VERSION 3.16)
project(magnum_integration_consumer LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

find_package(Eigen3 REQUIRED)
find_package(Magnum REQUIRED)
find_package(MagnumIntegration REQUIRED Eigen)

add_executable(magnum_integration_consumer main.cpp)
target_link_libraries(magnum_integration_consumer PRIVATE
  Eigen3::Eigen
  Magnum::Magnum
)

if(TARGET MagnumIntegration::EigenIntegration)
  target_link_libraries(magnum_integration_consumer PRIVATE MagnumIntegration::EigenIntegration)
elseif(TARGET MagnumIntegration::Eigen)
  target_link_libraries(magnum_integration_consumer PRIVATE MagnumIntegration::Eigen)
endif()
