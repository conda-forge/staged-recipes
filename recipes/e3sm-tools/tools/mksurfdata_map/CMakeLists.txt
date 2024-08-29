SET(SRC ${CMAKE_SOURCE_DIR}/components/elm/tools/mksurfdata_map/src)
set(MKSURFDATA_MAP_SRC ${SRC}/fileutils.F90
                       ${SRC}/mkagfirepkmonthMod.F90
                       ${SRC}/mkCH4inversionMod.F90
                       ${SRC}/mkchecksMod.F90
                       ${SRC}/mkdiagnosticsMod.F90
                       ${SRC}/mkdomainMod.F90
                       ${SRC}/mkFertMod.F90
                       ${SRC}/mkfileMod.F90
                       ${SRC}/mkgdpMod.F90
                       ${SRC}/mkglcmecMod.F90
                       ${SRC}/mkgridmapMod.F90
                       ${SRC}/mkharvestMod.F90
                       ${SRC}/mkindexmapMod.F90
                       ${SRC}/mklaiMod.F90
                       ${SRC}/mklanwatMod.F90
                       ${SRC}/mkncdio.F90
                       ${SRC}/mkpeatMod.F90
                       ${SRC}/mkpftMod.F90
                       ${SRC}/mkSedMod.F90
                       ${SRC}/mksoilMod.F90
                       ${SRC}/mksoilphosphorusMod.F90
                       ${SRC}/mksurfdat.F90
                       ${SRC}/mktopostatsMod.F90
                       ${SRC}/mkurbanparCommonMod.F90
                       ${SRC}/mkurbanparMod.F90
                       ${SRC}/mkutilsMod.F90
                       ${SRC}/mkvarctl.F90
                       ${SRC}/mkvarpar.F90
                       ${SRC}/mkVICparamsMod.F90
                       ${SRC}/mkvocefMod.F90
                       ${SRC}/nanMod.F90
                       ${SRC}/shr_const_mod.F90
                       ${SRC}/shr_file_mod.F90
                       ${SRC}/shr_kind_mod.F90
                       ${SRC}/shr_log_mod.F90
                       ${SRC}/shr_string_mod.F90
                       ${SRC}/shr_sys_mod.F90
                       ${SRC}/shr_timer_mod.F90)

include_directories(${netcdf_f_incdir})
add_executable(mksurfdata_map ${MKSURFDATA_MAP_SRC})
target_link_libraries(mksurfdata_map ${netcdf_f_libs})

install(TARGETS mksurfdata_map DESTINATION bin)
