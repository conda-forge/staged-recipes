cmake_minimum_required(VERSION 3.7 FATAL_ERROR)
project (HPTT C CXX)

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
set(ENABLE_IBM OFF)

if(CMAKE_SYSTEM_PROCESSOR STREQUAL "ppc64le")
  set(ENABLE_IBM ON)
endif()

find_package(OpenMP REQUIRED)

if(ENABLE_AVX)
  set(HPTT_CXX_FLAGS ${HPTT_CXX_FLAGS} -mavx -DHPTT_ARCH_AVX)
elseif(ENABLE_ARM)
  set(HPTT_CXX_FLAGS ${HPTT_CXX_FLAGS} -mfpu=neon -DHPTT_ARCH_ARM)
elseif(ENABLE_IBM)
  set(HPTT_CXX_FLAGS ${HPTT_CXX_FLAGS} -mtune=native -DHPTT_ARCH_IBM -maltivec -mabi=altivec)
endif()

set(HPTT_SRCS src/hptt.cpp src/plan.cpp src/transpose.cpp src/utils.cpp)

add_library(hptt ${HPTT_SRCS})
target_link_libraries(hptt PUBLIC OpenMP::OpenMP_CXX)
target_compile_features(hptt PUBLIC cxx_std_11)
target_include_directories(hptt PUBLIC
    $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/include>
    $<INSTALL_INTERFACE:include>)
#target_compile_definitions(hptt PRIVATE ${HPTT_CXX_COMPILE_DEFS})
target_compile_options(hptt PUBLIC ${HPTT_CXX_FLAGS})

include( GNUInstallDirs )

install(TARGETS hptt
        LIBRARY DESTINATION ${CMAKE_INSTALL_PREFIX}/lib
        ARCHIVE DESTINATION ${CMAKE_INSTALL_PREFIX}/lib)

set(HPTT_INCLUDES 
    include/compute_node.h 
    include/hptt_types.h 
    include/hptt.h 
    include/macros.h 
    include/plan.h 
    include/utils.h 
    include/transpose.h)

install(FILES ${HPTT_INCLUDES}
        DESTINATION ${CMAKE_INSTALL_PREFIX}/include/hptt)

install( TARGETS hptt
  EXPORT hptt-targets 
  LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
  ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
)
export(EXPORT hptt-targets
      NAMESPACE hptt::
      FILE "${PROJECT_BINARY_DIR}/hptt-targets.cmake")

# Export target to script
install( EXPORT hptt-targets
  FILE         hptt-targets.cmake
  NAMESPACE    hptt::
  DESTINATION  ${CMAKE_INSTALL_LIBDIR}/cmake/hptt
)

# Create config-version.cmake file
include( CMakePackageConfigHelpers )
write_basic_package_version_file(
  ${PROJECT_BINARY_DIR}/hptt-config-version.cmake
  VERSION $ENV{PKG_VERSION}
  COMPATIBILITY AnyNewerVersion
)

# Setup hptt-config.cmake
configure_package_config_file(
  ${PROJECT_SOURCE_DIR}/hptt-config.cmake.in
  ${PROJECT_BINARY_DIR}/hptt-config.cmake
  INSTALL_DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/hptt
)

install( FILES
  ${PROJECT_BINARY_DIR}/hptt-config.cmake
  ${PROJECT_BINARY_DIR}/hptt-config-version.cmake
  DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/hptt
)
