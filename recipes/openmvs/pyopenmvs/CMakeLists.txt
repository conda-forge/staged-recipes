# Builds only the pyOpenMVS module against the installed OpenMVS shared
# libraries (the openmvs package), via OpenMVS's CMake package.
cmake_minimum_required(VERSION 3.24)
project(pyOpenMVS CXX)
set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(OPENMVS_SOURCE_DIR "" CACHE PATH "OpenMVS source tree (for PythonWrapper.cpp)")
find_package(Python3 COMPONENTS Interpreter Development.Module REQUIRED)
find_package(Boost REQUIRED COMPONENTS python${Python3_VERSION_MAJOR}${Python3_VERSION_MINOR})
find_package(OpenMVS CONFIG REQUIRED)

Python3_add_library(pyOpenMVS MODULE ${OPENMVS_SOURCE_DIR}/libs/MVS/PythonWrapper.cpp)
# PythonWrapper.cpp includes MVS headers by their short names ("Scene.h")
target_include_directories(pyOpenMVS PRIVATE ${OpenMVS_INCLUDE_DIRS}/MVS)
target_compile_definitions(pyOpenMVS PRIVATE _USE_BOOST_PYTHON)
target_link_libraries(pyOpenMVS PRIVATE OpenMVS::MVS Boost::python)
set_target_properties(pyOpenMVS PROPERTIES PREFIX "" SUFFIX ".so")
install(TARGETS pyOpenMVS DESTINATION "${Python3_SITEARCH}")
