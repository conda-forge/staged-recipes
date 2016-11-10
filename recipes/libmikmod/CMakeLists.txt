cmake_minimum_required (VERSION 3.1.0)

project (MIKMOD)

include(CheckLibraryExists)
include(CheckIncludeFiles)
include(CheckIncludeFile)

set(MIKMOD_DRIVERS_SRC
    drivers/drv_nos.c
    drivers/drv_raw.c
    drivers/drv_stdout.c
    drivers/drv_wav.c
)

set(MIKMOD_LOADERS_SRC
    loaders/load_669.c
    loaders/load_amf.c
    loaders/load_dsm.c
    loaders/load_far.c
    loaders/load_gdm.c
    loaders/load_imf.c
    loaders/load_it.c
    loaders/load_m15.c
    loaders/load_med.c
    loaders/load_mod.c
    loaders/load_mtm.c
    loaders/load_okt.c
    loaders/load_s3m.c
    loaders/load_stm.c
    loaders/load_stx.c
    loaders/load_ult.c
    loaders/load_uni.c
    loaders/load_xm.c
)

set(MIKMOD_SRC
    mmio/mmalloc.c
    mmio/mmerror.c
    mmio/mmio.c
    playercode/mdreg.c
    playercode/mdriver.c
    playercode/mdulaw.c
    playercode/mloader.c
    playercode/mlreg.c
    playercode/mlutil.c
    playercode/mplayer.c
    playercode/munitrk.c
    playercode/mwav.c
    playercode/npertab.c
    playercode/sloader.c
    playercode/virtch.c
    playercode/virtch2.c
    playercode/virtch_common.c
)

# Options

if (WIN32)
    set(MIKMOD_DRIVERS_SUPPORT_WINMM ON CACHE BOOL "Support for Windows multimedia API")
    set(MIKMOD_DRIVERS_SUPPORT_DS ON CACHE BOOL "Support for DirectSound")

    if(MIKMOD_DRIVERS_SUPPORT_WINMM)
        list(APPEND MIKMOD_DRIVERS_SRC drivers/drv_win.c)
    endif()
    if(MIKMOD_DRIVERS_SUPPORT_DS)
        list(APPEND MIKMOD_DRIVERS_SRC drivers/drv_ds.c)
    endif()
elseif(UNIX)
    set(MIKMOD_DRIVERS_SUPPORT_AF OFF CACHE BOOL "Support for Digital AudioFile")
    set(MIKMOD_DRIVERS_SUPPORT_AIX OFF CACHE BOOL "Support for AIX")
    set(MIKMOD_DRIVERS_SUPPORT_ALSA ON CACHE BOOL "Support for ALSA")
    set(MIKMOD_DRIVERS_SUPPORT_ESD OFF CACHE BOOL "Support for EsounD (Enlightened sound daemon)")
    set(MIKMOD_DRIVERS_SUPPORT_HP OFF CACHE BOOL "Support for HP 9000 series")
    set(MIKMOD_DRIVERS_SUPPORT_OSS OFF CACHE BOOL "Support for Open Sound System (OSS)")
    set(MIKMOD_DRIVERS_SUPPORT_PIPE ON CACHE BOOL "Support for output via pipe")
    set(MIKMOD_DRIVERS_SUPPORT_SAM9407 OFF CACHE BOOL "Support for SAM9407 driver")
    set(MIKMOD_DRIVERS_SUPPORT_SGI OFF CACHE BOOL "Support for SGI audio system")
    set(MIKMOD_DRIVERS_SUPPORT_SUN OFF CACHE BOOL "Support for SUN audio device")
    set(MIKMOD_DRIVERS_SUPPORT_ULTRA OFF CACHE BOOL "Support for Ultrasound device")

    if(MIKMOD_DRIVERS_SUPPORT_AF)
        list(APPEND MIKMOD_DRIVERS_SRC drivers/drv_AF.c)
    endif()
    if(MIKMOD_DRIVERS_SUPPORT_AIX)
        list(APPEND MIKMOD_DRIVERS_SRC drivers/drv_aix.c)
    endif()
    if(MIKMOD_DRIVERS_SUPPORT_ALSA)
        list(APPEND MIKMOD_DRIVERS_SRC drivers/drv_alsa.c)
    endif()
    if(MIKMOD_DRIVERS_SUPPORT_ESD)
        list(APPEND MIKMOD_DRIVERS_SRC drivers/drv_esd.c)
    endif()
    if(MIKMOD_DRIVERS_SUPPORT_HP)
        list(APPEND MIKMOD_DRIVERS_SRC drivers/drv_hp.c)
    endif()
    if(MIKMOD_DRIVERS_SUPPORT_OSS)
        list(APPEND MIKMOD_DRIVERS_SRC drivers/drv_oss.c)
    endif()
    if(MIKMOD_DRIVERS_SUPPORT_PIPE)
        list(APPEND MIKMOD_DRIVERS_SRC drivers/drv_pipe.c)
    endif()
    if(MIKMOD_DRIVERS_SUPPORT_SAM9407)
        list(APPEND MIKMOD_DRIVERS_SRC drivers/drv_sam9407.c)
    endif()
    if(MIKMOD_DRIVERS_SUPPORT_SGI)
        list(APPEND MIKMOD_DRIVERS_SRC drivers/drv_sgi.c)
    endif()
    if(MIKMOD_DRIVERS_SUPPORT_SUN)
        list(APPEND MIKMOD_DRIVERS_SRC drivers/drv_sun.c)
    endif()
    if(MIKMOD_DRIVERS_SUPPORT_ULTRA)
        list(APPEND MIKMOD_DRIVERS_SRC drivers/drv_ultra.c)
    endif()

    if (APPLE)
        set(MIKMOD_DRIVERS_SUPPORT_MAC OFF CACHE BOOL "Support for Macintosh Sound Manager")

        if(MIKMOD_DRIVERS_SUPPORT_MAC)
            list(APPEND MIKMOD_DRIVERS_SRC drivers/drv_mac.c)
        endif()
    endif()
else()
    set(MIKMOD_DRIVERS_SUPPORT_DART OFF CACHE BOOL "Support for DART on OS/2 MMPM/2 using direct audio")
    set(MIKMOD_DRIVERS_SUPPORT_OS2 OFF CACHE BOOL "Support for DART on OS/2 using MMPM/2 MCI interface")

    if(MIKMOD_DRIVERS_SUPPORT_DART)
        list(APPEND MIKMOD_DRIVERS_SRC drivers/drv_dart.c)
    endif()
    if(MIKMOD_DRIVERS_SUPPORT_OS2)
        list(APPEND MIKMOD_DRIVERS_SRC drivers/drv_os2.c)
    endif()
endif()

set(MIKMOD_SOURCES
    ${MIKMOD_SRC}
    ${MIKMOD_DRIVERS_SRC}
    ${MIKMOD_LOADERS_SRC}
)

add_library(MIKMOD SHARED
    ${MIKMOD_SOURCES}
)

set_target_properties(MIKMOD
    PROPERTIES
    ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib"
    LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib"
    RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin"
)

if(WIN32)
    include_directories("${MIKMOD_SOURCE_DIR}/win32")
    if(MSVC)
        add_definitions(-DDLL_EXPORTS)
        configure_file( ${CMAKE_CURRENT_SOURCE_DIR}/win32/mikmod.def ${CMAKE_CURRENT_BINARY_DIR}/win32/mikmod.def @ONLY)
        set_target_properties(MIKMOD PROPERTIES LINK_FLAGS "/DEF:win32/mikmod.def")
    endif()
endif()

include_directories("${MIKMOD_SOURCE_DIR}/include")

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY build)
set_target_properties(MIKMOD
    PROPERTIES PREFIX "" OUTPUT_NAME "mikmod"
)

##### Installation targets #####
install(TARGETS MIKMOD
  LIBRARY DESTINATION "lib${LIB_SUFFIX}"
  ARCHIVE DESTINATION "lib${LIB_SUFFIX}"
  RUNTIME DESTINATION bin)

file(GLOB INCLUDE_FILES ${CMAKE_CURRENT_SOURCE_DIR}/include/*.h)
install(FILES ${INCLUDE_FILES} DESTINATION include/libmikmod)
