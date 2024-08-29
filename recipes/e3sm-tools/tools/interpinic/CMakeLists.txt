SET(SRC ${CMAKE_SOURCE_DIR}/components/elm/tools/interpinic/src)
set(INTERPINIC_SRC ${SRC}/fmain.F90
                   ${SRC}/interpinic.F90
                   ${SRC}/shr_const_mod.F90
                   ${SRC}/shr_infnan_mod.F90
                   ${SRC}/shr_isnan.c
                   ${SRC}/shr_kind_mod.F90
                   ${SRC}/shr_log_mod.F90
                   ${SRC}/shr_sys_mod.F90)

include_directories(${netcdf_f_incdir})

include_directories(${SRC})
add_compile_options("-DFORTRAN_UNDERSCORE_")
add_executable(interpinic ${INTERPINIC_SRC})
target_link_libraries(interpinic ${netcdf_f_libs})

install(TARGETS interpinic DESTINATION bin)
