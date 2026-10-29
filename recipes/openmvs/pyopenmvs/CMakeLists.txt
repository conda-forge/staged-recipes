# Builds only the pyOpenMVS module against the installed OpenMVS shared libraries.
cmake_minimum_required(VERSION 3.24)
project(pyOpenMVS CXX)
set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(OPENMVS_SOURCE_DIR "" CACHE PATH "OpenMVS source tree (for PythonWrapper.cpp)")
set(OPENMVS_PREFIX "" CACHE PATH "Prefix with the installed OpenMVS")
find_package(Python3 COMPONENTS Interpreter Development.Module REQUIRED)
find_package(Boost REQUIRED COMPONENTS python${Python3_VERSION_MAJOR}${Python3_VERSION_MINOR} iostreams program_options serialization)
find_package(Eigen3 CONFIG REQUIRED)
find_package(OpenCV REQUIRED)
find_package(CGAL REQUIRED)
find_package(OpenMP REQUIRED)

set(OMVS_INC ${OPENMVS_PREFIX}/include/OpenMVS)
foreach(lib MVS IO Math Common)
  find_library(OMVS_${lib} ${lib} PATHS ${OPENMVS_PREFIX}/lib/OpenMVS NO_DEFAULT_PATH REQUIRED)
endforeach()

# OpenMVS built with CUDA: its headers include cuda.h and call the CUDA APIs
file(STRINGS ${OMVS_INC}/ConfigLocal.h OMVS_USE_CUDA REGEX "^#define _USE_CUDA")
if(OMVS_USE_CUDA)
  find_package(CUDAToolkit REQUIRED)
endif()

Python3_add_library(pyOpenMVS MODULE ${OPENMVS_SOURCE_DIR}/libs/MVS/PythonWrapper.cpp)
target_include_directories(pyOpenMVS PRIVATE ${OMVS_INC} ${OMVS_INC}/MVS)
target_compile_definitions(pyOpenMVS PRIVATE _USE_BOOST_PYTHON)
target_link_libraries(pyOpenMVS PRIVATE ${OMVS_MVS} ${OMVS_IO} ${OMVS_Math} ${OMVS_Common}
  Boost::python Boost::iostreams Boost::program_options Boost::serialization
  Eigen3::Eigen ${OpenCV_LIBS} CGAL::CGAL OpenMP::OpenMP_CXX)
if(OMVS_USE_CUDA)
  target_link_libraries(pyOpenMVS PRIVATE CUDA::cudart CUDA::cuda_driver CUDA::curand)
endif()
set_target_properties(pyOpenMVS PROPERTIES PREFIX "" SUFFIX ".so"
  INSTALL_RPATH "${OPENMVS_PREFIX}/lib/OpenMVS;${OPENMVS_PREFIX}/lib")
install(TARGETS pyOpenMVS DESTINATION "${Python3_SITEARCH}")
