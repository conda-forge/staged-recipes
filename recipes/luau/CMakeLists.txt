# Install wrapper for Luau.
#
# Upstream's CMakeLists.txt builds static libraries and CLI executables but has
# no install() rules and no exported CMake package. This wrapper adds the
# upstream project as a subdirectory and installs:
#   - the static libraries as Luau::<Component> imported targets
#     (Common, Ast, Compiler, Config, Analysis, EqSat, CodeGen, VM, Require)
#     through a regular install(EXPORT), so the link graph is upstream's own;
#   - the headers into include/luau (NOT include/, because VM ships lua.h,
#     lualib.h and luaconf.h, which would clobber the `lua` package);
#   - the command-line tools.
cmake_minimum_required(VERSION 3.16)
project(luau_install LANGUAGES C CXX)

set(LUAU_SOURCE_DIR "" CACHE PATH "Luau source tree")
set(LUAU_VERSION "" CACHE STRING "Luau version")

add_subdirectory("${LUAU_SOURCE_DIR}" luau)

include(GNUInstallDirs)
include(CMakePackageConfigHelpers)

set(_components Common Ast Compiler Config Analysis EqSat CodeGen VM Require)
set(_targets)
foreach(_c IN LISTS _components)
  set(_t Luau.${_c})
  list(APPEND _targets ${_t})
  # Upstream uses source-relative include directories; keep them for the
  # in-tree build and point the installed targets at include/luau.
  get_target_property(_inc ${_t} INTERFACE_INCLUDE_DIRECTORIES)
  set_target_properties(${_t} PROPERTIES
    EXPORT_NAME ${_c}
    INTERFACE_INCLUDE_DIRECTORIES
      "$<BUILD_INTERFACE:${_inc}>;$<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/luau>"
    # MSVC: drop the /NATVIS:<source-dir>/... link options, which would point
    # into the (deleted) build tree in the installed package.
    INTERFACE_LINK_OPTIONS "")
endforeach()

# CodeGen privately links the header-only Luau.VM.Internals helper target
# (VM/src include dir); it is not needed by consumers of the static library.
set_property(TARGET Luau.CodeGen PROPERTY INTERFACE_LINK_LIBRARIES
  "Luau.Common;$<LINK_ONLY:Luau.VM>")

install(TARGETS ${_targets} EXPORT LuauTargets
  ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
  LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
  RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR})

foreach(_c IN LISTS _components)
  install(DIRECTORY "${LUAU_SOURCE_DIR}/${_c}/include/"
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/luau)
endforeach()

install(TARGETS
    Luau.Repl.CLI Luau.Analyze.CLI Luau.Ast.CLI
    Luau.Compile.CLI Luau.Bytecode.CLI
  RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR})

set(_cmakedir ${CMAKE_INSTALL_LIBDIR}/cmake/Luau)
install(EXPORT LuauTargets NAMESPACE Luau:: DESTINATION ${_cmakedir})
file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/LuauConfig.cmake"
  "include(\"\${CMAKE_CURRENT_LIST_DIR}/LuauTargets.cmake\")\n")
write_basic_package_version_file(
  "${CMAKE_CURRENT_BINARY_DIR}/LuauConfigVersion.cmake"
  VERSION ${LUAU_VERSION}
  # Luau has no API/ABI stability guarantees between releases.
  COMPATIBILITY ExactVersion)
install(FILES
    "${CMAKE_CURRENT_BINARY_DIR}/LuauConfig.cmake"
    "${CMAKE_CURRENT_BINARY_DIR}/LuauConfigVersion.cmake"
  DESTINATION ${_cmakedir})
