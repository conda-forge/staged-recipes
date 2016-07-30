include_directories("${CMAKE_CURRENT_SOURCE_DIR}/include")

file(GLOB lcms2_sources src/*.c)
file(GLOB lcms2_headers include/*.h)

file(GLOB common_sources utils/common/*.c)
file(GLOB common_headers utils/common/*.h)
file(GLOB jpgicc_sources utils/jpgicc/*.c)
file(GLOB linkicc_sources utils/linkicc/*.c)
file(GLOB psicc_sources utils/psicc/*.c)
file(GLOB tificc_sources utils/tificc/tifi*.c)
set(tifdiff_sources utils/tificc/tifdiff.c)
file(GLOB transicc_sources utils/transicc/*.c)

add_library(lcms2 SHARED ${lcms2_sources} ${lcms2_headers})
set_target_properties(lcms2
                      PROPERTIES COMPILE_DEFINITIONS
                      CMS_DLL_BUILD
                      )

find_package(jpeg REQUIRED)
find_package(tiff REQUIRED)
find_package(zlib REQUIRED)

include_directories(${CMAKE_SOURCE_DIR}/utils/common
                    ${JPEG_INCLUDE_DIR}
                    ${TIFF_INCLUDE_DIR}
                    ${ZLIB_INCLUDE_DIR}
                    )

add_executable(jpgicc ${jpgicc_sources} ${common_sources} ${common_headers})
add_dependencies(jpgicc lcms2)
target_link_libraries(jpgicc lcms2 ${JPEG_LIBRARY})

add_executable(linkicc ${linkicc_sources} ${common_sources} ${common_headers})
add_dependencies(linkicc lcms2)
target_link_libraries(linkicc lcms2)

add_executable(psicc ${psicc_sources} ${common_sources} ${common_headers})
add_dependencies(psicc lcms2)
target_link_libraries(psicc lcms2)

add_executable(tificc ${tificc_sources} ${common_sources} ${common_headers})
add_dependencies(tificc lcms2)
target_link_libraries(tificc lcms2 ${TIFF_LIBRARY})

add_executable(tifdiff ${tifdiff_sources} ${common_sources} ${common_headers})
add_dependencies(tifdiff lcms2)
target_link_libraries(tifdiff lcms2 ${TIFF_LIBRARY})

add_executable(transicc ${tificc_sources} ${common_sources} ${common_headers})
add_dependencies(transicc lcms2)
target_link_libraries(transicc lcms2 ${TIFF_LIBRARY})

set_target_properties(jpgicc linkicc psicc tificc tifdiff transicc
                      PROPERTIES COMPILE_DEFINITIONS CMS_DLL
                      )

install(FILES ${lcms2_headers}
        DESTINATION include
	)

install(TARGETS lcms2
        RUNTIME DESTINATION bin
	LIBRARY DESTINATION lib
	ARCHIVE DESTINATION lib
	)

foreach(exe jpgicc linkicc psicc tificc tifdiff transicc)
    install(TARGETS ${exe}
            RUNTIME DESTINATION bin
            )
endforeach(exe)
