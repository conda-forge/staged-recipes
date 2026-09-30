# Windows-only build; upstream ships just a MinGW qmake project (gource.pro),
# whose source list and defines this mirrors.
cmake_minimum_required(VERSION 3.20)
project(gource LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(OpenGL REQUIRED COMPONENTS OpenGL)
find_package(GLEW REQUIRED)
find_package(SDL2 CONFIG REQUIRED)
find_package(SDL2_image CONFIG REQUIRED)
find_package(Freetype REQUIRED)
find_package(PNG REQUIRED)
find_package(PCRE2 CONFIG REQUIRED COMPONENTS 8BIT)
find_package(glm CONFIG REQUIRED)
find_package(Boost CONFIG REQUIRED COMPONENTS filesystem)

add_executable(gource
    src/action.cpp
    src/bloom.cpp
    src/caption.cpp
    src/dirnode.cpp
    src/file.cpp
    src/gource.cpp
    src/gource_settings.cpp
    src/gource_shell.cpp
    src/key.cpp
    src/logmill.cpp
    src/main.cpp
    src/pawn.cpp
    src/slider.cpp
    src/spline.cpp
    src/textbox.cpp
    src/user.cpp
    src/zoomcamera.cpp
    src/formats/apache.cpp
    src/formats/bzr.cpp
    src/formats/commitlog.cpp
    src/formats/custom.cpp
    src/formats/cvs-exp.cpp
    src/formats/cvs2cl.cpp
    src/formats/git.cpp
    src/formats/gitraw.cpp
    src/formats/hg.cpp
    src/formats/svn.cpp
    src/tinyxml/tinystr.cpp
    src/tinyxml/tinyxml.cpp
    src/tinyxml/tinyxmlerror.cpp
    src/tinyxml/tinyxmlparser.cpp
    src/core/conffile.cpp
    src/core/display.cpp
    src/core/frustum.cpp
    src/core/fxfont.cpp
    src/core/logger.cpp
    src/core/mousecursor.cpp
    src/core/plane.cpp
    src/core/png_writer.cpp
    src/core/ppm.cpp
    src/core/quadtree.cpp
    src/core/regex.cpp
    src/core/resource.cpp
    src/core/sdlapp.cpp
    src/core/seeklog.cpp
    src/core/settings.cpp
    src/core/shader.cpp
    src/core/shader_common.cpp
    src/core/stringhash.cpp
    src/core/texture.cpp
    src/core/tga.cpp
    src/core/timezone.cpp
    src/core/vbo.cpp
    src/core/vectors.cpp
)

target_link_libraries(gource PRIVATE
    SDL2::SDL2main
    SDL2::SDL2
    SDL2_image::SDL2_image
    GLEW::GLEW
    OpenGL::GL
    OpenGL::GLU
    Freetype::Freetype
    PNG::PNG
    PCRE2::8BIT
    glm::glm-header-only
    Boost::filesystem
)

if(MSVC)
    # Sources include <unistd.h> unguarded and call getcwd/chdir, which MSVC
    # declares in <direct.h>; the shim dir supplies a unistd.h that pulls both in.
    target_include_directories(gource PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/msvc)
    target_compile_options(gource PRIVATE /FIdirect.h /utf-8)
    target_compile_definitions(gource PRIVATE _CRT_SECURE_NO_WARNINGS NOMINMAX)
endif()

# Windows gource resolves its data dir as <exe dir>\data\.
install(TARGETS gource RUNTIME DESTINATION bin)
install(DIRECTORY data/ DESTINATION bin/data
    PATTERN "gource.1" EXCLUDE)
