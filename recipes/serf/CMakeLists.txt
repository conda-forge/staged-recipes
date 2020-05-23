cmake_minimum_required (VERSION 2.8.11)
project (serf)

execute_process(COMMAND python ${CMAKE_CURRENT_SOURCE_DIR}/build/gen_def.py
                               ${CMAKE_CURRENT_SOURCE_DIR}/serf.h
                               ${CMAKE_CURRENT_SOURCE_DIR}/serf_bucket_types.h
                               ${CMAKE_CURRENT_SOURCE_DIR}/serf_bucket_util.h
                               OUTPUT_FILE ${CMAKE_CURRENT_SOURCE_DIR}/serf.def)

file(GLOB SERF_SRCS
     RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}
     ${CMAKE_CURRENT_SOURCE_DIR}/*.c
     ${CMAKE_CURRENT_SOURCE_DIR}/auth/*.c
     ${CMAKE_CURRENT_SOURCE_DIR}/buckets/*.c)

LIST(APPEND SERF_SRCS serf.def)
LIST(APPEND CMAKE_PREFIX_PATH $ENV{LIBRARY_PREFIX})

LIST(APPEND LIBS  user32.lib advapi32.lib gdi32.lib ws2_32.lib
                       crypt32.lib secur32.lib zdll.lib
                       libapr-1.lib libaprutil-1.lib libeay32.lib
                       ssleay32.lib)

LIST(APPEND SERF_DEP_LIBS "")
FOREACH (LIB ${LIBS})
    UNSET(FOUND_LIB CACHE)
    FIND_LIBRARY(FOUND_LIB ${LIB})
    LIST(APPEND SERF_DEP_LIBS "${FOUND_LIB}")
ENDFOREACH(LIB)

message(${SERF_DEP_LIBS})

add_definitions(-DOPENSSL_OPT_WINDLL)

add_library (serf-1 SHARED ${SERF_SRCS})

target_include_directories (serf-1 PUBLIC
                            ${CMAKE_CURRENT_SOURCE_DIR}
                            ${CMAKE_CURRENT_SOURCE_DIR}/auth
                            ${CMAKE_CURRENT_SOURCE_DIR}/buckets
                            $ENV{LIBRARY_INC})

target_link_libraries(serf-1 ${SERF_DEP_LIBS})

install(TARGETS serf-1
        RUNTIME DESTINATION bin
        ARCHIVE DESTINATION lib
        LIBRARY DESTINATION lib)
