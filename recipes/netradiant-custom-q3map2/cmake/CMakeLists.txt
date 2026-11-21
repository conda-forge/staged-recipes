# Standalone CMake build for q3map2 out of a netradiant-custom source tree.
#
# Upstream only ships a GNU Makefile which builds the whole editor and
# relies on a POSIX shell (and MSYS2 on Windows). This project builds just
# the q3map2 executable with a toolchain-agnostic generator (Ninja), so the
# same build works on Linux, macOS and Windows (MinGW-w64 GCC).
#
# To stay in sync with upstream, the lists of source files are not
# duplicated here, but extracted from upstream's Makefile at configure time.
#
# Usage: either copy this file into the root of a netradiant-custom source
# tree (which keeps object file paths short, important on Windows), or point
# to the sources explicitly:
#   cmake -S <this dir> -B build -G Ninja \
#         -DNETRADIANT_SOURCE_DIR=<path to netradiant-custom checkout>

cmake_minimum_required(VERSION 3.21)

project(q3map2 LANGUAGES C CXX)

set(NETRADIANT_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}" CACHE PATH "Path to the netradiant-custom source tree")
set(Q3MAP2_VERSION_SUFFIX "" CACHE STRING "Optional suffix appended to the q3map2 version string")

# The vendored assimp is a patched fork which upstream can build itself.
# conda-forge's assimp is built with MSVC on Windows, whose C++ ABI is not
# compatible with MinGW GCC - hence the vendored copy is used there.
if(WIN32)
  set(_q3map2_vendored_assimp_default ON)
else()
  set(_q3map2_vendored_assimp_default OFF)
endif()
option(Q3MAP2_VENDORED_ASSIMP "Build and statically link the assimp copy shipped with netradiant-custom"
       ${_q3map2_vendored_assimp_default})

if(NOT NETRADIANT_SOURCE_DIR)
  message(FATAL_ERROR "NETRADIANT_SOURCE_DIR must point to a netradiant-custom source tree")
endif()
# Normalize Windows backslashes, which would otherwise act as escapes below
file(TO_CMAKE_PATH "${NETRADIANT_SOURCE_DIR}" NR)
if(NOT EXISTS "${NR}/Makefile" OR NOT EXISTS "${NR}/tools/quake3/q3map2/main.cpp")
  message(FATAL_ERROR "'${NR}' does not look like a netradiant-custom source tree")
endif()

# Upstream's flags apply only to GCC-compatible compilers (GCC / Clang)
if(NOT CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
  message(FATAL_ERROR "q3map2 requires GCC or Clang, got '${CMAKE_CXX_COMPILER_ID}'")
endif()

if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
  set(CMAKE_BUILD_TYPE Release CACHE STRING "Build type" FORCE)
endif()

# --------------------------------------------------------------------------
# Upstream Makefile parsing
# --------------------------------------------------------------------------

file(READ "${NR}/Makefile" NR_MAKEFILE)
string(REPLACE "\r\n" "\n" NR_MAKEFILE "${NR_MAKEFILE}")
# Semicolons would be interpreted as CMake list separators
string(REPLACE ";" "" NR_MAKEFILE "${NR_MAKEFILE}")

# Reads the value of a simple 'NAME = value' assignment from the Makefile
function(nr_makefile_variable name out_var)
  if(NOT NR_MAKEFILE MATCHES "\n${name}[ \t]*=[ \t]*([^\n]*)\n")
    message(FATAL_ERROR "Variable '${name}' not found in ${NR}/Makefile")
  endif()
  string(STRIP "${CMAKE_MATCH_1}" value)
  set(${out_var} "${value}" PARENT_SCOPE)
endfunction()

# Extracts the prerequisites of a Makefile rule of the form
#
#   <target>: \
#   	path/to/object.o \
#   	path/to/source.cc \
#   	libfoo.$(A) \
#   	$(if ...) \
#
# Object files are mapped back onto their source files. 'lib<name>.$(A)'
# prerequisites are returned separately as '<name>' (static helper
# libraries), conditional '$(...)' and order-only '|' entries are skipped.
function(nr_makefile_prerequisites target out_sources out_libs)
  set(header "\n${target}: \\\n")
  string(FIND "${NR_MAKEFILE}" "${header}" pos)
  if(pos EQUAL -1)
    message(FATAL_ERROR "Rule '${target}' not found in ${NR}/Makefile")
  endif()
  string(LENGTH "${header}" header_len)
  math(EXPR start "${pos} + ${header_len}")
  string(SUBSTRING "${NR_MAKEFILE}" ${start} -1 rest)

  # A rule's prerequisite list ends with the first empty line
  string(FIND "${rest}" "\n\n" end)
  string(SUBSTRING "${rest}" 0 ${end} block)
  # Drop the line continuation backslashes first, as a '\' in front of the
  # ';' list separator would escape it and prevent splitting into lines
  string(REPLACE "\\\n" "\n" block "${block}")
  string(REGEX REPLACE "\\\\$" "" block "${block}")
  string(REPLACE "\n" ";" lines "${block}")

  set(sources "")
  set(libs "")
  foreach(line IN LISTS lines)
    string(STRIP "${line}" line)
    if(line STREQUAL "")
      continue()
    elseif(line MATCHES "^lib([A-Za-z0-9_]+)\\.\\$\\(A\\)$")
      list(APPEND libs "${CMAKE_MATCH_1}")
    elseif(line MATCHES "[$|]")
      continue()
    elseif(line MATCHES "^(.+)\\.o$")
      set(base "${CMAKE_MATCH_1}")
      set(found "")
      foreach(ext cpp c cc)
        if(EXISTS "${NR}/${base}.${ext}")
          set(found "${NR}/${base}.${ext}")
          break()
        endif()
      endforeach()
      if(NOT found)
        message(FATAL_ERROR "No source file found for '${line}' (rule '${target}')")
      endif()
      list(APPEND sources "${found}")
    elseif(line MATCHES "\\.(c|cc|cpp)$")
      list(APPEND sources "${NR}/${line}")
    else()
      message(FATAL_ERROR "Unexpected prerequisite '${line}' of rule '${target}'")
    endif()
  endforeach()

  if(NOT sources)
    message(FATAL_ERROR "No sources found for rule '${target}'")
  endif()
  set(${out_sources} "${sources}" PARENT_SCOPE)
  set(${out_libs} "${libs}" PARENT_SCOPE)
endfunction()

# --------------------------------------------------------------------------
# Versioning (mirrors the variables in upstream's Makefile)
# --------------------------------------------------------------------------

nr_makefile_variable(Q3MAP_VERSION Q3MAP2_VERSION)
nr_makefile_variable(RADIANT_VERSION_NUMBER RADIANT_VERSION_NUMBER)
nr_makefile_variable(RADIANT_MAJOR_VERSION RADIANT_MAJOR_VERSION)
nr_makefile_variable(RADIANT_MINOR_VERSION RADIANT_MINOR_VERSION)
# Upstream appends "-git-<hash>" here, a configurable suffix is used instead
if(Q3MAP2_VERSION_SUFFIX)
  string(APPEND Q3MAP2_VERSION "-${Q3MAP2_VERSION_SUFFIX}")
endif()
set(RADIANT_VERSION "${RADIANT_VERSION_NUMBER}n")
message(STATUS "q3map2 version: ${Q3MAP2_VERSION} (NetRadiant ${RADIANT_VERSION})")

# --------------------------------------------------------------------------
# Compiler flags (mirrors CFLAGS_COMMON / CXXFLAGS_COMMON / CPPFLAGS_COMMON)
# --------------------------------------------------------------------------

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Restricted to C/C++, as these must not reach windres (RC) on Windows
add_compile_options(
  "$<$<COMPILE_LANGUAGE:C,CXX>:-W;-Wall;-Wcast-align;-Wcast-qual;-Wno-unused-parameter;-Wno-unused-function>"
  "$<$<COMPILE_LANGUAGE:C,CXX>:-fno-strict-aliasing>"
  "$<$<COMPILE_LANGUAGE:CXX>:-Wreorder;-fno-exceptions;-fno-rtti>"
)

# Reproducible builds: q3map2 embeds source paths via __FILE__, so make
# them relative to the source tree instead of depending on its location
add_compile_options("$<$<COMPILE_LANGUAGE:C,CXX>:-ffile-prefix-map=${NR}=.>")

if(WIN32)
  add_compile_definitions(WIN32 _WIN32 _inline=inline)
  add_compile_options("$<$<COMPILE_LANGUAGE:C,CXX>:-mms-bitfields>")
else()
  add_compile_definitions(POSIX XWINDOWS)
endif()

# --------------------------------------------------------------------------
# Dependencies
# --------------------------------------------------------------------------

find_package(Threads REQUIRED)
find_package(ZLIB REQUIRED)
find_package(PNG REQUIRED)
find_package(JPEG REQUIRED)
find_package(LibXml2 REQUIRED)

# glib does not provide a CMake package and pkg-config is not reliably
# available on every platform, so locate it manually
find_path(GLIB_INCLUDE_DIR glib.h PATH_SUFFIXES glib-2.0 REQUIRED)
find_library(GLIB_LIBRARY NAMES glib-2.0 REQUIRED)
get_filename_component(_glib_library_dir "${GLIB_LIBRARY}" DIRECTORY)
find_path(GLIBCONFIG_INCLUDE_DIR glibconfig.h
  HINTS "${_glib_library_dir}/glib-2.0/include"
  PATH_SUFFIXES glib-2.0/include
  REQUIRED)
add_library(q3map2_glib INTERFACE)
target_include_directories(q3map2_glib INTERFACE "${GLIB_INCLUDE_DIR}" "${GLIBCONFIG_INCLUDE_DIR}")
target_link_libraries(q3map2_glib INTERFACE "${GLIB_LIBRARY}")

if(Q3MAP2_VENDORED_ASSIMP)
  # Mirrors upstream's ASSIMP_INTERNAL=yes build ($(INSTALLDIR)/libassimp_),
  # but as a static library to avoid shipping/locating an extra DLL
  nr_makefile_prerequisites("$(INSTALLDIR)/libassimp_.$(DLL)" assimp_sources _unused)
  add_library(q3map2_assimp STATIC ${assimp_sources})
  set(_assimp "${NR}/libs/assimp")
  target_include_directories(q3map2_assimp
    PUBLIC "${_assimp}/include"
    PRIVATE
      "${_assimp}/code" "${_assimp}/contrib/pugixml/src" "${_assimp}/contrib/unzip" "${_assimp}"
      "${_assimp}/contrib/openddlparser/include" "${_assimp}/contrib/rapidjson/include" "${_assimp}/contrib")
  target_compile_definitions(q3map2_assimp PRIVATE
    ASSIMP_BUILD_NO_C4D_IMPORTER ASSIMP_BUILD_NO_EXPORT ASSIMP_BUILD_NO_IFC_IMPORTER
    ASSIMP_BUILD_NO_OWN_ZLIB ASSIMP_IMPORTER_GLTF_USE_OPEN3DGC=1 MINIZ_USE_UNALIGNED_LOADS_AND_STORES=0
    OPENDDLPARSER_BUILD RAPIDJSON_HAS_STDSTRING=1 RAPIDJSON_NOMEMBERITERATORCLASS WIN32_LEAN_AND_MEAN)
  # assimp itself needs exceptions and RTTI (overrides the common flags)
  target_compile_options(q3map2_assimp PRIVATE -Wno-long-long -fexceptions -frtti -Wno-cast-qual)
  target_link_libraries(q3map2_assimp PUBLIC ZLIB::ZLIB)
  # Upstream includes the vendored headers by quoted path in this mode
  set(Q3MAP2_ASSIMP_INCLUDE "#x")
  set(Q3MAP2_ASSIMP_TARGET q3map2_assimp)
else()
  find_package(assimp CONFIG REQUIRED)
  set(Q3MAP2_ASSIMP_INCLUDE "<x>")
  set(Q3MAP2_ASSIMP_TARGET assimp::assimp)
endif()

# --------------------------------------------------------------------------
# q3map2
# --------------------------------------------------------------------------

nr_makefile_prerequisites("$(INSTALLDIR)/q3map2.$(EXE)" q3map2_sources q3map2_libs)

# Internal static helper libraries (libcrnlib, libddslib, ...), all of which
# use 'CPPFLAGS_EXTRA := -Ilibs' upstream
set(q3map2_lib_targets "")
foreach(lib IN LISTS q3map2_libs)
  nr_makefile_prerequisites("lib${lib}.$(A)" lib_sources _unused)
  add_library(q3map2_${lib} STATIC ${lib_sources})
  target_include_directories(q3map2_${lib} PRIVATE "${NR}/libs")
  list(APPEND q3map2_lib_targets q3map2_${lib})
endforeach()

# Version strings and the ASSIMP_INCLUDE() macro are passed via a forced
# include instead of -D flags, as quotes and angle brackets do not survive
# command line quoting on every platform/shell
set(Q3MAP2_CONFIG_HEADER "${CMAKE_CURRENT_BINARY_DIR}/q3map2_build_config.h")
file(WRITE "${Q3MAP2_CONFIG_HEADER}.in"
"#pragma once
#define Q3MAP_VERSION \"@Q3MAP2_VERSION@\"
#define RADIANT_VERSION \"@RADIANT_VERSION@\"
#define RADIANT_MAJOR_VERSION \"@RADIANT_MAJOR_VERSION@\"
#define RADIANT_MINOR_VERSION \"@RADIANT_MINOR_VERSION@\"
#define RADIANT_ABOUTMSG \"Custom build\"
#define ASSIMP_INCLUDE(x) @Q3MAP2_ASSIMP_INCLUDE@
")
configure_file("${Q3MAP2_CONFIG_HEADER}.in" "${Q3MAP2_CONFIG_HEADER}" @ONLY)

add_executable(q3map2 ${q3map2_sources})
target_include_directories(q3map2 PRIVATE
  "${NR}/tools/quake3/common" "${NR}/libs" "${NR}/include")
target_compile_options(q3map2 PRIVATE "$<$<COMPILE_LANGUAGE:C,CXX>:-include;${Q3MAP2_CONFIG_HEADER}>")
target_link_libraries(q3map2 PRIVATE
  ${q3map2_lib_targets}
  LibXml2::LibXml2
  q3map2_glib
  PNG::PNG
  JPEG::JPEG
  ZLIB::ZLIB
  ${Q3MAP2_ASSIMP_TARGET}
  Threads::Threads)

if(WIN32)
  # Larger main thread stack, as upstream does (deep BSP recursion)
  target_link_options(q3map2 PRIVATE "LINKER:--stack,4194304")
  # Reproducible builds: no link time in the PE header
  target_link_options(q3map2 PRIVATE "LINKER:--no-insert-timestamp")
  # Winsock for l_net (network broadcast to the editor) and other Win32 APIs
  target_link_libraries(q3map2 PRIVATE ws2_32 user32 gdi32 ole32)

  # Embed the application icon if a resource compiler (windres) is available
  include(CheckLanguage)
  check_language(RC)
  if(CMAKE_RC_COMPILER)
    enable_language(RC)
    set(_q3map2_rc "${CMAKE_CURRENT_BINARY_DIR}/q3map2_icon.rc")
    file(WRITE "${_q3map2_rc}" "1 ICON \"${NR}/icons/q3map2.ico\"\n")
    target_sources(q3map2 PRIVATE "${_q3map2_rc}")
  endif()
endif()

include(GNUInstallDirs)
install(TARGETS q3map2 RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}")
