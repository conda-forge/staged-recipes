cmake_minimum_required(VERSION 3.28.3)

project(usd-exchange-python LANGUAGES CXX)

set(USDEX_VERSION "${PROJECT_VERSION}" CACHE STRING "OpenUSD Exchange SDK version string")

find_package(pybind11 REQUIRED)
find_package(OpenGL REQUIRED)
find_package(pxr REQUIRED)
find_package(usd-exchange CONFIG REQUIRED)

# Normalize Python_SITEARCH to use forward slashes (CMake path convention).
# On Windows, find_package(Python) may return native backslashes, which CMake
# leaves unescaped in install(DIRECTORY) rules, causing cmake_install.cmake to
# fail with "Invalid character escape" errors (e.g. '\b' in C:\bld\...).
file(TO_CMAKE_PATH "${Python_SITEARCH}" Python_SITEARCH)

file(GLOB_RECURSE USDEX_CORE_PYTHON_BINDINGS CONFIGURE_DEPENDS source/core/python/bindings/*.cpp)
file(GLOB_RECURSE USDEX_RTX_PYTHON_BINDINGS CONFIGURE_DEPENDS source/rtx/python/bindings/*.cpp)

pybind11_add_module(_usdex_core ${USDEX_CORE_PYTHON_BINDINGS})
target_link_libraries(
    _usdex_core
    PRIVATE
    usd-exchange::usdex-core
)

pybind11_add_module(_usdex_rtx ${USDEX_RTX_PYTHON_BINDINGS})
target_link_libraries(
    _usdex_rtx
    PRIVATE
    usd-exchange::usdex-core
    usd-exchange::usdex-rtx
)

install(
    TARGETS _usdex_core
    LIBRARY DESTINATION ${Python_SITEARCH}/usdex/core
    RUNTIME DESTINATION ${Python_SITEARCH}/usdex/core
)

install(
    TARGETS _usdex_rtx
    LIBRARY DESTINATION ${Python_SITEARCH}/usdex/rtx
    RUNTIME DESTINATION ${Python_SITEARCH}/usdex/rtx
)

install(
    FILES
        source/core/python/__init__.py
        source/core/python/_AssetStructureBindings.py
        source/core/python/_StageAlgoBindings.py
    DESTINATION ${Python_SITEARCH}/usdex/core
)

install(
    FILES
        source/rtx/python/__init__.py
    DESTINATION ${Python_SITEARCH}/usdex/rtx
)

set(USDEX_PYTHON_DIST_INFO_DIR ${CMAKE_CURRENT_BINARY_DIR}/usd_exchange-${USDEX_VERSION}.dist-info)
file(MAKE_DIRECTORY ${USDEX_PYTHON_DIST_INFO_DIR})

file(WRITE ${USDEX_PYTHON_DIST_INFO_DIR}/METADATA "Metadata-Version: 2.1\nName: usd-exchange\nVersion: ${USDEX_VERSION}\nSummary: OpenUSD Exchange SDK Python bindings\n")
file(WRITE ${USDEX_PYTHON_DIST_INFO_DIR}/INSTALLER "conda\n")

install(
    DIRECTORY ${USDEX_PYTHON_DIST_INFO_DIR}/
    DESTINATION ${Python_SITEARCH}/usd_exchange-${USDEX_VERSION}.dist-info
)
