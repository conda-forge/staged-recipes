set(EXT_INCLUDE_DIRS "${CMAKE_INSTALL_PREFIX}/include/xmscore")
list(APPEND EXT_INCLUDE_DIRS "${CMAKE_INSTALL_PREFIX}/include/xmsgrid")
list(APPEND EXT_INCLUDE_DIRS "${CMAKE_INSTALL_PREFIX}/include/xmsgrid")

if(WIN32)
    set(EXT_LIB_DIRS "${LIBRARY_LIB}")
else()
    set(EXT_LIB_DIRS "${CMAKE_INSTALL_PREFIX}/lib")
endif()

set(EXT_LIBS xmscorelib)
list(APPEND EXT_LIBS xmsgridlib)
list(APPEND EXT_LIBS xmsinterplib)

set(Boost_USE_STATIC_LIBS TRUE)
find_package(Boost REQUIRED log_setup log system filesystem serialization timer thread)
list(APPEND EXT_INCLUDE_DIRS ${Boost_INCLUDE_DIRS})
list(APPEND EXT_LIB_DIRS ${Boost_LIBRARY_DIRS})
list(APPEND EXT_LIBS ${Boost_LIBRARIES})

if(WIN32)
    list(APPEND EXT_LIBS zlib)
else()
    list(APPEND EXT_LIBS z)
endif()

