set(EXT_INCLUDE_DIRS "${CMAKE_INSTALL_PREFIX}/include/xmscore")
set(EXT_LIB_DIRS "${CMAKE_INSTALL_PREFIX}/lib")
set(EXT_LIBS xmscorelib)

set(Boost_USE_STATIC_LIBS TRUE)
find_package(Boost REQUIRED log_setup log system filesystem serialization timer thread)
list(APPEND EXT_INCLUDE_DIRS ${Boost_INCLUDE_DIRS})
list(APPEND EXT_LIB_DIRS ${Boost_LIBRARY_DIRS})
list(APPEND EXT_LIBS ${Boost_LIBRARIES})
list(APPEND EXT_LIBS zlib)

