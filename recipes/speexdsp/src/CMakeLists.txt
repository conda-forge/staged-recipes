cmake_minimum_required(VERSION 3.10)

project(speexdsp
    VERSION 1.2.1
    DESCRIPTION "speexdsp audio processing library"
    LANGUAGES C
)

include(GNUInstallDirs)
include(CheckIncludeFile)
include(CheckTypeSize)
include(CheckFunctionExists)
include(TestBigEndian)

option(BUILD_SHARED_LIBS "Build shared libraries" OFF)
option(USE_FIXED_POINT "Use fixed-point arithmetic" OFF)

# Fixed vs. floating-point arithmetic (used by config.h.in via #cmakedefine)
if(USE_FIXED_POINT)
    set(FIXED_POINT 1)
else()
    set(FLOATING_POINT 1)
endif()

# Check for headers
check_include_file(stdint.h HAVE_STDINT_H)
check_include_file(alloca.h HAVE_ALLOCA_H)
check_include_file(memory.h HAVE_MEMORY_H)
check_include_file(strings.h HAVE_STRINGS_H)
check_include_file(sys/stat.h HAVE_SYS_STAT_H)
check_include_file(sys/types.h HAVE_SYS_TYPES_H)
check_include_file(unistd.h HAVE_UNISTD_H)
check_include_file(dlfcn.h HAVE_DLFCN_H)

# Check for alloca
check_function_exists(alloca HAVE_ALLOCA)
if(HAVE_ALLOCA)
    set(USE_ALLOCA 1)
endif()

# Check endianness
test_big_endian(WORDS_BIGENDIAN)

# Check sizes of integer types
check_type_size("short" SIZEOF_SHORT)
check_type_size("int"   SIZEOF_INT)
check_type_size("long"  SIZEOF_LONG)

# Set type definitions based on size checks
if(SIZEOF_SHORT EQUAL 2)
    set(SIZE16  "short")
    set(USIZE16 "unsigned short")
elseif(SIZEOF_INT EQUAL 2)
    set(SIZE16  "int")
    set(USIZE16 "unsigned int")
else()
    set(SIZE16  "int16_t")
    set(USIZE16 "uint16_t")
endif()

if(SIZEOF_INT EQUAL 4)
    set(SIZE32  "int")
    set(USIZE32 "unsigned int")
elseif(SIZEOF_LONG EQUAL 4)
    set(SIZE32  "long")
    set(USIZE32 "unsigned long")
else()
    set(SIZE32  "int32_t")
    set(USIZE32 "uint32_t")
endif()

# Tell source files to include config.h
add_compile_definitions(HAVE_CONFIG_H)

# Generate config.h (replaces the autoconf-generated file)
configure_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/cmake/config.h.in"
    "${CMAKE_BINARY_DIR}/config.h"
    @ONLY
)

# Generate speexdsp_config_types.h
file(MAKE_DIRECTORY "${CMAKE_BINARY_DIR}/include/speex")
configure_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/cmake/speexdsp_config_types.h.in"
    "${CMAKE_BINARY_DIR}/include/speex/speexdsp_config_types.h"
    @ONLY
)

# Include directories
include_directories(
    ${CMAKE_SOURCE_DIR}/include
    ${CMAKE_SOURCE_DIR}/libspeexdsp
    ${CMAKE_BINARY_DIR}
    ${CMAKE_BINARY_DIR}/include
    ${CMAKE_BINARY_DIR}/include/speex
)

# Source files (exclude test programs)
file(GLOB SPEEXDSP_SOURCES libspeexdsp/*.c)
list(REMOVE_ITEM SPEEXDSP_SOURCES
    ${CMAKE_SOURCE_DIR}/libspeexdsp/testdenoise.c
    ${CMAKE_SOURCE_DIR}/libspeexdsp/testecho.c
    ${CMAKE_SOURCE_DIR}/libspeexdsp/testjitter.c
    ${CMAKE_SOURCE_DIR}/libspeexdsp/testresample.c
    ${CMAKE_SOURCE_DIR}/libspeexdsp/testresample2.c
)

add_library(speexdsp ${SPEEXDSP_SOURCES})

# On Windows, auto-export all symbols so an import library (.lib) is generated
set_target_properties(speexdsp PROPERTIES WINDOWS_EXPORT_ALL_SYMBOLS ON)

# Link math library if available
find_library(MATH_LIBRARY m)
if(MATH_LIBRARY)
    target_link_libraries(speexdsp PRIVATE ${MATH_LIBRARY})
endif()

target_include_directories(speexdsp PUBLIC
    $<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/include>
    $<BUILD_INTERFACE:${CMAKE_BINARY_DIR}/include>
    $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
)

# Installation rules
install(TARGETS speexdsp
    EXPORT speexdspTargets
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
)
install(DIRECTORY include/ DESTINATION ${CMAKE_INSTALL_INCLUDEDIR})
install(FILES "${CMAKE_BINARY_DIR}/include/speex/speexdsp_config_types.h"
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/speex
)

# Create and install pkg-config file
configure_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/cmake/speexdsp.pc.in"
    "${CMAKE_BINARY_DIR}/speexdsp.pc"
    @ONLY
)
install(FILES "${CMAKE_BINARY_DIR}/speexdsp.pc"
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/pkgconfig
)

# Create CMake package config files
include(CMakePackageConfigHelpers)

configure_package_config_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/cmake/speexdspConfig.cmake.in"
    "${CMAKE_BINARY_DIR}/speexdspConfig.cmake"
    INSTALL_DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/speexdsp
)

write_basic_package_version_file(
    "${CMAKE_BINARY_DIR}/speexdspConfigVersion.cmake"
    VERSION ${PROJECT_VERSION}
    COMPATIBILITY SameMajorVersion
)

install(EXPORT speexdspTargets
    FILE speexdspTargets.cmake
    NAMESPACE speexdsp::
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/speexdsp
)

install(FILES
    "${CMAKE_BINARY_DIR}/speexdspConfig.cmake"
    "${CMAKE_BINARY_DIR}/speexdspConfigVersion.cmake"
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/speexdsp
)
