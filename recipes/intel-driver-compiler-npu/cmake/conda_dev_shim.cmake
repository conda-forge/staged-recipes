# conda_dev_shim.cmake — replaces OpenVINODeveloperPackage for the out-of-tree
# conda-forge CiD build (intel-driver-compiler-npu). Injected by patch 0009 and
# included from npu_compiler's root CMakeLists when -DNPU_CONDA_OUT_OF_TREE=ON.
# Designed by the Phase B strategist (2026-05-25); validated incrementally via
# the configure experiment in ~/git/npu-cc-spike.
include_guard(GLOBAL)

# Consumer OpenVINO (conda-forge libopenvino-dev) -> openvino::runtime
find_package(OpenVINO REQUIRED COMPONENTS Runtime)
# Phase-A support lib -> openvino::npu_compiler_support (npu_al/npu_ops/xml_util)
find_package(OpenVINONPUCompilerSupport REQUIRED)

# Shim npu_al / npu_ops / xml_util onto the support lib. They are used both as
# link libs and via $<TARGET_PROPERTY:...,INTERFACE_INCLUDE_DIRECTORIES>, so each
# must be a real linkable target re-exporting the support lib.
foreach(_t npu_al npu_ops xml_util)
    if(NOT TARGET openvino::${_t})
        add_library(openvino::${_t} INTERFACE IMPORTED GLOBAL)
        target_link_libraries(openvino::${_t} INTERFACE openvino::npu_compiler_support)
    endif()
endforeach()

# openvino::runtime::dev — internal dev-API interface target. In the
# conda-forge out-of-tree build the dev headers are shipped by the
# libopenvino-npu-compiler-support package (_6+) at
# $PREFIX/include/npu_compiler_support. Provide an INTERFACE target that
# exposes those headers so npu_ov_utils and vpux_compiler_l0 compile cleanly.
if(NOT TARGET openvino::runtime::dev)
    get_target_property(_npucs_incdirs openvino::npu_compiler_support INTERFACE_INCLUDE_DIRECTORIES)
    add_library(openvino_runtime_dev_shim INTERFACE IMPORTED GLOBAL)
    target_include_directories(openvino_runtime_dev_shim INTERFACE ${_npucs_incdirs})
    target_link_libraries(openvino_runtime_dev_shim INTERFACE openvino::runtime)
    add_library(openvino::runtime::dev ALIAS openvino_runtime_dev_shim)
endif()

# openvino::itt — Intel ITT profiling interface. In a production package build
# ITT is disabled; provide an empty INTERFACE target so the generator
# expression $<TARGET_PROPERTY:openvino::itt,INTERFACE_COMPILE_DEFINITIONS>
# resolves to nothing (no ENABLE_PROFILING_ITT define).
if(NOT TARGET openvino::itt)
    add_library(openvino_itt_shim INTERFACE IMPORTED GLOBAL)
    add_library(openvino::itt ALIAS openvino_itt_shim)
endif()

# --- ov_* macros that must do real work ---
if(NOT DEFINED OV_OPTIONS)
    set(OV_OPTIONS "" CACHE INTERNAL "")
endif()
macro(ov_option var desc value)
    option(${var} "${desc}" ${value})
    list(APPEND OV_OPTIONS ${var})
    set(OV_OPTIONS "${OV_OPTIONS}" CACHE INTERNAL "")
endmacro()
macro(ov_dependent_option var desc def cond fallback)
    include(CMakeDependentOption)
    cmake_dependent_option(${var} "${desc}" "${def}" "${cond}" "${fallback}")
    list(APPEND OV_OPTIONS ${var})
    set(OV_OPTIONS "${OV_OPTIONS}" CACHE INTERNAL "")
endmacro()
macro(ov_add_compiler_flags)
    add_compile_options(${ARGN})
endmacro()
function(ov_link_system_libraries TARGET_NAME)
    set(_scope PRIVATE)
    set(_libs ${ARGN})
    list(GET _libs 0 _maybe)
    if(_maybe MATCHES "^(PRIVATE|PUBLIC|INTERFACE)$")
        set(_scope ${_maybe})
        list(REMOVE_AT _libs 0)
    endif()
    target_link_libraries(${TARGET_NAME} ${_scope} ${_libs})
    foreach(_l ${_libs})
        if(TARGET ${_l})
            target_include_directories(${TARGET_NAME} SYSTEM ${_scope}
                $<TARGET_PROPERTY:${_l},INTERFACE_INCLUDE_DIRECTORIES>)
        endif()
    endforeach()
endfunction()
function(ov_commit_hash OUT_VAR SRC_DIR)
    find_package(Git QUIET)
    set(_hash "0000000")
    if(Git_FOUND)
        execute_process(COMMAND ${GIT_EXECUTABLE} rev-parse --short HEAD
            WORKING_DIRECTORY ${SRC_DIR} OUTPUT_VARIABLE _h
            OUTPUT_STRIP_TRAILING_WHITESPACE ERROR_QUIET RESULT_VARIABLE _rc)
        if(_rc EQUAL 0 AND _h)
            set(_hash "${_h}")
        endif()
    endif()
    set(${OUT_VAR} "${_hash}" PARENT_SCOPE)
endfunction()
function(ov_add_version_defines VERSION_FILE TARGET_NAME)
    if(NOT DEFINED CI_BUILD_NUMBER)
        set(CI_BUILD_NUMBER "custom")
    endif()
    target_compile_definitions(${TARGET_NAME} PRIVATE CI_BUILD_NUMBER="${CI_BUILD_NUMBER}")
endfunction()

# --- logging / misc dev-package helpers (from OpenVINODeveloperScripts) ---
macro(debug_message)
    message(STATUS ${ARGN})
endmacro()

# --- pure no-op stubs ---
macro(ov_build_target_faster)
endmacro()
macro(ov_add_api_validator_post_build_step)
endmacro()
macro(ov_set_temp_directory)
endmacro()
macro(ov_cpack)
endmacro()
macro(ov_cpack_add_component)
endmacro()
macro(ov_add_target)
endmacro()
macro(ov_add_test_target)
endmacro()

if(NOT DEFINED OV_CPACK_RUNTIMEDIR)
    set(OV_CPACK_RUNTIMEDIR lib)
endif()

# OPENVINO_SOURCE_DIR is used by npu_compiler to reach common/transformations/include.
# In the conda-forge out-of-tree build the transformations headers are shipped
# at $PREFIX/include/npu_compiler_support/transformations_compat/
# so that ${OPENVINO_SOURCE_DIR}/common/transformations/include resolves.
# Requires support package v7+ which adds the transformations_compat tree.
if(NOT DEFINED OPENVINO_SOURCE_DIR OR OPENVINO_SOURCE_DIR STREQUAL "")
    get_target_property(_npucs_incdirs openvino::npu_compiler_support INTERFACE_INCLUDE_DIRECTORIES)
    set(OPENVINO_SOURCE_DIR "${_npucs_incdirs}/transformations_compat" CACHE PATH
        "Synthetic OV source dir for transformations headers" FORCE)
endif()
# Add the transformations include dir globally so ALL targets can reach
# <transformations/...> headers (some targets include them without an explicit
# per-target include_directories call, e.g. ELFNPU37XX/metadata.hpp).
include_directories(SYSTEM "${OPENVINO_SOURCE_DIR}/common/transformations/include")

# flatbuffers (conda-forge). npu_compiler reuses OpenVINO's in-tree flatc/targets
# in the dev-package path; out-of-tree we supply them from conda-forge. NOTE: the
# flatbuffers version MUST match what conda-forge OpenVINO was built against
# (schema/flatc ABI). Verify in the configure experiment.
find_package(Flatbuffers QUIET)
if(NOT TARGET flatbuffers)
    # Resolve include dir: conda-build uses PREFIX, direct env use CONDA_PREFIX.
    set(_fb_prefix "$ENV{PREFIX}")
    if(NOT _fb_prefix)
        set(_fb_prefix "$ENV{CONDA_PREFIX}")
    endif()
    add_library(flatbuffers INTERFACE)
    target_include_directories(flatbuffers INTERFACE "${_fb_prefix}/include")
endif()
if(NOT TARGET flatc)
    # In conda-build: flatc lives in BUILD_PREFIX (the build env).
    # In direct env usage (spike/dev): fall back to CONDA_PREFIX or PATH.
    find_program(_flatc_exe flatc
        HINTS "$ENV{BUILD_PREFIX}/bin" "$ENV{CONDA_PREFIX}/bin"
        NO_DEFAULT_PATH)
    if(NOT _flatc_exe)
        find_program(_flatc_exe flatc)
    endif()
    if(NOT _flatc_exe)
        message(FATAL_ERROR "flatc not found. Set BUILD_PREFIX or CONDA_PREFIX.")
    endif()
    add_executable(flatc IMPORTED GLOBAL)
    set_target_properties(flatc PROPERTIES IMPORTED_LOCATION "${_flatc_exe}")
endif()
