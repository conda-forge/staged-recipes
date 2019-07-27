# Taken from https://gist.githubusercontent.com/scpeters/6325123/raw/cfb079be67997cb19a1aee60449714a1dedefed5/tinyxml_CMakeLists.patch
# This CMakeLists.txt file builds a shared library and provide an install
# target for tinyxml. This was submitted upstream as
# https://sourceforge.net/p/tinyxml/patches/66/
cmake_minimum_required(VERSION 2.4.6)
add_definitions(-DTIXML_USE_STL)
add_library(tinyxml SHARED tinyxml.cpp tinyxmlerror.cpp tinyxmlparser.cpp)
set_target_properties(tinyxml PROPERTIES
                      INSTALL_NAME_DIR ${CMAKE_INSTALL_PREFIX}/lib)

install(TARGETS tinyxml)

install(FILES tinyxml.h
        DESTINATION include)
