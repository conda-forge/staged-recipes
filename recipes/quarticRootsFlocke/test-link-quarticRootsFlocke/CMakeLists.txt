cmake_minimum_required(VERSION 3.0.0)

project(
  TestLinkQuarticRootsFlockeLib
)

find_package(Quartic CONFIG REQUIRED)

add_executable(test_linkage
    ../test_linkage.cpp
)

target_link_libraries(test_linkage
  PRIVATE
    QuarticStatic
)
