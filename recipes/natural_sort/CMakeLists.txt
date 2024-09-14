cmake_minimum_required(VERSION 3.6.0)

project(natural_sort)

add_library(${PROJECT_NAME} INTERFACE)
target_include_directories(${PROJECT_NAME} INTERFACE
    "$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>"
    "$<INSTALL_INTERFACE:include>"
)

install(
    FILES "natural_sort.hpp"
    DESTINATION "include/NaturalSort"
)

install(TARGETS ${PROJECT_NAME} EXPORT ${PROJECT_NAME}Targets)

include(CMakePackageConfigHelpers)
set(CONFIG_PACKAGE_BUILD_LOCATION "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}")
set(CONFIG_PACKAGE_INSTALL_LOCATION "lib/cmake/${PROJECT_NAME}")
write_basic_package_version_file (
    "${CONFIG_PACKAGE_BUILD_LOCATION}/${PROJECT_NAME}ConfigVersion.cmake"
    VERSION 0.0.0
    COMPATIBILITY AnyNewerVersion
)
export(
    EXPORT ${PROJECT_NAME}Targets
    FILE "${CONFIG_PACKAGE_BUILD_LOCATION}/${PROJECT_NAME}Targets.cmake"
)
configure_file(
    "${PROJECT_NAME}Config.cmake.in"
    "${CONFIG_PACKAGE_BUILD_LOCATION}/${PROJECT_NAME}Config.cmake"
    @ONLY
)
install(
    EXPORT "${PROJECT_NAME}Targets"
    FILE "${PROJECT_NAME}Targets.cmake"
    DESTINATION "${CONFIG_PACKAGE_INSTALL_LOCATION}"
)
install(
    FILES
    "${CONFIG_PACKAGE_BUILD_LOCATION}/${PROJECT_NAME}Config.cmake"
    "${CONFIG_PACKAGE_BUILD_LOCATION}/${PROJECT_NAME}ConfigVersion.cmake"
    DESTINATION "${CONFIG_PACKAGE_INSTALL_LOCATION}"
)
