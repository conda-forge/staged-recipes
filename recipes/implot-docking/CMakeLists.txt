cmake_minimum_required(VERSION 3.8)
project(implot CXX)

find_package(imgui CONFIG REQUIRED)

set(CMAKE_DEBUG_POSTFIX d)
include(GNUInstallDirs)

add_library(${PROJECT_NAME} "")
add_library(${PROJECT_NAME}::${PROJECT_NAME} ALIAS ${PROJECT_NAME})
target_compile_features(${PROJECT_NAME} PUBLIC cxx_std_11)
target_include_directories(
	${PROJECT_NAME}
	PUBLIC
		$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
		$<INSTALL_INTERFACE:include>
)
target_link_libraries(${PROJECT_NAME} PUBLIC imgui::imgui)

target_sources(
	${PROJECT_NAME}
	PRIVATE
		${CMAKE_CURRENT_SOURCE_DIR}/implot.cpp
		${CMAKE_CURRENT_SOURCE_DIR}/implot_items.cpp
		${CMAKE_CURRENT_SOURCE_DIR}/implot_demo.cpp
)

if(WIN32)
    set_target_properties(${PROJECT_NAME} PROPERTIES WINDOWS_EXPORT_ALL_SYMBOLS ON)
    # WINDOWS_EXPORT_ALL_SYMBOLS only exports functions, not data symbols.
    # GImPlot is a global data symbol that consumers access via inline functions
    # in implot_internal.h, so it needs explicit dllexport/dllimport.
    target_compile_definitions(${PROJECT_NAME} PRIVATE "IMPLOT_API=__declspec(dllexport)")
    target_compile_definitions(${PROJECT_NAME} INTERFACE "IMPLOT_API=__declspec(dllimport)")
endif()

install(
	TARGETS ${PROJECT_NAME}
	EXPORT ${PROJECT_NAME}_target
	ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
	LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
	RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

if(NOT IMPLOT_SKIP_HEADERS)
    install(FILES
        ${CMAKE_CURRENT_SOURCE_DIR}/implot.h
		${CMAKE_CURRENT_SOURCE_DIR}/implot_internal.h
        DESTINATION include
    )
endif()

install(
	EXPORT ${PROJECT_NAME}_target
	NAMESPACE ${PROJECT_NAME}::
	FILE ${PROJECT_NAME}-config.cmake
	DESTINATION share/${PROJECT_NAME}
)
