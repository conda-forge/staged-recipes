# - Find the MKL libraries
# Modified from Armadillo's ARMA_FindMKL.cmake
# This module defines
#  MKL_INCLUDE_DIR, the directory for the MKL headers
#  MKL_LIB_DIR, the directory for the MKL library files
#  MKL_COMPILER_LIB_DIR, the directory for the MKL compiler library files
#  MKL_LIBRARIES, the libraries needed to use Intel's implementation of BLAS & LAPACK.
#  MKL_FOUND, If false, do not try to use MKL; if true, the macro definition USE_MKL is added.

# Set the include path
# TODO: what if MKL is not installed in /opt/intel/mkl?
# try to find at /opt/intel/mkl
# in windows, try to find MKL at C:/Program Files (x86)/Intel/Composer XE/mkl

if (WIN32)
  if (NOT DEFINED ENV{MKLROOT_PATH})
    set(MKLROOT_PATH "C:/Program Files (x86)/Intel/Composer XE" CACHE PATH "Where the MKL are stored")
  endif ()
else ()
  set(MKLROOT_PATH "/opt/intel" CACHE PATH "Where the MKL are stored")
endif ()

if (EXISTS ${MKLROOT_PATH}/mkl OR EXISTS ${MKLROOT_PATH})
  set(MKL_FOUND TRUE)
  if (EXISTS ${MKLROOT_PATH}/mkl)
    message("MKL is found at ${MKLROOT_PATH}/mkl")
  else ()
    message("MKL is found at ${MKLROOT_PATH}")
  endif ()
  
  if (CMAKE_SIZEOF_VOID_P EQUAL 8)
    set(USE_MKL_64BIT ON)
    if (ARMADILLO_FOUND)
      if (ARMADILLO_BLAS_LONG_LONG)
        set(USE_MKL_64BIT_LIB ON)
        add_definitions(-DMKL_ILP64)
        message("MKL is linked against ILP64 interface ... ")
      endif ()
    endif ()
  else ()
    set(USE_MKL_64BIT OFF)
  endif ()
else ()
  set(MKL_FOUND FALSE)
  message("MKL is NOT found ... ")
endif ()

if (MKL_FOUND)
  if (EXISTS ${MKLROOT_PATH}/mkl)
    set(MKL_INCLUDE_DIR "${MKLROOT_PATH}/mkl/include")
  else ()
    set(MKL_INCLUDE_DIR "${MKLROOT_PATH}/include")
  endif ()
  add_definitions(-DUSE_MKL)
  if (USE_MKL_64BIT)
    if (EXISTS ${MKLROOT_PATH}/mkl)
      set(MKL_LIB_DIR "${MKLROOT_PATH}/mkl/lib/intel64")
    else ()
      set(MKL_LIB_DIR "${MKLROOT_PATH}/lib/intel64")
    endif ()
    set(MKL_COMPILER_LIB_DIR "${MKLROOT_PATH}/compiler/lib/intel64")
    set(MKL_COMPILER_LIB_DIR ${MKL_COMPILER_LIB_DIR} "${MKLROOT_PATH}/lib/intel64")
    if (USE_MKL_64BIT_LIB)
      if (WIN32)
        set(MKL_LIBRARIES ${MKL_LIBRARIES} mkl_intel_ilp64)
      else ()
        set(MKL_LIBRARIES ${MKL_LIBRARIES} mkl_intel_ilp64)
      endif ()
    else ()
      if (WIN32)
        set(MKL_LIBRARIES ${MKL_LIBRARIES} mkl_intel_lp64)
      else ()
        set(MKL_LIBRARIES ${MKL_LIBRARIES} mkl_intel_lp64)
      endif ()
    endif ()
  else ()
    if (EXISTS ${MKLROOT_PATH}/mkl)
      set(MKL_LIB_DIR "${MKLROOT_PATH}/mkl/lib/ia32")
    else ()
      set(MKL_LIB_DIR "${MKLROOT_PATH}/lib/ia32")
    endif ()
    set(MKL_COMPILER_LIB_DIR "${MKLROOT_PATH}/compiler/lib/ia32")
    set(MKL_COMPILER_LIB_DIR ${MKL_COMPILER_LIB_DIR} "${MKLROOT_PATH}/lib/ia32")
    if (WIN32)
      set(MKL_LIBRARIES ${MKL_LIBRARIES} mkl_intel_c)
    else ( )
      set(MKL_LIBRARIES ${MKL_LIBRARIES} mkl_intel)
    endif ( )
  endif ()

  if (WIN32)
    set(MKL_LIBRARIES ${MKL_LIBRARIES} mkl_intel_thread)
    set(MKL_LIBRARIES ${MKL_LIBRARIES} mkl_core)
    set(MKL_LIBRARIES ${MKL_LIBRARIES} libiomp5md)
  else ()
    set(MKL_LIBRARIES ${MKL_LIBRARIES} mkl_gnu_thread)
    set(MKL_LIBRARIES ${MKL_LIBRARIES} mkl_core)
  endif () 
endif ()

if (MKL_FOUND)
  if (NOT MKL_FIND_QUIETLY)
    message(STATUS "Found MKL libraries:  ${MKL_LIBRARIES}")
    message(STATUS "MKL_INCLUDE_DIR:      ${MKL_INCLUDE_DIR}")
    message(STATUS "MKL_LIB_DIR:          ${MKL_LIB_DIR}")
    message(STATUS "MKL_COMPILER_LIB_DIR: ${MKL_COMPILER_LIB_DIR}")
  endif ()

  include_directories(${MKL_INCLUDE_DIR})
  link_directories(${MKL_LIB_DIR} ${MKLROOT_PATH}/lib ${MKLROOT_PATH} ${MKL_COMPILER_LIB_DIR})
else ()
  if (MKL_FIND_REQUIRED)
    message(FATAL_ERROR "Could not find MKL libraries")
  endif ()
endif ()

# MARK_AS_ADVANCED(MKL_LIBRARY)
