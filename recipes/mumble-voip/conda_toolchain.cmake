# CMake toolchain file for conda-forge integration
# This file ensures proper detection and linking of conda-forge packages

# Set the system name
set(CMAKE_SYSTEM_NAME ${CMAKE_HOST_SYSTEM_NAME})

# Use conda-forge environment variables
if(DEFINED ENV{PREFIX})
    set(CMAKE_PREFIX_PATH "$ENV{PREFIX}" ${CMAKE_PREFIX_PATH})
    set(CMAKE_FIND_ROOT_PATH "$ENV{PREFIX}")

    # Set standard paths
    list(APPEND CMAKE_PREFIX_PATH "$ENV{PREFIX}")
    list(APPEND CMAKE_PREFIX_PATH "$ENV{PREFIX}/lib/cmake")
    list(APPEND CMAKE_PREFIX_PATH "$ENV{PREFIX}/share/cmake")
    list(APPEND CMAKE_PREFIX_PATH "$ENV{PREFIX}/lib/pkgconfig")

    # Platform-specific paths
    if(WIN32)
        list(APPEND CMAKE_PREFIX_PATH "$ENV{PREFIX}/Library")
        list(APPEND CMAKE_PREFIX_PATH "$ENV{PREFIX}/Library/lib/cmake")
        list(APPEND CMAKE_PREFIX_PATH "$ENV{PREFIX}/Library/share/cmake")
    endif()

    message(STATUS "Conda environment detected: $ENV{PREFIX}")
else()
    message(WARNING "PREFIX environment variable not set - conda-forge integration may not work properly")
endif()

# Set pkg-config path
if(DEFINED ENV{PREFIX})
    if(WIN32)
        if(DEFINED ENV{PKG_CONFIG_PATH})
            set(ENV{PKG_CONFIG_PATH} "$ENV{PREFIX}/Library/lib/pkgconfig:$ENV{PKG_CONFIG_PATH}")
        else()
            set(ENV{PKG_CONFIG_PATH} "$ENV{PREFIX}/Library/lib/pkgconfig")
        endif()
    else()
        if(DEFINED ENV{PKG_CONFIG_PATH})
            set(ENV{PKG_CONFIG_PATH} "$ENV{PREFIX}/lib/pkgconfig:$ENV{PKG_CONFIG_PATH}")
        else()
            set(ENV{PKG_CONFIG_PATH} "$ENV{PREFIX}/lib/pkgconfig")
        endif()
    endif()
endif()

# Configure find modes for conda-forge
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)

# Prefer conda-forge packages over system packages
set(CMAKE_FIND_PACKAGE_PREFER_CONFIG ON)

# Enable pkg-config
find_package(PkgConfig QUIET)
if(NOT PkgConfig_FOUND)
    message(STATUS "PkgConfig not found - some system libraries may not be detected")
endif()

# Set compiler and linker flags for conda-forge
if(DEFINED ENV{PREFIX})
    if(NOT WIN32)
        set(CMAKE_C_FLAGS_INIT "-I$ENV{PREFIX}/include")
        set(CMAKE_CXX_FLAGS_INIT "-I$ENV{PREFIX}/include")
        set(CMAKE_EXE_LINKER_FLAGS_INIT "-L$ENV{PREFIX}/lib")
        set(CMAKE_SHARED_LINKER_FLAGS_INIT "-L$ENV{PREFIX}/lib")
    else()
        set(CMAKE_C_FLAGS_INIT "/I$ENV{PREFIX}/Library/include")
        set(CMAKE_CXX_FLAGS_INIT "/I$ENV{PREFIX}/Library/include")
        set(CMAKE_EXE_LINKER_FLAGS_INIT "/LIBPATH:$ENV{PREFIX}/Library/lib")
        set(CMAKE_SHARED_LINKER_FLAGS_INIT "/LIBPATH:$ENV{PREFIX}/Library/lib")
    endif()
endif()

# Platform-specific configuration
if(APPLE)
    # macOS-specific conda-forge integration
    if(DEFINED ENV{PREFIX})
        set(CMAKE_OSX_SYSROOT "$ENV{CONDA_BUILD_SYSROOT}")
        if(DEFINED ENV{MACOSX_DEPLOYMENT_TARGET})
            set(CMAKE_OSX_DEPLOYMENT_TARGET "$ENV{MACOSX_DEPLOYMENT_TARGET}")
        endif()
    endif()
elseif(UNIX AND NOT APPLE)
    # Linux-specific conda-forge integration
    if(DEFINED ENV{PREFIX})
        # Set RPATH for conda environment
        set(CMAKE_INSTALL_RPATH "$ENV{PREFIX}/lib")
        set(CMAKE_BUILD_RPATH "$ENV{PREFIX}/lib")
        set(CMAKE_BUILD_WITH_INSTALL_RPATH ON)
        set(CMAKE_INSTALL_RPATH_USE_LINK_PATH ON)
    endif()
endif()

# Debugging output
message(STATUS "Conda-forge toolchain configuration:")
message(STATUS "  CMAKE_PREFIX_PATH: ${CMAKE_PREFIX_PATH}")
message(STATUS "  CMAKE_FIND_ROOT_PATH: ${CMAKE_FIND_ROOT_PATH}")
if(DEFINED ENV{PKG_CONFIG_PATH})
    message(STATUS "  PKG_CONFIG_PATH: $ENV{PKG_CONFIG_PATH}")
else()
    message(STATUS "  PKG_CONFIG_PATH: <not set>")
endif()
message(STATUS "  PkgConfig found: ${PkgConfig_FOUND}")
