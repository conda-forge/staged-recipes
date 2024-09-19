if(WIN32)
    add_definitions(-DBUILDING_DLL)
    set(EXPORT_MACRO "#ifdef _WIN32\n  #ifdef BUILDING_DLL\n    #define DLL_EXPORT_API __declspec(dllexport)\n  #else\n    #define DLL_EXPORT_API __declspec(dllimport)\n  #endif\n#else\n  #define DLL_EXPORT_API\n#endif\n")
else()
    set(EXPORT_MACRO "#define DLL_EXPORT_API\n")
endif()

foreach(_file ${PROTO_GENERATED_FILES})
    if(_file MATCHES ".h$")
        add_custom_command(
            OUTPUT ${_file}_modified
            COMMAND ${CMAKE_COMMAND} -E echo_append "${EXPORT_MACRO}" >> ${_file}
            DEPENDS ${_file}
        )
    endif()
endforeach()

set(PROTO_MODIFIED_HEADERS)
foreach(_file ${PROTO_GENERATED_FILES})
    if(_file MATCHES ".h$")
        list(APPEND PROTO_MODIFIED_HEADERS ${_file}_modified)
    endif()
endforeach()

add_custom_target(modify_headers ALL DEPENDS ${PROTO_MODIFIED_HEADERS})
add_dependencies(dydx_v4_proto_obj modify_headers)
