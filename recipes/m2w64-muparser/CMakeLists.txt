# Set the minimum version of cmake required to 3.4 (for WINDOWS_EXPORT_ALL_SYMBOLS)
cmake_minimum_required( VERSION 3.4 )

project(muParser CXX)

set(muparser_sources
    src/muParserBase.cpp
    src/muParserBytecode.cpp
    src/muParserCallback.cpp
    src/muParser.cpp
    src/muParserDLL.cpp
    src/muParserError.cpp
    src/muParserInt.cpp
    src/muParserTest.cpp
    src/muParserTokenReader.cpp
)

set(muparser_headers
    include/muParserBase.h
    include/muParserBytecode.h
    include/muParserCallback.h
    include/muParserDef.h
    include/muParserDLL.h
    include/muParserError.h
    include/muParserFixes.h
    include/muParser.h
    include/muParserInt.h
    include/muParserStack.h
    include/muParserTemplateMagic.h
    include/muParserTest.h
    include/muParserToken.h
    include/muParserTokenReader.h
)

if(CMAKE_BUILD_TYPE STREQUAL Release)
    add_definitions(-DDEBUG=0)
else()
    add_definitions(-DDEBUG=1)
endif()
include_directories(include)

add_library(muparser ${muparser_sources})

if(BUILD_SHARED_LIBS)
    target_compile_definitions(muparser PRIVATE -DMUPARSER_DLL -DMUPARSERLIB_EXPORTS -DSHARED=1 -D_CRT_SECURE_NO_WARNINGS)
else()
    target_compile_definitions(muparser PRIVATE -DSHARED=0 -D_CRT_SECURE_NO_WARNINGS)
endif()

# -DMUPARSERLIB_EXPORTS just exports the C calls - need to do this to get the C++ interface
# -DMUPARSERLIB_EXPORTS still needed otherwise it won't build
set_target_properties(muparser PROPERTIES WINDOWS_EXPORT_ALL_SYMBOLS TRUE)

install(FILES ${muparser_headers}
    DESTINATION include COMPONENT Development
)
install(TARGETS muparser
    RUNTIME DESTINATION bin COMPONENT RuntimeLibraries
    LIBRARY DESTINATION lib COMPONENT RuntimeLibraries
    ARCHIVE DESTINATION lib COMPONENT Development
)

add_executable (example1 samples/example1/example1.cpp)
target_link_libraries (example1 muparser)
