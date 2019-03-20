cmake_minimum_required(VERSION 3.1)

# Based on minimal example in https://github.com/CGAL/cgal/wiki/How-to-use-CGAL-with-CMake-or-your-own-build-system
# but with Qt dependency removed

project(test_cgal)
find_package(CGAL REQUIRED COMPONENTS Core)
if(CGAL_FOUND)
  #required to use basic_viewer
  add_definitions(-DCGAL_USE_BASIC_VIEWER)
  #create the executable of the application
  add_executable(test_ test.cpp)
  #link it with the required CGAL libraries
  target_link_libraries(test_ CGAL::CGAL CGAL::CGAL_Core)
else()
  message("ERROR: this program requires CGAL and will not be compiled.")
endif()
