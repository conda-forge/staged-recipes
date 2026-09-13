# MrDocs requires `find_package(Lua CONFIG REQUIRED)`, but neither upstream
# Lua nor conda-forge's `lua` package ship a CMake package config (only
# CMake's own FindLua.cmake module, which CONFIG mode ignores). This wraps the
# already-installed conda-forge `lua` library/headers into a Lua::lua imported
# target and a LuaConfig.cmake, adapted from the equivalent patch MrDocs
# applies via its own bootstrap tool
# (https://github.com/cppalliance/mrdocs/blob/develop/utils/bootstrap/patches/lua/LuaConfig.cmake.in).
cmake_minimum_required(VERSION 3.16)
project(lua-shim LANGUAGES NONE)

include(GNUInstallDirs)
include(CMakePackageConfigHelpers)

find_path(LUA_INCLUDE_DIR lua.h REQUIRED)
find_library(LUA_LIBRARY NAMES lua lua5.4 lua-5.4 REQUIRED)

configure_file(
    ${CMAKE_CURRENT_LIST_DIR}/LuaTargets.cmake.in
    ${PROJECT_BINARY_DIR}/LuaTargets.cmake
    @ONLY)

configure_package_config_file(
    ${CMAKE_CURRENT_LIST_DIR}/LuaConfig.cmake.in
    ${PROJECT_BINARY_DIR}/LuaConfig.cmake
    INSTALL_DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/Lua
)

install(FILES
    ${PROJECT_BINARY_DIR}/LuaTargets.cmake
    ${PROJECT_BINARY_DIR}/LuaConfig.cmake
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/Lua)
