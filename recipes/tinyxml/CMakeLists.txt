cmake_minimum_required(VERSION 2.4.6)
add_definitions(-DTIXML_USE_STL)
add_library(tinyxml SHARED tinyxml.cpp tinyxmlerror.cpp tinyxmlparser.cpp)
set_target_properties(tinyxml PROPERTIES
                      INSTALL_NAME_DIR ${CMAKE_INSTALL_PREFIX}/lib)

install(TARGETS tinyxml
        LIBRARY DESTINATION lib
        ARCHIVE DESTINATION lib
        RUNTIME DESTINATION lib)
install(FILES tinyxml.h
        DESTINATION include)
