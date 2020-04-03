# adopted from https://github.com/kattkieru/sdl/blob/master/CMakeLists.txt
cmake_minimum_required(VERSION 3.4)

set(SDL ${CMAKE_CURRENT_SOURCE_DIR})

file(
    GLOB SDL_SOURCES
    ${SDL}/src/*.c
    ${SDL}/src/audio/*.c
    ${SDL}/src/audio/disk/*.c
    ${SDL}/src/audio/dummy/*.c
    ${SDL}/src/cdrom/*.c
    ${SDL}/src/cdrom/dummy/*.c
    ${SDL}/src/cpuinfo/*.c
    ${SDL}/src/events/*.c
    ${SDL}/src/file/*.c
    ${SDL}/src/joystick/*.c
    ${SDL}/src/stdlib/*.c
    ${SDL}/src/thread/*.c
    ${SDL}/src/timer/*.c
    ${SDL}/src/video/*.c
    ${SDL}/src/video/dummy/*.c
)

file(
    GLOB SDL_WIN32_SOURCES
    ${SDL}/src/audio/windib/*.c
    ${SDL}/src/audio/windx5/*.c
    ${SDL}/src/cdrom/win32/*.c
    ${SDL}/src/joystick/win32/*.c
    ${SDL}/src/loadso/win32/*.c
    ${SDL}/src/thread/win32/*.c
    ${SDL}/src/thread/generic/SDL_syscond.c
    ${SDL}/src/timer/win32/*.c
    ${SDL}/src/video/wincommon/*.c
    ${SDL}/src/video/windib/*.c
    ${SDL}/src/video/windx5/*.c
)

file(
    GLOB SDL_MACOS_SOURCES
    ${SDL}/src/audio/macosx/*.c
    ${SDL}/src/cdrom/macosx/*.c
    ${SDL}/src/joystick/darwin/*.c
    ${SDL}/src/loadso/dlopen/*.c
    ${SDL}/src/loadso/macosx/*.c
    ${SDL}/src/thread/generic/*.c
    # ${SDL}/src/thread/pthread/*.c
    ${SDL}/src/timer/unix/*.c
    ${SDL}/src/video/quartz/*.m
)

set(LIBSDL_SOURCES ${SDL_SOURCES})

if (WIN32)
    set(LIBSDL_SOURCES ${LIBSDL_SOURCES} ${SDL_WIN32_SOURCES})
    set(LIBSDLMAIN_SOURCES ${SDL}/src/main/win32/SDL_win32_main.c)
    file(STRINGS ${SDL}/include/SDL_config.h.default SDL_CONFIG_HEADER)
    message(AUTHOR_WARNING "+ Building for Windows.")
elseif(UNIX AND APPLE)
    set(LIBSDL_SOURCES ${LIBSDL_SOURCES} ${SDL_MACOS_SOURCES})
    set(LIBSDLMAIN_SOURCES ${SDL}/src/main/macosx/SDLMain.m)

    ## copy over a pre-created macOS config
    set(CFLAGS "-Wall -Wextra -O2 -g -fomit-frame-pointer -fPIC")
    set(CXXFLAGS "${CFLAGS} -fno-exceptions -fno-rtti")

    file(STRINGS ${CMAKE_CURRENT_SOURCE_DIR}/SDL_config.h.macOS SDL_CONFIG_HEADER)
    message(AUTHOR_WARNING "+ Building for macOS.")
else()
    message(FATAL_ERROR "Unknown operating system-- aborting.")
endif()

string(REPLACE ";" "\n" SDL_CONFIG_HEADER "${SDL_CONFIG_HEADER}")
file(WRITE ${SDL}/include/SDL_config.h "${SDL_CONFIG_HEADER}")

add_library(SDL ${LIBSDL_SOURCES})
target_include_directories(SDL PUBLIC ${SDL}/include)
if(WIN32)
    target_link_libraries(SDL winmm.lib dxguid.lib)
    target_compile_definitions(SDL PRIVATE _CRT_SECURE_NO_DEPRECATE)
endif()

add_library(SDLmain STATIC ${LIBSDLMAIN_SOURCES})
target_include_directories(SDLmain PUBLIC ${SDL}/include)

install(TARGETS SDL SDLmain
  ARCHIVE DESTINATION lib
  LIBRARY DESTINATION lib
  RUNTIME DESTINATION bin
)

file(
    GLOB SDL_HEADERS
    ${SDL}/include/*.h
)

install(FILES ${SDL_HEADERS}
  DESTINATION include/SDL
)
