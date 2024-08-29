find_package(CURL REQUIRED)
message(STATUS "CURL_INCLUDE_DIRS=${CURL_INCLUDE_DIRS}")
message(STATUS "CURL_LIBRARIES=${CURL_LIBRARIES}")

SET(SRC ${CMAKE_SOURCE_DIR}/components/eam/tools/topo_tool/cube_to_target)
set(CUBE_TO_TARGET_SRC ${SRC}/cube_to_target.F90
                       ${SRC}/reconstruct.F90
                       ${SRC}/remap.F90
                       ${SRC}/shr_kind_mod.F90)

include_directories(${netcdf_f_incdir})
include_directories(${CURL_INCLUDE_DIRS})
add_executable(cube_to_target ${CUBE_TO_TARGET_SRC})
target_link_libraries(cube_to_target ${netcdf_f_libs} ${CURL_LIBRARIES})

install(TARGETS cube_to_target DESTINATION bin)
