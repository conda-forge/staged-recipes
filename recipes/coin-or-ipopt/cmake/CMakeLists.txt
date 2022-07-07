cmake_minimum_required(VERSION 2.8)

project(IpOpt)

# FUNNY_LAPACK_FINT

#undef HAVE_MPI_INITIALIZED - Define to 1 if you have the `MPI_Initialized' function.

option(COIN_ENABLE_READLINE "Enable the use of the readline library" OFF)

option(IPOPT_HAS_AMPL                   "Enable Ampl interface" OFF)
option(IPOPT_HAS_PARDISO                "Enable Pardiso solver" OFF)
option(IPOPT_HAS_PARDISO_MKL            "Enable if you are using Pardiso from MKL" OFF)
option(IPOPT_HAS_PARDISO_OLDINTERFACE   "Enable if you are not using at least a 4.0 version of Pardiso" OFF)
option(IPOPT_HAS_PARDISO_PARALLEL       "Enable if you are using the parallel version of Pardiso" OFF)
option(IPOPT_HAS_HSL                    "Enable HSL interface"  OFF)
option(IPOPT_HAS_WSMP                   "Enable WSMP solver"    OFF)
option(IPOPT_HAS_MUMPS                  "Enable Mumps solver"   OFF)
option(IPOPT_BUILD_EXAMPLES             "Enable the building of examples" OFF)
option(IPOPT_ENABLE_LINEARSOLVERLOADER  "Build the dynamic linear solver loader" OFF)
option(IPOPT_ENABLE_PARDISOSOLVERLOADER "Build the dynamic pardiso solver loader" OFF)
option(IPOPT_ENABLE_INEXACT             "Build the inexact solver" OFF)

set(IPOPT_CHECKLEVEL "0" CACHE STRING "The debug sanity check level of IpOpt (0 if no test)")
set(IPOPT_VERBOSITY  "0" CACHE STRING "The debug verbosity level of IpOpt (0 if no output)")

set(COIN_HAS_MUMPS OFF CACHE BOOL "Enable the Mumps linear solver (default solver enabled)" FORCE)
set(COIN_HAS_MUMPS_INCLUDE_PATH "None" CACHE PATH "The MUMPS linear solver include Path")
set(COIN_HAS_MUMPS_LIBRARY_PATH "None" CACHE PATH "The MUMPS linear solver absolute library Path")

set(COIN_HAS_WSMP OFF CACHE BOOL "Enable the WSMP linear solver" FORCE)
set(COIN_HAS_WSMP_INCLUDE_PATH "None" CACHE PATH "The WSMP linear solver include Path")
set(COIN_HAS_WSMP_LIBRARY_PATH "None" CACHE PATH "The WSMP linear solver absolute library Path")

# Compilation options
option(ENABLE_SHARED_LIBRARIES       "Build libraries as shared libraries" ON)
option(COIN_COMPILE_STATIC           "Activate the static linking" OFF)
option(COIN_COMPILE_COVERAGE         "Activate the code coverage compilation" OFF)
option(COIN_COMPILE_PROFILE          "Activate the code profiling compilation" OFF)
option(COIN_COMPILE_PROFILE_VALGRIND "Activate the code profiling compilation for valgrind" OFF)
option(COIN_COMPILE_LTO              "Activate the whole program optimization" OFF)
option(COIN_HAS_MKL                  "Use Intel MKL library (requires Intel compiler)" OFF)
option(COIN_USE_FAST_CODE            "Use intensive optimization flags" OFF)
option(COIN_COMPILE_WARNINGS         "Activate a set of warning options" OFF)
option(COIN_COMPILE_CXX11            "Activate C++11 compilation" OFF)
option(COIN_TESTS_DISABLE_TIMEOUT    "Disable the timeout of the tests" OFF)
option(COIN_ENABLE_DOXYGEN           "Enable the build of doxygen documentation" OFF)
option(COIN_LINK_GFORTRAN            "Link examples against gfortran" ON)

option(USE_PROCESSOR_EXTENSIONS      "Use sse / mmx / avx extensions during compilation" OFF)
option(COIN_ENABLE_COMPAT            "Enable libc compatibility" OFF)

# Set paths of source
set(COIN_DIR "${CMAKE_CURRENT_SOURCE_DIR}" CACHE PATH "The Cbc Path")

set(COIN_COVERAGE_CTEST_LABEL "SAMPLE" CACHE PATH "The label sent to ctest during coverage")

mark_as_advanced(ENABLE_SHARED_LIBRARIES
                 COIN_ENABLE_READLINE
                 COIN_COMPILE_STATIC
                 COIN_COMPILE_COVERAGE
                 COIN_COMPILE_PROFILE
                 COIN_COMPILE_PROFILE_VALGRIND
                 COIN_COMPILE_LTO
                 COIN_HAS_MKL
                 COIN_USE_FAST_CODE
                 COIN_COMPILE_WARNINGS
                 COIN_COMPILE_CXX11
                 COIN_HAS_MUMPS
                 COIN_HAS_MUMPS_INCLUDE_PATH
                 COIN_HAS_MUMPS_LIBRARY_PATH
                 COIN_HAS_WSMP
                 COIN_HAS_WSMP_INCLUDE_PATH
                 COIN_HAS_WSMP_LIBRARY_PATH
                 COIN_LINK_GFORTRAN
		 COIN_DIR
		 IPOPT_HAS_PARDISO_MKL
		 IPOPT_HAS_PARDISO_OLDINTERFACE
		 IPOPT_HAS_PARDISO_PARALLEL
                 COIN_IPOPT_CHECKLEVEL
                 COIN_IPOPT_VERBOSITY
                 USE_PROCESSOR_EXTENSIONS
		 COIN_COVERAGE_CTEST_LABEL)

# Set paths for binary and library generation inside the build directory:
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH}
                      ${CMAKE_CURRENT_SOURCE_DIR}/cmake)

include(coin-macros)
include(GetAcInitVersion)
include(CheckCLinkerFlag)
include(GNUInstallDirs)

Enable_Testing ()

#------------------------------------------------------------
# Check options
#------------------------------------------------------------

if (IPOPT_ENABLE_INEXACT AND NOT (IPOPT_HAS_PARDISO OR IPOPT_HAS_PARDISO_MKL OR IPOPT_HAS_PARDISO_OLDINTERFACE OR IPOPT_HAS_PARDISO_PARALLEL))
  message(FATAL_ERROR "Error: Inexact solver is only available through MKL. Please activate the MKL")
endif ()

if (NOT IPOPT_ENABLE_INEXACT)
  message(WARNING "If you have MKL, you can activate IPOPT_ENABLE_INEXACT")
endif ()

#------------------------------------------------------------
# Detect 64 bits
#------------------------------------------------------------

if (CMAKE_SIZEOF_VOID_P EQUAL 4)
  set(HAVE_64_BIT 0)
else ()
  set(HAVE_64_BIT 1)
endif ()

# Various definitions

# Name of package
set(PACKAGE           "IpOpt")
# Define to the address where bug reports for this package should be sent.
set(PACKAGE_BUGREPORT "bugs@coin-or.org")
# Define to the full name of this package.
set(PACKAGE_NAME      "IpOpt")
# Define to the full name and version of this package.
set(PACKAGE_STRING    "IpOpt")
# Define to the one symbol short name of this package.
set(PACKAGE_TARNAME   "ipopt")

if (CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
  set(CMAKE_INSTALL_PREFIX "${CMAKE_BINARY_DIR}/ipopt_binary" 
      CACHE PATH "IpOpt install prefix" FORCE)
endif ()

include(CheckCCompilerFlag)
if (COIN_COMPILE_LTO)
  if (NOT CMAKE_VERSION VERSION_LESS "3.9")
    cmake_policy(SET CMP0069 NEW)
    include(CheckIPOSupported)
    check_ipo_supported()
  endif ()
endif ()

if (COIN_ENABLE_COMPAT)
  # Disable extra stdc++ symbols (@GLIBCXX_3.4.21)
  add_definitions(-D_GLIBCXX_USE_CXX11_ABI=0)
  set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -include ${CMAKE_CURRENT_SOURCE_DIR}/cmake/compatibility.h")
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -include ${CMAKE_CURRENT_SOURCE_DIR}/cmake/compatibility.h")
endif ()

# Desactivate some relocation types for portability
if (UNIX AND COIN_ENABLE_COMPAT)
  check_c_compiler_flag("-Wa,-mrelax-relocations=no" HAVE_RELAX_RELOC_FLAG)
  if (HAVE_RELAX_RELOC_FLAG)
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wa,-mrelax-relocations=no")
  endif ()
endif ()

# Check for readline
set(COIN_HAS_READLINE "OFF")
if (COIN_ENABLE_READLINE)
  find_package(Readline)
  if (READLINE_FOUND)
    set(COIN_HAS_READLINE "ON")
    
    include_directories(${READLINE_INCLUDE_DIR})
  endif ()
endif ()

if (USE_PROCESSOR_EXTENSIONS)
  # Check for SSE* and AVX*
  find_package(SSE)
  if (MMX_FOUND OR
      SSE2_FOUND OR SSE3_FOUND OR SSSE3_FOUND OR SSE4_1_FOUND OR SSE4_2_FOUND OR
      AVX_FOUND OR AVX2_FOUND)
    set(CMAKE_C_FLAGS       "${CMAKE_C_FLAGS} ${SSE_COMPILER_FLAGS}")
    set(CMAKE_CXX_FLAGS     "${CMAKE_CXX_FLAGS} ${SSE_COMPILER_FLAGS}")
    set(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} ${SSE_COMPILER_FLAGS}")
  endif ()
endif ()

# Check for MKL
if (COIN_HAS_MKL)
  find_package(MKL)
  
  if (MKL_FOUND)
    message(STATUS "MKL library found")
  else ()
    message(STATUS "MKL library not found")
  endif ()
  
  # Copy libiomp5md.dll in the build directory
  if (WIN32)
    if (HAVE_64_BIT)
      set(MKL_DLL_DIR ${MKL_ROOT}/bin/intel64)
    else ()
      set(MKL_DLL_DIR ${MKL_ROOT}/bin/ia32)
    endif ()
    
    execute_process(COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_BINARY_DIR}/bin/
                    COMMAND ${CMAKE_COMMAND} -E copy ${MKL_DLL_DIR}/libiomp5md.dll ${CMAKE_BINARY_DIR}/bin/
                    COMMAND ${CMAKE_COMMAND} -E echo "Copying ${MKL_DLL_DIR}/libiomp5md.dll into ${CMAKE_BINARY_DIR}/bin/")
  endif ()
  
  set(COIN_MKL_LIBS "${MKL_LIBRARIES}")
  if (WIN32)
    set(COIN_MKL_LIBS ${COIN_MKL_LIBS} mkl_intel_thread libiomp5md)
  else ()
    set(COIN_MKL_LIBS ${COIN_MKL_LIBS} mkl_gnu_thread gomp dl)
  endif ()
  
  include_directories(${MKL_INCLUDE_DIRS})
  
  if (HAVE_64_BIT)
    link_directories(${MKLROOT_PATH}/mkl/lib/intel64)
  else ()
    link_directories(${MKLROOT_PATH}/mkl/lib/ia32)
  endif ()
  
  set(COIN_HAS_LAPACK ON CACHE BOOL "Use Intel MKL library (requires Intel compiler)")
endif ()

# Check some directories

coin_check_and_add_include_path(COIN_HAS_MUMPS_INCLUDE_PATH)
coin_check_and_add_library_path(COIN_HAS_MUMPS_LIBRARY_PATH)
coin_check_and_add_include_path(COIN_HAS_WSMP_INCLUDE_PATH)
coin_check_and_add_library_path(COIN_HAS_WSMP_LIBRARY_PATH)

#-----------------------------------------------------------------------------
# Manage compilation options
#-----------------------------------------------------------------------------

if (UNIX)
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wno-deprecated")
  set(CMAKE_C_FLAGS   "${CMAKE_C_FLAGS}   -Wno-deprecated")
  
  if (NOT ENABLE_SHARED_LIBRARIES)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fPIC")
    set(CMAKE_C_FLAGS   "${CMAKE_C_FLAGS}   -fPIC")
  endif ()
  if (COIN_COMPILE_WARNINGS)
    # Try to locate unitizalized variables
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -Wshadow -Wuninitialized ")
    set(CMAKE_C_FLAGS   "${CMAKE_C_FLAGS}   -Wall -Wshadow -Wmissing-prototypes -Wuninitialized ")
  endif ()
  if (COIN_COMPILE_STATIC)
    if (CMAKE_CXX_COMPILER_ID STREQUAL "GNU" AND NOT APPLE)
      set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -static")
      
      check_c_linker_flag("-z muldef" ZFLAGDEFINED)
      if (ZFLAGDEFINED)
	set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -z muldefs")
      endif ()
    endif ()
  endif ()
  if (COIN_COMPILE_COVERAGE)
    if (CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
      set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -O0 --coverage")
      set(CMAKE_C_FLAGS          "${CMAKE_C_FLAGS} -O0 --coverage")
      set(CMAKE_CXX_FLAGS        "${CMAKE_CXX_FLAGS} -O0 --coverage")
    endif ()
    if (CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
      set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fprofile-arcs -ftest-coverage -Xclang -coverage-cfg-checksum -Xclang -coverage-no-function-names-in-data -Xclang -coverage-version='408*'")
    endif ()
  endif ()
  if (COIN_COMPILE_PROFILE)
    set(CMAKE_CXX_FLAGS        "${CMAKE_CXX_FLAGS} -pg")
    set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -pg")
  endif ()
  if (COIN_COMPILE_PROFILE_VALGRIND)
    set(CMAKE_CXX_FLAGS        "${CMAKE_CXX_FLAGS} -p")
    set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -p")
  else ()
    if (CMAKE_CXX_COMPILER_ID STREQUAL "GNU" AND NOT APPLE)
      check_c_linker_flag("-z muldef" ZFLAGDEFINED)
      if (ZFLAGDEFINED)
	set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -z muldefs")
      endif ()
    endif ()
  endif ()
endif ()

#-----------------------------------------------------------------------------
# Manage specific VS flags
#-----------------------------------------------------------------------------

if (MSVC)
  # Avoid Warning C4530 by using the flag /EHsc
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /EHsc ")
  set(CMAKE_C_FLAGS   "${CMAKE_C_FLAGS} /EHsc ")
endif ()

#-----------------------------------------------------------------------------
# Manage threads include dir under Windows
#-----------------------------------------------------------------------------

if (WIN32)
  if (NOT COIN_THREADS_INC_PATH STREQUAL "None")
    include_directories(${COIN_THREADS_INC_PATH})
  endif ()
  if (NOT COIN_THREADS_LIB_PATH STREQUAL "None")
    link_directories(${COIN_THREADS_LIB_PATH})
  endif ()
endif ()

# Check for a fortran compiler
include(CMakeDetermineFortranCompiler)
if (NOT CMAKE_Fortran_COMPILER)
  message(STATUS "WARNING: fortran compiler not found. Disabling f77/f95 bindings")
endif ()

# Define IPOPT_FORTRAN_INTEGER_TYPE for Ipopt.
set(IPOPT_FORTRAN_INTEGER_TYPE int)

#-----------------------------------------------------------------------------
# Detect name mangling convention used between Fortran and C
#-----------------------------------------------------------------------------

if (CMAKE_Fortran_COMPILER)
  enable_language(Fortran)
  
  include(FortranCInterface)
  
  FortranCInterface_HEADER(${CMAKE_BINARY_DIR}/F77Mangle.h
                           MACRO_NAMESPACE "F77_"
                           SYMBOL_NAMESPACE "F77_")
  
  file(STRINGS ${CMAKE_BINARY_DIR}/F77Mangle.h CONTENTS REGEX "F77_GLOBAL\\(.*,.*\\) +(.*)")
  string(REGEX MATCH "F77_GLOBAL\\(.*,.*\\) +(.*)" RESULT ${CONTENTS})
  set(F77_FUNC         "F77_FUNC(name,NAME) ${CMAKE_MATCH_1}")
  set(IPOPT_LAPACK_FUNC "IPOPT_LAPACK_FUNC(name,NAME) ${CMAKE_MATCH_1}")
  
  file(STRINGS ${CMAKE_BINARY_DIR}/F77Mangle.h CONTENTS REGEX "F77_GLOBAL_\\(.*,.*\\) +(.*)")
  string(REGEX MATCH "F77_GLOBAL_\\(.*,.*\\) +(.*)" RESULT ${CONTENTS})
  set(F77_FUNC_         "F77_FUNC_(name,NAME) ${CMAKE_MATCH_1}")
  set(IPOPT_LAPACK_FUNC_ "IPOPT_LAPACK_FUNC_(name,NAME) ${CMAKE_MATCH_1}")
else ()
  set(F77_FUNC          "F77_FUNC(name,NAME)  name##_")
  set(F77_FUNC_         "F77_FUNC_(name,NAME) name##__")
  set(IPOPT_LAPACK_FUNC  "IPOPT_LAPACK_FUNC(name,NAME)  name##_")
  set(IPOPT_LAPACK_FUNC_ "IPOPT_LAPACK_FUNC_(name,NAME) name##__")
endif ()

set(F77_DUMMY_MAIN "" CACHE STRING "Define to dummy 'main' function (if any) required to link to the Fortran libraries.")
set(FC_DUMMY_MAIN  "" CACHE STRING "Define to dummy 'main' function (if any) required to link to the Fortran libraries.")
option(FC_DUMMY_MAIN_EQ_F77 "Define if F77 and FC dummy 'main' functions are identical." OFF)

if (FC_DUMMY_MAIN_EQ_F77)
  set(FC_DUMMY_MAIN "${F77_DUMMY_MAIN}")
endif ()

mark_as_advanced(F77_FUNC
                 F77_FUNC_
                 F77_DUMMY_MAIN
                 FC_DUMMY_MAIN
                 FC_DUMMY_MAIN_EQ_F77)

# Manage coverage via lcov automatically

if (COIN_COMPILE_COVERAGE AND NOT ((CMAKE_BUILD_TYPE STREQUAL "DEBUG") OR (CMAKE_BUILD_TYPE STREQUAL "RELWITHDEBINFO")))
  message(STATUS "Warning: to enable coverage, you must compile in DEBUG ou RELWITHDEBINFO mode")
endif ()

if (COIN_COMPILE_COVERAGE)
  if (WIN32)
    message(FATAL_ERROR "Error: code coverage analysis is only available under Linux for now.")
  endif ()
  
  find_program(GCOV_PATH gcov)
  find_program(LCOV_PATH lcov)
  find_program(GENHTML_PATH genhtml)

  if (NOT GCOV_PATH)
    message(FATAL_ERROR "gcov not found! Please install lcov and gcov. Aborting...")
  endif ()
  
  if (NOT LCOV_PATH)
    message(FATAL_ERROR "lcov not found! Please install lcov and gcov. Aborting...")
  endif ()
  
  if (NOT GENHTML_PATH)
    message(FATAL_ERROR "genhtml not found! Please install lcov and gcov. Aborting...")
  endif ()
  
  # /!\ FAILURE IF AT LEAST ONE TEST FAILS
  # Capturing lcov counters and generating report
  add_custom_target(coverage
                    COMMAND ${LCOV_PATH} --directory ${CMAKE_BINARY_DIR} --zerocounters
                    COMMAND ${LCOV_PATH} --capture --initial --directory ${CMAKE_BINARY_DIR} --output-file ${CMAKE_BINARY_DIR}/coverage.info
                    COMMAND ${CMAKE_COMMAND} -E chdir ${CMAKE_BINARY_DIR} ${CMAKE_CTEST_COMMAND} -LE "(LONG|FAIL)" -L "${COIN_COVERAGE_CTEST_LABEL}" || true
                    COMMAND ${LCOV_PATH} --capture --directory ${CMAKE_BINARY_DIR} --output-file ${CMAKE_BINARY_DIR}/coverage.info
                    COMMAND ${LCOV_PATH} --remove ${CMAKE_BINARY_DIR}/coverage.info "*/usr/include/*" '${CMAKE_BINARY_DIR}/Dependencies/${CMAKE_CFG_INTDIR}/*' --output-file ${CMAKE_BINARY_DIR}/coverage.info.cleaned
                    COMMAND ${GENHTML_PATH} -o ${CMAKE_BINARY_DIR}/coverage ${CMAKE_BINARY_DIR}/coverage.info.cleaned
                    COMMAND ${CMAKE_COMMAND} -E remove ${CMAKE_BINARY_DIR}/coverage.info ${CMAKE_BINARY_DIR}/coverage.info.cleaned
		    VERBATIM
                    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
                    COMMENT "Resetting code coverage counters to zero.
Processing code coverage counters and generating report.
You can zip the directory ${CMAKE_BINARY_DIR}/coverage and upload the content to a web server.")
endif ()

#
# Add uninstall-target
#

add_custom_target(uninstall
                  COMMAND ${CMAKE_COMMAND} -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/uninstall.cmake")

# Directories where to find the source code

set(Ipopt_DIR ${COIN_DIR})

# End of coverage

include(CheckIncludeFileCXX)
include(CheckIncludeFile)
include(VA_COPY)

check_include_file("assert.h"    HAVE_ASSERT_H)
check_include_file("bzlib.h"     HAVE_BZLIB_H)
check_include_file("ctype.h"     HAVE_CTYPE_H)
check_include_file("dlfcn.h"     HAVE_DLFCN_H)
check_include_file("endian.h"    HAVE_ENDIAN_H)
check_include_file("float.h"     HAVE_FLOAT_H)
check_include_file("ieeefp.h"    HAVE_IEEEFP_H)
check_include_file("inttypes.h"  HAVE_INTTYPES_H)
check_include_file("math.h"      HAVE_MATH_H)
check_include_file("memory.h"    HAVE_MEMORY_H)
if (COIN_ENABLE_READLINE)
  check_include_file("readline/readline.h" HAVE_READLINE_READLINE_H)
endif ()
check_include_file("stdint.h"    HAVE_STDINT_H)
check_include_file("stdlib.h"    HAVE_STDLIB_H)
check_include_file("stdio.h"     HAVE_STDIO_H)
check_include_file("stdarg.h"    HAVE_STDARG_H)
check_include_file("stddef.h"    HAVE_STDDEF_H)
check_include_file("strings.h"   HAVE_STRINGS_H)
check_include_file("string.h"    HAVE_STRING_H)
check_include_file("sys/stat.h"  HAVE_SYS_STAT_H)
check_include_file("sys/types.h" HAVE_SYS_TYPES_H)
check_include_file("time.h"      HAVE_TIME_H)
check_include_file("unistd.h"    HAVE_UNISTD_H)
check_include_file("windows.h"   HAVE_WINDOWS_H)
check_include_file("zlib.h"      HAVE_ZLIB_H)
check_include_file_cxx("cctype"    HAVE_CCTYPE)
check_include_file_cxx("cmath"     HAVE_CMATH)
check_include_file_cxx("cieeefp"   HAVE_CIEEEFP)
check_include_file_cxx("cfloat"    HAVE_CFLOAT)
check_include_file_cxx("cinttypes" HAVE_CINTTYPES)
check_include_file_cxx("cassert"   HAVE_CASSERT)
check_include_file_cxx("cstdio"    HAVE_CSTDIO)
check_include_file_cxx("cstdlib"   HAVE_CSTDLIB)
check_include_file_cxx("cstdarg"   HAVE_CSTDARG)
check_include_file_cxx("cstddef"   HAVE_CSTDDEF)
check_include_file_cxx("cstring"   HAVE_CSTRING)
check_include_file_cxx("ctime"     HAVE_CTIME)

string(SUBSTRING ${CMAKE_SHARED_LIBRARY_SUFFIX} 1 -1 SHAREDLIBEXT)

include(CheckCXXCompilerFlag)

if (COIN_COMPILE_CXX11 AND NOT WIN32)
  # VS2013 activate C++11 by default
  check_cxx_compiler_flag(-std=c++11 HAVE_STD_CPP11_FLAG)
  if (HAVE_STD_CPP11_FLAG)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11")
  else ()
    check_cxx_compiler_flag(-std=c++0x HAVE_STD_CPP0X_FLAG)
    if (HAVE_STD_CPP0X_FLAG)
      set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++0x")
    endif ()
  endif ()
endif ()

check_cxx_compiler_flag(-Qunused-arguments HAVE_QUNUSED_ARGUMENTS)
if (HAVE_QUNUSED_ARGUMENTS)
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Qunused-arguments")
endif ()

if (UNIX)
  if (CMAKE_CXX_COMPILER_ID STREQUAL "GNU" AND NOT APPLE)
    check_cxx_compiler_flag(-Wno-unused-local-typedefs GCC_HAS_TYPEDEFS)
    if (GCC_HAS_TYPEDEFS)
      set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wno-unused-local-typedefs")
    endif ()
  endif ()
  
  if (NOT APPLE)
    check_cxx_compiler_flag(-Wno-narrowing GCC_HAS_NARROWING)
    if (GCC_HAS_NARROWING)
      set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wno-narrowing")
      set(CMAKE_C_FLAGS   "${CMAKE_C_FLAGS}   -Wno-narrowing")
    endif ()
  endif ()
endif ()

include(CheckTypeSize)

check_type_size("int *" SIZEOF_INT_P)

include(CheckSymbolExists)
include(CheckCXXSymbolExists)
include(CheckFunctionExists)

set(CMAKE_REQUIRED_LIBRARIES m)
set(COIN_C_FINITE std::isfinite)

check_symbol_exists(clock_gettime time.h     HAVE_CLOCK_GETTIME)
check_symbol_exists(gettimeofday  sys/time.h HAVE_GETTIMEOFDAY)
check_symbol_exists(drand48 stdlib.h IPOPT_HAS_DRAND48)
# To avoid problems in Windows checks, always assume that rand exists
set(IPOPT_HAS_RAND 1 CACHE INTERNAL "Assume that rand is defined")
check_function_exists(snprintf   HAVE_SNPRINTF)
check_cxx_symbol_exists(std::rand cstdlib HAVE_STD__RAND)
check_function_exists(va_copy    HAVE_VA_COPY)
check_function_exists(vsnprintf  HAVE_VSNPRINTF)
check_function_exists(_snprintf  HAVE__SNPRINTF)
check_function_exists(_vsnprintf HAVE__VSNPRINTF)

if (WIN32)
  # snprintf not correctly detected under Visual Studio.
  # Hack: we just activate snprintf under Windows. 
  # TO BE FIXED
  set(HAVE_STDIO_H    1)
  set(HAVE_SNPRINTF   1)
  set(HAVE__SNPRINTF  1)
  set(HAVE_VSNPRINTF  1)
  set(HAVE__VSNPRINTF 1)
  set(HAVE_VA_COPY    1)
endif ()

if (COIN_USE_FAST_CODE)
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fomit-frame-pointer ")
  set(CMAKE_C_FLAGS   "${CMAKE_C_FLAGS} -fomit-frame-pointer ")
  
  if (CMAKE_CXX_COMPILER_ID STREQUAL "Intel")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fno-math-errno -fp-trap=none ")
    set(CMAKE_C_FLAGS   "${CMAKE_C_FLAGS} -fno-math-errno -fp-trap=none ")
  endif ()

  if (CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -ffast-math -fno-math-errno -fno-trapping-math ")
    set(CMAKE_C_FLAGS   "${CMAKE_C_FLAGS} -ffast-math -fno-math-errno -fno-trapping-math ")
  endif ()
  
endif ()

include(AC_HEADER_STDC)

add_definitions(-DHAVE_CONFIG_H)

if (("${MSVC_VERSION}" STREQUAL "1900") OR ("${MSVC_VERSION}" STREQUAL "1910"))
  add_definitions(/DHAVE_SNPRINTF /DHAVE_STRUCT_TIMESPEC)
endif ()

#-----------------------------------------------
# Doxygen documentation
#-----------------------------------------------

set(coin_doxy_logname ) # output warning to stderr
set(coin_doxy_excludes "*/.git*")
set(coin_doxy_tagfiles )
set(coin_doxy_tagname )

find_package(Doxygen)

if (DOXYGEN AND COIN_ENABLE_DOXYGEN)
  configure_file(${CMAKE_CURRENT_SOURCE_DIR}/doxydoc/doxygen.conf.in ${CMAKE_BINARY_DIR}/doxydoc/doxygen.conf)

  add_custom_target(docs 
                    ${DOXYGEN_EXECUTABLE} ${CMAKE_BINARY_DIR}/doxydoc/doxygen.conf)
endif ()

include_directories(${CMAKE_BINARY_DIR}/Dependencies/${CMAKE_CFG_INTDIR}/include
                    ${CMAKE_BINARY_DIR}/Dependencies/${CMAKE_CFG_INTDIR}/include/ampl)
link_directories(${CMAKE_BINARY_DIR}/Dependencies/${CMAKE_CFG_INTDIR}/lib
                 ${CMAKE_BINARY_DIR}/Dependencies/${CMAKE_CFG_INTDIR}/lib64)

#
# HSL Management
#

if (COIN_ENABLE_DOWNLOAD_METIS) # METIS found
  add_definitions(-DCOINHSL_HAS_METIS)
endif ()

if (IPOPT_ENABLE_LINEARSOLVERLOADER OR IPOPT_ENABLE_PARDISOSOLVERLOADER)
  add_definitions(-DIPOPT_HAS_LINEARSOLVERLOADER)

  find_package(DL)
endif ()

if (IPOPT_HAS_MUMPS)
  set(COINHSL_HAS_MUMPS ON)
endif ()

if (IPOPT_HAS_WSMP)
  add_definitions(-DIPOPT_HAS_WSMP)
  
  set(COINHSL_HAS_WSMP ON)
endif ()

add_subdirectory(Ipopt)

#
# Packaging
#

set(CPACK_PACKAGE_NAME      "${PACKAGE_NAME}")
set(CPACK_PACKAGE_FILE_NAME "${CPACK_PACKAGE_NAME}-${IPOPT_VERSION}-${CMAKE_SYSTEM_NAME}")

message(STATUS "Package filename: ${CPACK_PACKAGE_FILE_NAME}")

set(CPACK_PACKAGE_INSTALL_DIRECTORY "${PACKAGE_NAME}")
set(CPACK_PACKAGE_VERSION "${IPOPT_VERSION}")

set(CPACK_PACKAGE_RELOCATABLE TRUE)

if (WIN32)
  set(CPACK_PACKAGE_INSTALL_REGISTRY_KEY "${CPACK_PACKAGE_NAME}")
  set(CPACK_MONOLITHIC_INSTALL ON)
  set(CPACK_NSIS_CONTACT "${PACKAGE_BUGREPORT}")
  set(CPACK_NSIS_MODIFY_PATH ON)
  set(CPACK_NSIS_PACKAGE_NAME "IpOpt ${IPOPT_VERSION}")
elseif (APPLE)
  set(CPACK_COMPONENTS_ALL_IN_ONE_PACKAGE ON)
  set(CPACK_PACKAGE_DEFAULT_LOCATION "/opt/${CPACK_PACKAGE_NAME}")
  set(CPACK_PACKAGING_INSTALL_PREFIX "/")
else (WIN32)
  set(CPACK_COMPONENTS_ALL_IN_ONE_PACKAGE ON)
  set(CPACK_PACKAGE_DEFAULT_LOCATION "/opt/${CPACK_PACKAGE_NAME}")
  set(CPACK_PACKAGING_INSTALL_PREFIX "/")
  
  set(CPACK_DEBIAN_PACKAGE_SECTION "Libraries")
  set(CPACK_DEBIAN_PACKAGE_MAINTAINER "${PACKAGE_BUGREPORT}")
  
  set(CPACK_RPM_COMPONENT_INSTALL ON)
  set(CPACK_RPM_PACKAGE_RELOCATABLE ON)
  set(CPACK_RPM_PACKAGE_LICENSE "Copyrighted")
  set(CPACK_RPM_PACKAGE_GROUP "Development/Libraries")
  set(CPACK_RPM_PACKAGE_URL "${PACKAGE_URL}")
  set(CPACK_RPM_PACKAGE_SUMMARY "IpOpt is a non linear constrained solver library from CoinOR.")
  set(CPACK_RPM_PACKAGE_DESCRIPTION 
    "The CoinUtils suite includes:

    * The IpOpt non linear constrained solver.
"
    )
endif ()

include(CPack)
include(CTest)

###########################
#                         #
# Sum-up of configuration #
#                         #
###########################

# available colors: {u,b,bg, } black, red, green, yellow, blue, purple, cyan, white, reset

color_message("${color_green}")
color_message("************************")
color_message("*                      *")
color_message("* Configuration sum-up *")
color_message("*                      *")
color_message("************************")
color_message("${color_reset} ")

color_message("${color_cyan}Installation directory:${color_reset} ${CMAKE_INSTALL_PREFIX}")
color_message("${color_cyan}Build type:${color_reset} ${CMAKE_BUILD_TYPE}")

get_directory_property(ALL_INCLUDES INCLUDE_DIRECTORIES)
get_directory_property(ALL_LINKS    LINK_DIRECTORIES)
get_directory_property(ALL_DEFS     COMPILE_DEFINITIONS)

message(STATUS "${color_cyan}Include directories:${color_reset}     ${ALL_INCLUDES}")
message(STATUS "${color_cyan}Link directories:${color_reset}        ${ALL_LINKS}")
message(STATUS "${color_cyan}Compilation definitions:${color_reset} ${ALL_DEFS}")

#
# Install part
#

install(FILES LICENSE README.md AUTHORS
	DESTINATION share/coin/doc/Ipopt/)
