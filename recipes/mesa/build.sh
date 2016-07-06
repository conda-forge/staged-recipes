#!/usr/bin/env bash

# FIXME: This is a hack to make sure the environment is activated.
# The reason this is required is due to the conda-build issue
# mentioned below.
#
# https://github.com/conda/conda-build/issues/910
#
source activate "${CONDA_DEFAULT_ENV}"

scons llvm=no build=release osmesa mesa libgl-xlib

#
#Checking for GCC ...  yes
#Checking for Clang ...  no
#scons: Found LLVM version 3.3
#Checking for X11 (x11 xext xdamage xfixes glproto >= 1.4.13)... yes
#Checking for XCB (x11-xcb xcb-glx >= 1.8.1 xcb-dri2 >= 1.8)... yes
#Checking for XF86VIDMODE (xxf86vm)... yes
#Checking for DRM (libdrm >= 2.4.38)... yes
#Checking for UDEV (libudev >= 151)... no
#fatal: Not a git repository (or any of the parent directories): .git
#scons: done reading SConscript files.
#
#build: build type (debug|checked|profile|release)
#    default: debug
#    actual: debug
#
#verbose: verbose output (yes|no)
#    default: no
#    actual: False
#
#machine: use machine-specific assembly code (generic|ppc|x86|x86_64)
#    default: x86_64
#    actual: x86_64
#
#platform: target platform (cygwin|darwin|freebsd|haiku|linux|sunos|windows)
#    default: linux
#    actual: linux
#
#embedded: embedded build (yes|no)
#    default: no
#    actual: False
#
#analyze: enable static code analysis where available (yes|no)
#    default: no
#    actual: False
#
#toolchain: compiler toolchain
#    default: default
#    actual: default
#
#gles: EXPERIMENTAL: enable OpenGL ES support (yes|no)
#    default: no
#    actual: False
#
#llvm: use LLVM (yes|no)
#    default: yes
#    actual: True
#
#openmp: EXPERIMENTAL: compile with openmp (swrast) (yes|no)
#    default: no
#    actual: False
#
#debug: DEPRECATED: debug build (yes|no)
#    default: yes
#    actual: True
#
#profile: DEPRECATED: profile build (yes|no)
#    default: no
#    actual: False
#
#quiet: DEPRECATED: profile build (yes|no)
#    default: yes
#    actual: True
#
#texture_float: enable floating-point textures and renderbuffers (yes|no)
#    default: no
#    actual: False
#
#Recognized targets:
#    dri-swrast
#    dri-vmwgfx
#    gallium
#    glcpp
#    glsl_compiler
#    glx
#    graw-progs
#    graw-xlib
#    libgl
#    libgl-xlib
#    libgl-xlib-swrast
#    libloader
#    llvmpipe
#    lp_test_arit
#    lp_test_blend
#    lp_test_conv
#    lp_test_format
#    lp_test_printf
#    megadrivers_stub
#    mesa
#    mesautil
#    osmesa
#    pipe_barrier_test
#    pipe_loader
#    rbug
#    roundeven_test
#    softpipe
#    svga
#    trace
#    translate_test
#    u_atomic_test
#    u_cache_test
#    u_format_compatible_test
#    u_format_test
#    u_half_test
#    unit
#    ws_null
#    ws_xlib
#
