cmake_minimum_required(VERSION 3.16)
project(imgui CXX)

set(CMAKE_DEBUG_POSTFIX d)
include(GNUInstallDirs)

if(APPLE)
    set(CMAKE_CXX_STANDARD 11)
    enable_language(OBJCXX)
endif()

add_library(${PROJECT_NAME} "")
add_library(${PROJECT_NAME}::${PROJECT_NAME} ALIAS ${PROJECT_NAME})
target_include_directories(
    ${PROJECT_NAME}
    PUBLIC
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
        $<INSTALL_INTERFACE:include>
)

target_sources(
    ${PROJECT_NAME}
    PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}/imgui.cpp
        ${CMAKE_CURRENT_SOURCE_DIR}/imgui_demo.cpp
        ${CMAKE_CURRENT_SOURCE_DIR}/imgui_draw.cpp
        ${CMAKE_CURRENT_SOURCE_DIR}/imgui_tables.cpp
        ${CMAKE_CURRENT_SOURCE_DIR}/imgui_widgets.cpp
        ${CMAKE_CURRENT_SOURCE_DIR}/misc/cpp/imgui_stdlib.cpp
)

target_compile_features(${PROJECT_NAME} PUBLIC cxx_std_11)

if(MSVC AND BUILD_SHARED_LIBS)
    include(GenerateExportHeader)
    generate_export_header(${PROJECT_NAME}
        EXPORT_MACRO_NAME IMGUI_API
        EXPORT_FILE_NAME ${CMAKE_CURRENT_SOURCE_DIR}/imconfig.h
    )
endif()

if(IMGUI_BUILD_DX11_BINDING)
    target_sources(${PROJECT_NAME} PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/backends/imgui_impl_dx11.cpp)
endif()

if(IMGUI_BUILD_GLFW_BINDING)
    if(NOT EMSCRIPTEN)
        find_package(glfw3 CONFIG REQUIRED)
        target_link_libraries(${PROJECT_NAME} PUBLIC glfw)
    endif()
    target_sources(${PROJECT_NAME} PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/backends/imgui_impl_glfw.cpp)
endif()

if(IMGUI_BUILD_METAL_BINDING)
    target_sources(${PROJECT_NAME} PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/backends/imgui_impl_metal.mm)
    set_source_files_properties(${CMAKE_CURRENT_SOURCE_DIR}/backends/imgui_impl_metal.mm PROPERTIES COMPILE_FLAGS -fobjc-weak)
    target_link_libraries(${PROJECT_NAME} PUBLIC "-framework Metal" "-framework Foundation" "-framework CoreFoundation" "-framework QuartzCore")
    target_link_libraries(${PROJECT_NAME} PRIVATE objc)
endif()

if(IMGUI_BUILD_OPENGL3_BINDING)
    target_sources(${PROJECT_NAME} PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/backends/imgui_impl_opengl3.cpp)
    if(APPLE)
        target_link_libraries(${PROJECT_NAME} PUBLIC "-framework OpenGL")
    else()
        find_package(OpenGL REQUIRED)
        target_link_libraries(${PROJECT_NAME} PRIVATE OpenGL::GL)
    endif()
endif()

if(IMGUI_BUILD_WIN32_BINDING)
    target_sources(${PROJECT_NAME} PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/backends/imgui_impl_win32.cpp)
endif()

if(IMGUI_FREETYPE)
    find_package(Freetype REQUIRED)
    target_link_libraries(${PROJECT_NAME} PUBLIC Freetype::Freetype)
    target_sources(${PROJECT_NAME} PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/misc/freetype/imgui_freetype.cpp)
    target_compile_definitions(${PROJECT_NAME} PUBLIC IMGUI_ENABLE_FREETYPE)
endif()

if(IMGUI_USE_WCHAR32)
    target_compile_definitions(${PROJECT_NAME} PUBLIC IMGUI_USE_WCHAR32)
endif()

if(IMGUI_32BIT_DRAW_IDX)
    target_compile_definitions(${PROJECT_NAME} PUBLIC "ImDrawIdx=unsigned int")
endif()

target_compile_definitions(${PROJECT_NAME} PUBLIC IMGUI_DEFINE_MATH_OPERATORS)

install(
    TARGETS ${PROJECT_NAME}
    EXPORT ${PROJECT_NAME}_target
)

if(NOT IMGUI_SKIP_HEADERS)
    install(FILES
        ${CMAKE_CURRENT_SOURCE_DIR}/imgui.h
        ${CMAKE_CURRENT_SOURCE_DIR}/imconfig.h
        ${CMAKE_CURRENT_SOURCE_DIR}/imgui_internal.h
        ${CMAKE_CURRENT_SOURCE_DIR}/imstb_textedit.h
        ${CMAKE_CURRENT_SOURCE_DIR}/imstb_rectpack.h
        ${CMAKE_CURRENT_SOURCE_DIR}/imstb_truetype.h
        ${CMAKE_CURRENT_SOURCE_DIR}/misc/cpp/imgui_stdlib.h
        DESTINATION include
    )

    if(IMGUI_BUILD_DX11_BINDING)
        install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/backends/imgui_impl_dx11.h DESTINATION include)
    endif()

    if(IMGUI_BUILD_GLFW_BINDING)
        install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/backends/imgui_impl_glfw.h DESTINATION include)
    endif()

    if(IMGUI_BUILD_METAL_BINDING)
        install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/backends/imgui_impl_metal.h DESTINATION include)
    endif()

    if(IMGUI_BUILD_OPENGL3_BINDING)
        install(
            FILES
                ${CMAKE_CURRENT_SOURCE_DIR}/backends/imgui_impl_opengl3.h
                ${CMAKE_CURRENT_SOURCE_DIR}/backends/imgui_impl_opengl3_loader.h
            DESTINATION
                include
        )
    endif()

    if(IMGUI_BUILD_WIN32_BINDING)
        install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/backends/imgui_impl_win32.h DESTINATION include)
    endif()

    if(IMGUI_FREETYPE)
        install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/misc/freetype/imgui_freetype.h DESTINATION include)
    endif()
endif()

include(CMakePackageConfigHelpers)
configure_package_config_file(imgui-config.cmake.in imgui-config.cmake INSTALL_DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/${PROJECT_NAME})

install(FILES ${CMAKE_CURRENT_BINARY_DIR}/imgui-config.cmake DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/${PROJECT_NAME})

install(
    EXPORT ${PROJECT_NAME}_target
    NAMESPACE ${PROJECT_NAME}::
    FILE ${PROJECT_NAME}-targets.cmake
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/${PROJECT_NAME}
)
