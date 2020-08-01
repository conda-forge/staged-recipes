# This file was taken from Hugin and modified with the included patch
# However, it proved to be difficult to integrated in the automated build
# environments.

# The Copyright of this file is held by the Hugin Developers under the GPL-2.0
# license

# require at least cmake 3.8
cmake_minimum_required(VERSION 3.8 FATAL_ERROR )

# prevent in-tree building
if("${CMAKE_SOURCE_DIR}" STREQUAL "${CMAKE_BINARY_DIR}")
    message(FATAL_ERROR "In-source builds are not allowed.")
endif()

if(COMMAND cmake_policy)
  cmake_policy(SET CMP0003 NEW)
endif(COMMAND cmake_policy)

if(APPLE)
  set(CMAKE_OSX_DEPLOYMENT_TARGET "10.9")
  if (MAC_SELF_CONTAINED_BUNDLE)
      set(CMAKE_LIBRARY_PATH ${CMAKE_SOURCE_DIR}/mac/ExternalPrograms/repository/lib)
      set(CMAKE_INCLUDE_PATH ${CMAKE_SOURCE_DIR}/mac/ExternalPrograms/repository/include ${CMAKE_SOURCE_DIR}/mac/ExternalPrograms/repository/bin)
  endif(MAC_SELF_CONTAINED_BUNDLE)
  # for FindOpenMP
  set(CMAKE_REQUIRED_INCLUDES ${CMAKE_SOURCE_DIR}/mac/ExternalPrograms/repository/include)
endif(APPLE)

set(CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/CMakeModules )

##
## Cleaner Debian Packaging (disable by -DDISABLE_DPKG=ON)
##
OPTION (DISABLE_DPKG "Do not use debian scripts to get package dependences" OFF)


IF(NOT DISABLE_DPKG)
  set(ARCH_TRIPLET)
  if(UNIX)
    FIND_PROGRAM(DPKG_ARCHITECTURE_EXECUTABLE dpkg-architecture)
    if(DPKG_ARCHITECTURE_EXECUTABLE)
      EXECUTE_PROCESS(COMMAND dpkg-architecture -qDEB_HOST_MULTIARCH
        OUTPUT_VARIABLE ARCH_TRIPLET
        ERROR_VARIABLE ERROR_ARCH_TRIPLET
        OUTPUT_STRIP_TRAILING_WHITESPACE)
    endif()
  endif()
  if(ARCH_TRIPLET)
    set(SYSTEM_LIB_DIRS /usr/lib /usr/lib/${ARCH_TRIPLET} /usr/local/lib)
  else()
    set(SYSTEM_LIB_DIRS /usr/lib /usr/local/lib)
  endif()
ENDIF()

include(HuginMacros)
include(CheckIncludeFiles)

##  global setup
project(hugin)

# version
set(V_MAJOR 2019)
set(V_MINOR 2)
set(V_PATCH 0)

#
# Check for mercurial and get current revision
#

IF(EXISTS ${PROJECT_SOURCE_DIR}/.hg)
  FIND_PACKAGE(Hg)
  IF(HG_FOUND)
    EXECUTE_PROCESS(COMMAND ${HG_EXECUTABLE} summary WORKING_DIRECTORY "${PROJECT_SOURCE_DIR}" OUTPUT_VARIABLE _release OUTPUT_STRIP_TRAILING_WHITESPACE)
    foreach(_v_l ${_release})
      if(_v_l MATCHES "^.*: *[^0-9]*\([0-9]+\):\([a-z0-9]+\)")
        set(CPACK_PACKAGE_VERSION_PATCH ${CMAKE_MATCH_1})
        set(HUGIN_WC_REVISION ${CMAKE_MATCH_2})
      endif()
    endforeach()
  ELSE()
    SET(HUGIN_WC_REVISION 0)
  ENDIF()
  SET(HUGIN_PACKAGE_VERSION ${V_MAJOR}.${V_MINOR}.${V_PATCH})
  SET(HUGIN_DEVELOPMENT_VERSION 1)
  FILE(WRITE ${PROJECT_SOURCE_DIR}/rev.txt "${HUGIN_WC_REVISION}")
  MESSAGE("-- Current HG revision is ${HUGIN_WC_REVISION}")
ELSE()
  IF (EXISTS ${PROJECT_SOURCE_DIR}/.svn)
    # comment out the following line to compile an old version from the subversion repository
    MESSAGE(FATAL_ERROR "Hugin subversion repository is not up to date. The development happens now in mercurial repository. Please switch to mercurial. Sorry for the inconsistency")
  ENDIF()

  SET(CPACK_PACKAGE_VERSION_PATCH ${V_PATCH})
  SET(HUGIN_PACKAGE_VERSION ${V_MAJOR}.${V_MINOR}.${V_PATCH})
  SET(HUGIN_WC_REVISION 0)
  FILE(READ "${PROJECT_SOURCE_DIR}/rev.txt" HUGIN_WC_REVISION)
  MESSAGE("-- Current HG revision is ${HUGIN_WC_REVISION}")
  MESSAGE("-- Assuming this is a tarball (release) build for ${HUGIN_PACKAGE_VERSION}")
  SET(HUGIN_DEVELOPMENT_VERSION 0)
ENDIF()

# version to display
IF (HUGIN_DEVELOPMENT_VERSION EQUAL 1)
  set(DISPLAY_VERSION "Pre-Release ${V_MAJOR}.${V_MINOR}.${V_PATCH}.${HUGIN_WC_REVISION}")
ELSE (HUGIN_DEVELOPMENT_VERSION EQUAL 1)
  set(DISPLAY_VERSION "${V_MAJOR}.${V_MINOR}.${V_PATCH}.${HUGIN_WC_REVISION}")
ENDIF (HUGIN_DEVELOPMENT_VERSION EQUAL 1)

# version for internal libraries.
set(HUGIN_LIB_VERSION 0.0)

# set include path for internal libraries before using finding and initializing
# external dependencies. This makes sure that "our" include paths are specified
# before any system includes

include_directories( ${CMAKE_BINARY_DIR}/src )
include_directories( ${CMAKE_SOURCE_DIR}/src/hugin_base )
include_directories( ${CMAKE_SOURCE_DIR}/src/celeste )
include_directories( ${CMAKE_BINARY_DIR}/src/celeste )
include_directories( ${CMAKE_SOURCE_DIR}/src )

# this function is not available on some systems, notably FreeBSD and Windows
include(CheckFunctionExists)
set(CMAKE_REQUIRED_LIBRARIES -lm)
check_function_exists(log1p HAVE_LOG1P)

#
# find dependencies
#
IF (UNIX)
FIND_PACKAGE(PkgConfig)
ENDIF (UNIX)

set(HUGIN_SHARED "1" CACHE STRING "Build shared internal libraries" )

#
# Setup windows search paths for dependencies
#
IF (WIN32)
  ##
  ## The directory that contains the hugin source root is a good
  ## place to look for support packages, so post it in cache.
  ## 
  ## Our FIND_PACKAGE calls modules will search SOURCE_BASE_DIR
  ## after the local standard places  
  ##
  # extract pathname from CMAKE_SOURCE_DIR (note result must be a local var)
  STRING( REGEX REPLACE "(.*)/[^/]+$" "\\1" work "${CMAKE_SOURCE_DIR}" )
  # create the cache entry
  SET( SOURCE_BASE_DIR ${work} CACHE FILEPATH "parent dir of hugin source root" )

  # wxWidgets
  IF(NOT wxWidgets_ROOT_SUFFIX)
    SET( wxWidgets_ROOT_SUFFIX 3.0.0 CACHE STRING "version of wxWidgets." FORCE )
  ENDIF(NOT wxWidgets_ROOT_SUFFIX)
  IF(NOT wxWidgets_ROOT_DIR)
    SET(wxWidgets_ROOT_DIR ${SOURCE_BASE_DIR}/wxWidgets-${wxWidgets_ROOT_SUFFIX})
  ENDIF()
ENDIF(WIN32)

##
## wxWidgets
##
#  This must come before FINDs for tiff, jpeg, png, zlib to enable
#  finding the wxWidgets distributions of those packages (Win32 only).
IF(WIN32)
  FIND_PACKAGE(wxWidgets REQUIRED base core)
  FIND_PACKAGE(wxWidgets REQUIRED base core aui)
  FIND_PACKAGE(wxWidgets REQUIRED base core aui xrc)
  FIND_PACKAGE(wxWidgets REQUIRED base core aui xrc html xml)
  FIND_PACKAGE(wxWidgets REQUIRED base core aui xrc html xml adv)
  FIND_PACKAGE(wxWidgets REQUIRED base core aui xrc html xml adv gl)
  FIND_PACKAGE(wxWidgets REQUIRED base core aui xrc html xml adv gl qa)
ELSE()
# Unix needs also wxWidgets net library
  FIND_PACKAGE(wxWidgets REQUIRED base core aui xrc html xml adv gl net qa)
ENDIF()

# hugin requires wxwidgets 3.0 or above
IF (UNIX)
  EXEC_PROGRAM(sh ARGS "${wxWidgets_CONFIG_EXECUTABLE} --version" OUTPUT_VARIABLE wxWidgets_VERSION)
  STRING(REGEX REPLACE "^([0-9]+\\.[0-9]+)\\..*" "\\1"  wxWidgets_VERSION ${wxWidgets_VERSION})
  IF(wxWidgets_VERSION VERSION_LESS "3.0")
    MESSAGE(FATAL_ERROR "At least wxWidgets 3.0 is required")
  ENDIF()
  IF(wxWidgets_VERSION VERSION_GREATER "3.1.0")
    SET(USE_XDG_DIRS 1)
  ELSE()
    UNSET(USE_XDG_DIRS)
  ENDIF()
  # Ubuntu has 2 different devel packages, we need the GUI version
  EXEC_PROGRAM(sh ARGS "${wxWidgets_CONFIG_EXECUTABLE} --query-toolkit" OUTPUT_VARIABLE wxWidgets_TOOLKIT)
  IF(wxWidgets_TOOLKIT STREQUAL "base")
    MESSAGE(FATAL_ERROR "wxWidgets is as non-GUI package configured. Check you wxWidgets installation (maybe wxgtkXX-devel is missing)")
  ENDIF()
ENDIF (UNIX)

##
## Graphics libraries
##
# wxWidgets sub-packages will be used if native ones aren't found

FIND_PACKAGE(TIFF REQUIRED)
INCLUDE_DIRECTORIES(${TIFF_INCLUDE_DIR})
FIND_PACKAGE(JPEG REQUIRED)
INCLUDE_DIRECTORIES(${JPEG_INCLUDE_DIR})
FIND_PACKAGE(PNG REQUIRED)
INCLUDE_DIRECTORIES(${ZLIB_INCLUDE_DIR})
INCLUDE_DIRECTORIES(${PNG_INCLUDE_DIR})

IF(WIN32 AND NOT HUGIN_SHARED)
IF(NOT ${WX_jpeg} MATCHES ${JPEG_LIBRARIES_RELEASE})
MESSAGE(FATAL_ERROR "Using different libjpeg and wxjpeg. This does not work with static libs. Use wxjpeg for libjpeg")
ENDIF()
IF(NOT ${WX_zlib} MATCHES ${ZLIB_LIBRARIES_RELEASE})
MESSAGE(FATAL_ERROR "Using different libzlib and wxzlib. This does not work with static libs. Use wxzlib for libzlib")
ENDIF()
IF(NOT ${WX_png} MATCHES ${PNG_LIBRARIES_RELEASE})
MESSAGE(FATAL_ERROR "Using different libpng and wxpng. This does not work with static libs. Use wxpng for libpng")
ENDIF()
IF(NOT ${WX_tiff} MATCHES ${TIFF_LIBRARIES_RELEASE})
MESSAGE(FATAL_ERROR "Using different libtiff and wxtiff. This does not work with static libs. Use wxtiff for libtiff")
ENDIF()

ENDIF()

FIND_PACKAGE(OpenEXR REQUIRED)
include_directories(${OPENEXR_INCLUDE_DIR})

FIND_PACKAGE(VIGRA 1.9.0 REQUIRED)
include_directories(${VIGRA_INCLUDE_DIR})

FIND_PACKAGE(EXIV2 REQUIRED)
INCLUDE_DIRECTORIES(${EXIV2_INCLUDE_DIR})

## OpenGL and GLEW

FIND_PACKAGE(OpenGL REQUIRED)
INCLUDE_DIRECTORIES(${OPENGL_INCLUDE_DIR})
SET(OPENGL_GLEW_LIBRARIES ${OPENGL_LIBRARIES})

IF(NOT APPLE AND NOT WIN32)
  OPTION(BUILD_WITH_EGL "Initialize OpenGL context with OpenGL ES (requires libglew with egl support)" OFF)
  IF(BUILD_WITH_EGL)
    IF(NOT OpenGL_EGL_FOUND)
      MESSAGE(FATAL_ERROR "OpenGL ES not found: Install OpenGL ES header or deactivate option BUILD_WITH_EGL")
    ENDIF()
    MESSAGE(STATUS "Use OpenGL ES")
    SET(HAVE_EGL 1)
    INCLUDE_DIRECTORIES(${OPENGL_EGL_INCLUDE_DIRS})
    SET(OPENGL_GLEW_LIBRARIES ${OPENGL_LIBRARIES} ${OPENGL_egl_LIBRARY})
  ELSE()
    UNSET(HAVE_EGL)
  ENDIF()
ENDIF()

IF (APPLE)
  FIND_PACKAGE(GLUT REQUIRED)
  INCLUDE_DIRECTORIES(${GLUT_INCLUDE_DIR})
  SET(OPENGL_GLEW_LIBRARIES ${OPENGL_GLEW_LIBRARIES} ${GLUT_LIBRARIES})
ENDIF()
FIND_PACKAGE(GLEW REQUIRED)
INCLUDE_DIRECTORIES(${GLEW_INCLUDE_DIR})
SET(OPENGL_GLEW_LIBRARIES ${OPENGL_GLEW_LIBRARIES} ${GLEW_LIBRARIES})
IF(NOT HUGIN_SHARED OR NOT WIN32)
  ADD_DEFINITIONS(-DGLEW_STATIC)
ENDIF()

IF(NOT APPLE AND NOT WIN32 AND NOT HAVE_EGL)
MESSAGE(STATUS "Searching X11 header")
FIND_PACKAGE(X11 REQUIRED)
ENDIF()
##
## Panotools
##

FIND_PACKAGE(PANO13 2.9.19 REQUIRED)

IF(PANO13_FOUND)
  SET(PANO_LIBRARIES ${PANO13_LIBRARIES})
  SET(PANO_INCLUDE_DIR ${PANO13_INCLUDE_DIR})
ELSE(PANO13_FOUND)
  MESSAGE(SEND_ERROR "libpano13 required")
ENDIF(PANO13_FOUND) 
INCLUDE_DIRECTORIES(${PANO_INCLUDE_DIR})

# Check CXX11 compiler
SET(CMAKE_CXX_STANDARD 11)
SET(CMAKE_CXX_STANDARD_REQUIRED ON)
# necessary threads lib
SET(THREADS_PREFER_PTHREAD_FLAG ON)
FIND_PACKAGE(Threads REQUIRED)

IF(WIN32)
  # for Windows Vista support
  ADD_DEFINITIONS(-DPSAPI_VERSION=1)
ENDIF(WIN32)

# check if we have C++17 <filesystem> header
INCLUDE(CheckCXXSourceCompiles)
check_cxx_source_compiles(
  "
    #include <filesystem>
    #include <string>
    
    #if defined _MSC_VER && _MSC_VER <= 1900
    namespace fs = std::tr2::sys;
    #else
    namespace fs = std::experimental::filesystem;
    #endif

    int main()
    {
      fs::path filepath;
      filepath=fs::absolute(filepath);
      std::string s=filepath.filename().string();
      return 0;    
    };
  "
  HAVE_STD_FILESYSTEM
)

IF(HAVE_STD_FILESYSTEM)
# in this combination we don't need Boost anymore
ELSE()
##
## Boost
##
# I am sick of having to edit the boost rev number in this file.
# Now it is a cache variable you can edit in cmakesetup --TKS
#
IF( NOT Boost_root_suffix )
  SET( Boost_root_suffix _1_54_0 CACHE STRING "suffix of boost root dir." FORCE )
ENDIF( NOT Boost_root_suffix )

IF(WIN32)
  IF(HUGIN_SHARED)
    SET(Boost_USE_STATIC_LIBS OFF)
    SET(Boost_USE_STATIC_RUNTIME OFF)
    # ADD_DEFINITIONS(-DBOOST_ALL_DYN_LINK)
    # ADD_DEFINITIONS(-D_DLL)
    ADD_DEFINITIONS(-DBOOST_ALL_NO_LIB)
  ELSE()
    SET(Boost_USE_STATIC_LIBS ON)
    SET(Boost_USE_STATIC_RUNTIME ON)
  ENDIF()
  # If BOOST_ROOT was defined in the environment, use it. 
  IF(NOT BOOST_ROOT AND NOT $ENV{BOOST_ROOT} STREQUAL "") 
    SET(BOOST_ROOT $ENV{BOOST_ROOT})
  ENDIF()
  IF(NOT BOOST_ROOT)
    SET(BOOST_ROOT ${SOURCE_BASE_DIR}/boost${Boost_root_suffix})
  ENDIF()
ENDIF(WIN32)

FIND_PACKAGE(Boost 1.47 COMPONENTS filesystem system)

IF (NOT Boost_FOUND)
  IF(WIN32)
    MESSAGE(FATAL_ERROR "Boost not found. Bad BOOST_ROOT? On windows, try editing Boost_root_suffix")
  ELSE()
    MESSAGE(FATAL_ERROR "Boost not found. Maybe wrong version. Hugin requires at least version 1.47")
  ENDIF()
ENDIF (NOT Boost_FOUND)

INCLUDE_DIRECTORIES(${Boost_INCLUDE_DIRS})
LINK_DIRECTORIES(${Boost_LIBRARY_DIRS})
ENDIF()

# find enblend-enfuse base path
IF(WIN32)
  FIND_PATH(ENBLEND_DIR bin/enblend.exe enblend.exe
    PATHS 
      ${SOURCE_BASE_DIR}/enblend-enfuse-4.2-win64 
      ${SOURCE_BASE_DIR}/enblend-enfuse-4.2-win32 
      ${SOURCE_BASE_DIR}/enblend-enfuse-4.1.5-win64 
      ${SOURCE_BASE_DIR}/enblend-enfuse-4.1.5-win32 
      ${SOURCE_BASE_DIR}/enblend-enfuse-4.1.4-win64 
      ${SOURCE_BASE_DIR}/enblend-enfuse-4.1.4-win32 
      ${SOURCE_BASE_DIR}/enblend-enfuse-4.1.3-win64 
      ${SOURCE_BASE_DIR}/enblend-enfuse-4.1.3-win32 
      ${SOURCE_BASE_DIR}/enblend-enfuse-4.1.2-win64 
      ${SOURCE_BASE_DIR}/enblend-enfuse-4.1.2-win32 
      ${SOURCE_BASE_DIR}/enblend-enfuse-4.1.1-win64 
      ${SOURCE_BASE_DIR}/enblend-enfuse-4.1.1-win32 
      ${SOURCE_BASE_DIR}/enblend-enfuse-4.1.1 
      ${SOURCE_BASE_DIR}/enblend-enfuse-4.1 
      ${SOURCE_BASE_DIR}/enblend-enfuse-4.0
      ${SOURCE_BASE_DIR}/enblend-3.1
      ${SOURCE_BASE_DIR}/enblend-enfuse-3.2
      ${SOURCE_BASE_DIR}/enblend.build
      ${SOURCE_BASE_DIR}/enblend
    DOC "Location of enblend"
    NO_DEFAULT_PATH
  )
  IF(NOT ENBLEND_DIR)
    MESSAGE(FATAL_ERROR "enblend-enfuse files not found.")
  ENDIF()
ENDIF()

# littleCMS 2 now
FIND_PACKAGE(LCMS2 REQUIRED)
INCLUDE_DIRECTORIES(${LCMS2_INCLUDE_DIR})
IF(WIN32)
  IF(HUGIN_SHARED AND NOT VCPKG_TOOLCHAIN)
    ADD_DEFINITIONS(-DCMS_DLL)
  ENDIF()
ENDIF()

FIND_PACKAGE(FLANN)

IF(NOT FLANN_FOUND)
  INCLUDE_DIRECTORIES(${CMAKE_SOURCE_DIR}/src/foreign)
ENDIF(NOT FLANN_FOUND)

FIND_PACKAGE(FFTW)
IF(FFTW_FOUND)
  MESSAGE(STATUS "Found FFTW library. Activated support for FFT fast cross correlation used by fine-tune feature.")
  INCLUDE_DIRECTORIES(${FFTW_INCLUDE_DIR})
  SET(HAVE_FFTW TRUE)
ELSE()
  MESSAGE(STATUS "Not found FFTW library. Deactivating support for FFT fast cross correlation used by fine-tune feature.")
ENDIF()

# Check for OpenMP
IF(APPLE)
  #we need a special search routine for mac, see changes in file CMakeModules/FindOpenMPMac.cmake
  FIND_PACKAGE(OpenMPMac)
ELSE()
  FIND_PACKAGE(OpenMP)
ENDIF()
IF(OPENMP_FOUND)
  MESSAGE(STATUS "Compiler supports OpenMP. Activating support for it.")
  ADD_COMPILE_OPTIONS(${OpenMP_CXX_FLAGS})
  SET(HAVE_OPENMP TRUE)
  IF(OpenMP_CXX_FLAGS AND NOT MSVC)
    SET(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} ${OpenMP_CXX_FLAGS}")
    SET(CMAKE_MODULE_LINKER_FLAGS "${CMAKE_MODULE_LINKER_FLAGS} ${OpenMP_CXX_FLAGS}")
    SET(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} ${OpenMP_CXX_FLAGS}")
  ENDIF()
ELSE()
  MESSAGE(WARNING "Compiler does not support OpenMP. OpenMP is required for multi-threaded processes. So only single threaded execution is compiled now.") 
ENDIF()

IF(WIN32)
  # HTML Helpworkshop for creating help file
  FIND_PACKAGE(HTMLHelp)
  IF(${HTML_HELP_COMPILER} MATCHES "-NOTFOUND")
    MESSAGE(FATAL_ERROR "MS HTML Help Workshop not found. It is required to build Hugins help file.")
  ENDIF()
ENDIF(WIN32)

FIND_PACKAGE(SQLite3 REQUIRED)
INCLUDE_DIRECTORIES(${SQLITE3_INCLUDE_DIR})

IF(UNIX)
OPTION(UNIX_SELF_CONTAINED_BUNDLE "Build a self-contained bundle under Unix systems" OFF)
ENDIF()
OPTION(BUILD_HSI "Python Scripting Interface" OFF)

IF(BUILD_HSI)
  # find Python first because the version of SWIG required depends on the
  # version of Python available
  if(WIN32)
    FIND_PACKAGE(PythonLibs 3.0 REQUIRED)
  else()
    #  Linux/MacOS
    find_package(PythonInterp 3.0 REQUIRED)
    find_package(PythonLibs ${PYTHON_VERSION_STRING} REQUIRED)
  endif()
  INCLUDE_DIRECTORIES(${PYTHON_INCLUDE_PATH})
  ADD_DEFINITIONS(-DHUGIN_HSI)
  FIND_PACKAGE(SWIG 2.0.4 REQUIRED)
  INCLUDE(${SWIG_USE_FILE})
ENDIF()

##
## LAPACK (optional, enable by -DENABLE_LAPACK=ON)
##
OPTION (ENABLE_LAPACK "Use LAPACK based solver in levmar" OFF)

IF(ENABLE_LAPACK)
  FIND_PACKAGE(LAPACK)
  IF(LAPACK_FOUND)
    MESSAGE(STATUS "LAPACK found (${LAPACK_LIBRARIES})")
  ELSE(LAPACK_FOUND)
    MESSAGE(STATUS "LAPACK not found, using LU-based solver")
  ENDIF(LAPACK_FOUND)
ENDIF(ENABLE_LAPACK)

OPTION(USE_GDKBACKEND_X11 "Enforce GDK_BACKEND=x11 for Hugin as workaround for wxWidgets bug (not supporting wxGLCanvas on Wayland)" OFF)
IF(USE_GDKBACKEND_X11)
  ADD_DEFINITIONS(-DUSE_GDKBACKEND_X11)
  MESSAGE(STATUS "Compiling Hugin with hard coded GDK_BACKEND=x11")
ENDIF()

# vips is not used right now
#IF (WIN32)
#  # todo: check for vips (not needed right now)
#ELSE (WIN32)
#  pkg_check_modules(VIPS vips-7.12)
#  LIST2STRING(VIPS_CFLAGS_OTHER VIPS_CFLAGS_OTHER_STRING)
#  LIST2STRING(VIPS_LDFLAGS_OTHER VIPS_LDFLAGS_OTHER_STRING)
#
#  pkg_check_modules(VIPSCC vipsCC-7.12)
#  LIST2STRING(VIPSCC_CFLAGS_OTHER VIPSCC_CFLAGS_OTHER_STRING)
#  LIST2STRING(VIPSCC_LDFLAGS_OTHER VIPSCC_LDFLAGS_OTHER_STRING)
#ENDIF (WIN32)
#INCLUDE_DIRECTORIES( ${VIPSCC_INCLUDE_DIRS} )
#LINK_DIRECTORIES( ${VIPSCC_LIBRARY_DIRS} )

#
# Check build type and set options accordingly
# 
IF(NOT CMAKE_BUILD_TYPE)
  SET(CMAKE_BUILD_TYPE RelWithDebInfo CACHE STRING
      "Choose the type of build, options are: None Debug Release RelWithDebInfo MinSizeRel."
      FORCE)
ENDIF(NOT CMAKE_BUILD_TYPE)

# allow user to specify lib suffix
set(LIB_SUFFIX "" CACHE STRING "Define suffix of lib directory name (32/64)" )

IF(${CMAKE_BUILD_TYPE} STREQUAL "Debug")
  MESSAGE("Building in Debug mode, resulting programs will be SLOW")
  ADD_DEFINITIONS(-DDEBUG)
  IF(UNIX)
    ADD_COMPILE_OPTIONS(-Wall)
  ENDIF(UNIX)
ENDIF(${CMAKE_BUILD_TYPE} STREQUAL "Debug")

#
# define destination dirs (relative to prefix)
#
SET(HUGINDATADIR share/hugin)
SET(DATADIR share)
SET(BINDIR  bin)

IF (NOT MANDIR AND NOT $ENV{MANDIR} STREQUAL "")
    SET (MANDIR "$ENV{MANDIR}")
ELSEIF(CMAKE_SYSTEM_NAME STREQUAL "FreeBSD" OR CMAKE_SYSTEM_NAME STREQUAL "NetBSD")
    SET (MANDIR "man")
ELSE(NOT MANDIR AND NOT $ENV{MANDIR} STREQUAL "")
    SET (MANDIR "share/man")
ENDIF(NOT MANDIR AND NOT $ENV{MANDIR} STREQUAL "")

SET(LOCALEDIR share/locale) 
SET(ICONDIR share/icons) 
SET(LINKDIR share/applications)
SET(LIBDIR  lib${LIB_SUFFIX})
SET(INSTALL_XRC_DIR ${CMAKE_INSTALL_PREFIX}/share/hugin/xrc)
SET(INSTALL_DATA_DIR ${CMAKE_INSTALL_PREFIX}/share/hugin/data)
SET(INSTALL_LOCALE_DIR ${CMAKE_INSTALL_PREFIX}/${LOCALEDIR})

IF (APPLE)
  SET(CMAKE_EXE_LINKER_FLAGS    "${CMAKE_EXE_LINKER_FLAGS} -stdlib=libc++ -lc++")
  SET(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -stdlib=libc++ -lc++")
  # setup bundle install prefix
  IF (NOT MAC_SELF_CONTAINED_BUNDLE)
    IF (CMAKE_INSTALL_PREFIX STREQUAL "/opt/local")
      # MacPorts
      SET(INSTALL_OSX_BUNDLE_DIR /Applications/MacPorts CACHE DOCSTRING "Install directory Hugin and HuginStitchProject application bundles")
    ELSE(CMAKE_INSTALL_PREFIX STREQUAL "/opt/local")
      # fink or other custom system.
      SET(INSTALL_OSX_BUNDLE_DIR ${CMAKE_INSTALL_PREFIX}/Applications CACHE DOCSTRING "Install directory Hugin and HuginStitchProject application bundles")
    ENDIF(CMAKE_INSTALL_PREFIX STREQUAL "/opt/local")
    MESSAGE("*** Will install application bundles in ${INSTALL_OSX_BUNDLE_DIR}, set INSTALL_OSX_BUNDLE_DIR to change the location")
  ENDIF (NOT MAC_SELF_CONTAINED_BUNDLE)
ENDIF (APPLE)

IF (HUGIN_SHARED AND UNIX AND NOT APPLE)
  SET(CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/${LIBDIR}/hugin")
  SET(HUGIN_LIBS_PRIVATE_DIR "1" CACHE INTERNAL "Store internal
    libraries in private subdirectory" )
ELSE ()
  # On OS X files are moved around after make install, do not try to use
  # rpath or CMAKE_INSTALL_NAME_DIR
  SET(HUGIN_LIBS_PRIVATE_DIR "0" CACHE INTERNAL "Store internal
    libraries in private subdirectory" )
ENDIF()

IF (UNIX)
  IF (HUGIN_SHARED)
    # use shared internal libraries
    SET(HUGIN_SHARED_LIBS 1)
  ENDIF (HUGIN_SHARED)
  MESSAGE("-- Using shared internal libraries")
ELSE()

  IF (HUGIN_SHARED)
    ADD_DEFINITIONS(-DOPENEXR_DLL)
    ADD_DEFINITIONS(-DEXV_HAVE_DLL)
    ADD_DEFINITIONS(-DHugin_shared)
    ADD_DEFINITIONS(-DPANO13_DLL)
    SET(HUGIN_SHARED_LIBS 1)
  ELSE()
    ADD_DEFINITIONS(-DVIGRA_STATIC_LIB)
  ENDIF()

  # Windows installer packaging related stuff
  # unfortunately, CMake/CPack does not support Warsetup directly.
  # prepare files here...
  IF(WIN32)
    # install into place in build-dir
    SET( CMAKE_INSTALL_PREFIX ${CMAKE_CURRENT_BINARY_DIR}/INSTALL/FILES CACHE FILEPATH "install prefix")
    INCLUDE (win_bundle)
	
	#Build HuginSetup
	OPTION (BUILD_HUGINSETUP "Build HuginSetup (NSIS Installer)" OFF)
    IF(BUILD_HUGINSETUP)
      FIND_PACKAGE(NSIS REQUIRED)
      IF(NSIS_FOUND)
        MESSAGE(STATUS "NSIS found (${MAKENSIS_EXECUTABLE})")
      ELSE(NSIS_FOUND)
        MESSAGE(STATUS "NSIS not found")
      ENDIF(NSIS_FOUND)
      ADD_CUSTOM_TARGET(HuginSetup COMMAND cd .. & ${MAKENSIS_EXECUTABLE} HuginSetup.nsi WORKING_DIRECTORY ${CMAKE_INSTALL_PREFIX})
    ENDIF(BUILD_HUGINSETUP)
  ENDIF(WIN32)

  IF (MSVC)
    # Stop MSVC8 from bitching about the C library
    ADD_DEFINITIONS(/D_CRT_SECURE_NO_DEPRECATE)
    # Stop MSVC9 from bitching about possibly invalid STL usage
    ADD_DEFINITIONS(/D_SCL_SECURE_NO_WARNINGS)
    # Stop MSVC9 from bitching about POSIX names without underscores
    ADD_DEFINITIONS(/D_CRT_NONSTDC_NO_DEPRECATE)
    # Show information about auto-linking library files during build, .e.g.
    # "Linking to lib file: libboost_thread-vc90-mt-s-1_37.lib"
    # This can be used to determine on which boost libraries Hugin depend on
    #ADD_DEFINITIONS(/DBOOST_LIB_DIAGNOSTIC)
    IF(NOT HUGIN_SHARED)
      # compile everything for the static C runtime
      FOREACH(TYPE C CXX)
        # makefiles use blank configuration
        FOREACH(CFG "_DEBUG" "_MINSIZEREL" "_RELEASE" "_RELWITHDEBINFO")
          #MESSAGE("Replacing CMAKE_${TYPE}_FLAGS${CFG}: ${CMAKE_${TYPE}_FLAGS${CFG}}")
          SET(NEW_FLAGS "${CMAKE_${TYPE}_FLAGS${CFG}}")
          # fix up static libc flags
          STRING(REPLACE "/MD" "/MT" NEW_FLAGS "${NEW_FLAGS}")
          # *FORCE* to override whats already placed into the cache
          SET(CMAKE_${TYPE}_FLAGS${CFG} "${NEW_FLAGS}" CACHE STRING "CMAKE_${TYPE}_FLAGS${CFG} (overwritten to ensure static build)" FORCE)
          #MESSAGE("New       CMAKE_${TYPE}_FLAGS${CFG}: ${CMAKE_${TYPE}_FLAGS${CFG}}")
        ENDFOREACH(CFG)
      ENDFOREACH(TYPE)
      # link only with the static C runtime !! THIS IS A MUST !!
      SET(NEW_FLAGS "${CMAKE_EXE_LINKER_FLAGS}")
      # ensure that the flags are not duplicaated on subsequent runs
      STRING(REPLACE " /NODEFAULTLIB:\"MSVCRT.lib\" /NODEFAULTLIB:\"MSVCRTd.lib\"" "" NEW_FLAGS "${NEW_FLAGS}")
      # note that flag names (NODEFAULTLIB) etc.) are case sensitive
      SET( CMAKE_EXE_LINKER_FLAGS
        "${NEW_FLAGS} /NODEFAULTLIB:\"MSVCRT.lib\" /NODEFAULTLIB:\"MSVCRTd.lib\""
        CACHE STRING "for MSVC" FORCE
      )
      FOREACH(CFG "MINSIZEREL" "RELEASE" "RELWITHDEBINFO")
        SET(NEW_FLAGS "${CMAKE_EXE_LINKER_FLAGS_${CFG}}")
        STRING(REPLACE " /LTCG" "" NEW_FLAGS "${NEW_FLAGS}")
        SET(CMAKE_EXE_LINKER_FLAGS_${CFG} "${NEW_FLAGS} /LTCG" CACHE STRING "overwritten" FORCE)
      ENDFOREACH()
      SET(NEW_FLAGS "${CMAKE_EXE_LINKER_FLAGS_RELWITHDEBINFO}")
      STRING(REPLACE " /INCREMENTAL:NO" "" NEW_FLAGS "${NEW_FLAGS}")
      STRING(REPLACE " /INCREMENTAL" "" NEW_FLAGS "${NEW_FLAGS}")
      SET(CMAKE_EXE_LINKER_FLAGS_RELWITHDEBINFO "${NEW_FLAGS} /INCREMENTAL:NO" CACHE STRING "overwritten" FORCE)
    ENDIF()
  ENDIF()
ENDIF ()

IF(APPLE)

  IF(MAC_SELF_CONTAINED_BUNDLE)
    SET(CMAKE_MACOSX_RPATH FALSE) 

    ADD_CUSTOM_TARGET(Mac ALL)
    SET(APPS Hugin PTBatcherGUI calibrate_lens_gui HuginStitchProject)
    SET(APPS_DIR ${CMAKE_BINARY_DIR}/src/hugin1/hugin
                 ${CMAKE_BINARY_DIR}/src/hugin1/ptbatcher
                 ${CMAKE_BINARY_DIR}/src/hugin1/calibrate_lens
                 ${CMAKE_BINARY_DIR}/src/hugin1/stitch_project )

    foreach(_var RANGE 0 3)
      LIST(GET APPS ${_var} _target)
      LIST(GET APPS_DIR ${_var} _target_dir)
      ADD_DEPENDENCIES(Mac ${_target})
      ADD_CUSTOM_COMMAND(
        TARGET Mac
        COMMAND bash ${CMAKE_SOURCE_DIR}/mac/PackageMacAppBundleLibs.sh
        ARGS ${_target} ${_target_dir} ${CMAKE_SOURCE_DIR}
      )
    ENDFOREACH(_var)

    ADD_CUSTOM_COMMAND(
      TARGET Mac
      POST_BUILD
      COMMAND ${CMAKE_SOURCE_DIR}/mac/PackageCreateToolsLibs.sh
      ARGS ${CMAKE_CURRENT_BINARY_DIR}/tools_mac
        align_image_stack autooptimiser celeste_standalone checkpto cpclean cpfind
        deghosting_mask fulla geocpset hugin_executor hugin_lensdb hugin_stacker
        icpfind linefind pano_modify pano_trafo pto_gen pto_lensstack pto_mask pto_merge
        pto_move pto_template pto_var tca_correct vig_optimize
        :enblend :enfuse :hugin_hdrmerge :nona :verdandi)

    INSTALL( DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/tools_mac
             DESTINATION Hugin 
             COMPONENT "tools_mac"
             FILE_PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE
             PATTERN .DS_Store EXCLUDE )

  ENDIF(MAC_SELF_CONTAINED_BUNDLE)

  
  ADD_DEFINITIONS(-D__ASSERT_MACROS_DEFINE_VERSIONS_WITHOUT_UNDERSCORES=0)

  #This namespace workaround is not needed for CMake >= 2.5.x
  ## Add needed Compiler and Linker flags for OSX
  IF (CMAKE_COMPILER_IS_GNUCC OR CMAKE_COMPILER_IS_GNUCXX)
      SET (CMAKE_C_FLAGS:STRING "\"$CMAKE_C_FLAGS\" -flat_namespace -undefined suppress" )
      SET (CMAKE_CXX_FLAGS:STRING "\"$CMAKE_CXX_FLAGS\" -flat_namespace -undefined suppress" )
      SET (CMAKE_LDFLAGS:STRING "\"$CMAKE_LD_FLAGS\"" )
      SET (CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS}  -flat_namespace -undefined suppress" )
      SET (CMAKE_MODULE_LINKER_FLAGS "${CMAKE_MODULE_LINKER_FLAGS}  -flat_namespace -undefined suppress" )
      SET (CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS}  -flat_namespace -undefined suppress" )
      SET (CMAKE_INSTALL_NAME_DIR "${CMAKE_INSTALL_PREFIX}/lib" )
    IF (${CMAKE_BUILD_TYPE} STREQUAL "Release")
      SET (CMAKE_C_FLAGS_RELEASE:STRING " $CMAKE_C_FLAGS_RELEASE ")
      SET (CMAKE_CXX_FLAGS_RELEASE:STRING " $CMAKE_CXX_FLAGS_RELEASE ")
    ENDIF (${CMAKE_BUILD_TYPE} STREQUAL "Release")
  ENDIF (CMAKE_COMPILER_IS_GNUCC OR CMAKE_COMPILER_IS_GNUCXX)
ENDIF (APPLE)


# create config.h file
configure_file(src/hugin_config.h.in.cmake ${CMAKE_BINARY_DIR}/src/hugin_config.h)
configure_file(src/hugin_version.h.in.cmake ${CMAKE_BINARY_DIR}/src/hugin_version.h)

add_subdirectory(src)
add_subdirectory(doc)
# install enfuse droplets and windows installer and everything else in platforms
ADD_SUBDIRECTORY(platforms)

SET(CPACK_PACKAGE_VERSION_MAJOR "${V_MAJOR}")
SET(CPACK_PACKAGE_VERSION_MINOR "${V_MINOR}")

IF(NOT DISABLE_DPKG)
  SET(CPACK_PACKAGE_VERSION_PATCH "${V_PATCH}.${CPACK_PACKAGE_VERSION_PATCH}")
ELSE()
  SET(CPACK_PACKAGE_VERSION_PATCH "${V_PATCH}.${CPACK_PACKAGE_VERSION_PATCH}.local")
ENDIF()

SET(CPACK_SOURCE_PACKAGE_FILE_NAME "hugin-${V_MAJOR}.${V_MINOR}.${V_PATCH}")
SET(CPACK_SOURCE_GENERATOR "TBZ2")
SET(CPACK_PACKAGE_CONTACT "hugin-ptx@googlegroups.com")
IF(NOT WIN32)
  SET(CPACK_SET_DESTDIR "ON")
ENDIF()
SET(CPACK_SOURCE_IGNORE_FILES
"/_CPack_Packages/"
"/CMakeCache.txt$"
"\\\\.dir/"
"\\\\.tar\\\\.gz$"
"\\\\.tar\\\\.bz2$"
"\\\\.tar\\\\.Z$"
"\\\\.svn/"
"\\\\.cvsignore$"
"\\\\.swp$"
"~$"
"\\\\.#"
"/#"
"/src/api-doc/"
"/celeste/celeste_standalone$"
"/celeste/Config.h$"
"/celeste/training/celeste_train$"
"/tools/autooptimiser$"
"/tools/fulla$"
"/tools/nona$"
"/tools/vig_optimize$"
"/tools/align_image_stack$"
"/tools/tca_correct$"
"/tools/pto2mk$"
"/tools/hugin_hdrmerge$"
"/ptbatcher/PTBatcher$"
"/ptbatcher/PTBatcherGUI$"
"/hugin_base/test/open_file$"
"/matchpoint/matchpoint$"
"/hugin/hugin$"
"/whitepaper/"
"/lens_calibrate/test_lensFunc$"
"/lens_calibrate/calibrate_lens$"
"/nona_gui/nona_gui$"
"/stitch_project/hugin_stitch_project$"
"/deghosting/deghosting_mask$" 
"/outdated/"
"/build/"
"/CVS/"
"/cmake_install.cmake$"
"/CMakeOutput.log$"
"/CPackConfig.cmake$"
"/CPackSourceConfig.cmake$"
"/Makefile$"
"/Makefile2$"
"/CMakeFiles/"
"/\\\\.libs/"
"/\\\\.deps/"
"\\\\.o$"
"\\\\.gmo$"
"\\\\.mo$"
"\\\\.a$"
"\\\\.lo$"
"\\\\.so$"
"\\\\.so\\\\.0$" 
"\\\\.so\\\\.0\\\\.0$" 
"\\\\.la$"
"Makefile\\\\.in$"
"/\\\\.hg/"
"/artwork-src/"
"\\\\.hgignore$"
"\\\\.hgtags$"
 )

IF(NOT DISABLE_DPKG)
  # Use dpkg-shlibdeps to get the needed dependences
  SET(CPACK_DEBIAN_PACKAGE_SHLIBDEPS ON)

  # the following part copied from http://www.cmake.org/Wiki/CMake_RPATH_handling
  # use, i.e. don't skip the full RPATH for the build tree
  SET(CMAKE_SKIP_BUILD_RPATH  FALSE)
  # when building, don't use the install RPATH already
  # (but later on when installing)
  SET(CMAKE_BUILD_WITH_INSTALL_RPATH FALSE) 

  SET(CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/lib/hugin")
  SET(CPACK_DEBIAN_PACKAGE_DEBUG ON)

  # add the automatically determined parts of the RPATH
  # which point to directories outside the build tree to the install RPATH
  SET(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)


  # the RPATH to be used when installing, but only if it's not a system directory
  LIST(FIND CMAKE_PLATFORM_IMPLICIT_LINK_DIRECTORIES "${CMAKE_INSTALL_PREFIX}/lib/hugin" isSystemDir)
  IF("${isSystemDir}" STREQUAL "-1")
     SET(CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/lib/hugin")
  ENDIF("${isSystemDir}" STREQUAL "-1")

  #this environment will be used by dpkg-shlibdebs to find local created libs
  string(REGEX REPLACE "^/(.*)" "\\1" LDLIBPATH "${CMAKE_INSTALL_RPATH}")
  #message(STATUS "CMAKE_INSTALL_RPATH set to ${CMAKE_INSTALL_RPATH}")
  #message(STATUS "LDLIBPATH = ${LDLIBPATH}")
  set(CPACK_PROJECT_CONFIG_FILE "${CMAKE_BINARY_DIR}/CPackEnv.cmake")
  FILE(WRITE "${CPACK_PROJECT_CONFIG_FILE}" "set(ENV{LD_LIBRARY_PATH} \"${LDLIBPATH}\")")

ELSE()
  # incomplete manually set dependencies but we don't really care since this package is not for distribution
  # and whoever use the DISABLE_DPKG option knows what they are doing
  SET(CPACK_DEBIAN_PACKAGE_DEPENDS "libpano13(>=2.9.17)")
ENDIF()

# ignore some directories when creating rpm
SET(CPACK_RPM_SPEC_MORE_DEFINE "%define ignore \#")
SET(CPACK_RPM_USER_FILELIST 
  "%ignore /usr/local"
  "%ignore /usr/local/bin" 
  "%ignore /usr/local/lib" 
  "%ignore /usr/local/share" 
  "%ignore /usr/local/share/applications" 
  "%ignore /usr/local/share/man" 
  "%ignore /usr/local/share/man/man1"
  "%ignore /usr/lib/python2.7"
  "%ignore /usr/lib/python2.7/site-packages"
)

message(STATUS "Current source dir = ${CMAKE_CURRENT_SOURCE_DIR}")
SET(CPACK_DEBIAN_PACKAGE_CONTROL_EXTRA "${CMAKE_CURRENT_SOURCE_DIR}/Debian/postinst"
				       "${CMAKE_CURRENT_SOURCE_DIR}/Debian/shlibs.local")


IF(APPLE)
  SET(CPACK_PACKAGE_NAME "Hugin")
  SET(CPACK_GENERATOR "DragNDrop")
  SET(CPACK_DMG_FORMAT "UDBZ")
  SET(CPACK_COMPONENTS_ALL tools_mac Hugin PTBatcherGUI calibrate_lens_gui HuginStitchProject)
  SET(CPACK_SYSTEM_NAME "Mac")
  SET(CPACK_PACKAGE_FILE_NAME "Hugin-${V_MAJOR}.${V_MINOR}.${V_PATCH}")

  #has to be 72dpi
  SET(CPACK_DMG_BACKGROUND_IMAGE "${CMAKE_SOURCE_DIR}/mac/DmgBackground.jpg")

  SET(CPACK_DMG_DS_STORE_SETUP_SCRIPT "${CMAKE_SOURCE_DIR}/mac/DmgScript.scpt")
  # SET(CPACK_DMG_DS_STORE "${CMAKE_SOURCE_DIR}/mac/DmgDS_Store.in")

ENDIF(APPLE)

IF(MSVC)
# configure variables for wix toolset generator
MATH(EXPR VERSION_WIN_MAJOR "${V_MAJOR}/100")
MATH(EXPR VERSION_WIN_MINOR "${V_MAJOR}%100")
SET(CPACK_PACKAGE_VERSION_MAJOR "${VERSION_WIN_MAJOR}")
SET(CPACK_PACKAGE_VERSION_MINOR "${VERSION_WIN_MINOR}")
SET(CPACK_PACKAGE_VERSION_PATCH "${V_MINOR}")
SET(CPACK_RESOURCE_FILE_LICENSE "${CMAKE_SOURCE_DIR}/COPYING.txt")
IF(CMAKE_SIZEOF_VOID_P EQUAL 8)
  # 64 bit version
  SET(CPACK_WIX_UPGRADE_GUID "1B85EFEB-F843-49C6-80D3-A539B035D319")
ELSE()
  # 32 bit version
  SET(CPACK_WIX_UPGRADE_GUID "F33AD91A-C09A-4C6E-A027-D56611228094")
ENDIF()
# installing to start menu requires at least CMake 3.3
cmake_minimum_required(VERSION 3.3.0 FATAL_ERROR )
SET(CPACK_WIX_PROGRAM_MENU_FOLDER Hugin)
SET(CPACK_WIX_UI_DIALOG "${CMAKE_SOURCE_DIR}/platforms/windows/wix/big_banner.bmp")
SET(CPACK_WIX_UI_BANNER "${CMAKE_SOURCE_DIR}/platforms/windows/wix/top_banner.bmp")
SET(CPACK_WIX_PRODUCT_ICON "${CMAKE_SOURCE_DIR}/src/hugin1/hugin/xrc/data/hugin.ico")
SET(CPACK_PACKAGE_INSTALL_DIRECTORY "Hugin")
SET(CPACK_PACKAGE_NAME "Hugin")
SET(CPACK_PACKAGE_VENDOR "Hugin developer team")
SET(CPACK_PACKAGE_DESCRIPTION_SUMMARY "Hugin - Panorama photo stitcher")
IF(MSVC_VERSION EQUAL 1900)
  IF(CMAKE_SIZEOF_VOID_P EQUAL 8)
    SET(CPACK_WIX_EXTRA_SOURCES 
      "${CMAKE_SOURCE_DIR}/platforms/windows/wix/redist_vc14_x64.wxs"
      "${CMAKE_SOURCE_DIR}/platforms/windows/wix/filetype.wxs"
    )
  ELSE()
    SET(CPACK_WIX_EXTRA_SOURCES
      "${CMAKE_SOURCE_DIR}/platforms/windows/wix/redist_vc14_x86.wxs"
      "${CMAKE_SOURCE_DIR}/platforms/windows/wix/filetype.wxs"
    )
  ENDIF()
  SET(CPACK_WIX_PATCH_FILE "${CMAKE_SOURCE_DIR}/platforms/windows/wix/redist.xml")
ELSEIF(MSVC_VERSION GREATER_EQUAL 1910)
  IF(CMAKE_SIZEOF_VOID_P EQUAL 8)
    SET(CPACK_WIX_EXTRA_SOURCES 
      "${CMAKE_SOURCE_DIR}/platforms/windows/wix/redist_vc15_x64.wxs"
      "${CMAKE_SOURCE_DIR}/platforms/windows/wix/filetype.wxs"
    )
  ELSE()
    SET(CPACK_WIX_EXTRA_SOURCES
      "${CMAKE_SOURCE_DIR}/platforms/windows/wix/redist_vc15_x86.wxs"
      "${CMAKE_SOURCE_DIR}/platforms/windows/wix/filetype.wxs"
    )
  ENDIF()
  SET(CPACK_WIX_PATCH_FILE "${CMAKE_SOURCE_DIR}/platforms/windows/wix/redist.xml")
ELSE()
  SET(CPACK_WIX_EXTRA_SOURCES "${CMAKE_SOURCE_DIR}/platforms/windows/wix/filetype.wxs")
  SET(CPACK_WIX_PATCH_FILE "${CMAKE_SOURCE_DIR}/platforms/windows/wix/filetype.xml")
ENDIF()
ENDIF()

INCLUDE(CPack)

##
## Uninstall Taget
##
CONFIGURE_FILE(
  "${CMAKE_CURRENT_SOURCE_DIR}/cmake_uninstall.cmake.in"
  "${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake"
  IMMEDIATE @ONLY)

ADD_CUSTOM_TARGET(uninstall
  "${CMAKE_COMMAND}" -P "${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake")

