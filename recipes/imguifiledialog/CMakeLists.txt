cmake_minimum_required(VERSION 3.16)
project(ImGuiFileDialog CXX)

include(GNUInstallDirs)

find_package(imgui CONFIG REQUIRED)

add_library(${PROJECT_NAME}
    ImGuiFileDialog.cpp
    ImGuiFileDialog.h
    ImGuiFileDialogConfig.h
)

target_link_libraries(${PROJECT_NAME} PUBLIC imgui::imgui)

target_include_directories(${PROJECT_NAME}
    PUBLIC
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
        $<INSTALL_INTERFACE:include>
)

if(UNIX)
    target_compile_options(${PROJECT_NAME} PUBLIC -Wno-unknown-pragmas)
endif()

if(WIN32)
    set_target_properties(${PROJECT_NAME} PROPERTIES WINDOWS_EXPORT_ALL_SYMBOLS ON)
endif()

install(TARGETS ${PROJECT_NAME}
    EXPORT ${PROJECT_NAME}Targets
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

install(FILES
    ImGuiFileDialog.h
    ImGuiFileDialogConfig.h
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
)

install(EXPORT ${PROJECT_NAME}Targets
    FILE ${PROJECT_NAME}Config.cmake
    NAMESPACE ${PROJECT_NAME}::
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/${PROJECT_NAME}
)
