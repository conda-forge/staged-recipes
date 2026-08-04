#!/bin/bash

set -euxo pipefail

# FreeRDP builds with CMake. ${CMAKE_ARGS} carries conda's cross toolchain
# file and the usual install/rpath settings; the prefix and libdir are set
# explicitly so everything lands in $PREFIX/lib rather than lib64.
#
# This build targets Weston's rdp backend, which needs the server libraries
# (freerdp-server3.pc + winpr3.pc + freerdp3.pc). Everything Weston does not
# need is turned off to keep the dependency surface small:
#   * WITH_CLIENT / WITH_CLIENT_COMMON / WITH_CLIENT_SDL: the client binaries
#     and the SDL GUI client are not used.
#   * WITH_SAMPLE / WITH_SHADOW / WITH_PROXY / WITH_PLATFORM_SERVER: standalone
#     server/proxy applications; Weston links the freerdp-server library itself.
#   * WITH_X11 / WITH_WAYLAND: X11 and Wayland (wlfreerdp/uwac) clients.
#   * WITH_FFMPEG / WITH_SWSCALE / WITH_CAIRO: optional codec/scaling backends.
#   * WITH_ALSA / WITH_PULSE / WITH_OSS: sound backends.
#   * WITH_MANPAGES: avoids the docs toolchain.
#   * BUILD_TESTING: unit tests.
# The core libraries and the virtual channel plugins (WITH_CHANNELS, on by
# default) are kept. NLA authentication still works through NTLM.
#
# WITH_KRB5 is turned off: FreeRDP calls krb5_get_init_creds_opt_set_pac_request
# unconditionally, but conda-forge's krb5 does not export that symbol, so a
# Kerberos build cannot link. Weston's RDP backend does not require Kerberos
# single sign-on.
# FreeRDP forbids in-source builds, so configure from a dedicated directory.
mkdir -p build
cd build

cmake -G Ninja ${CMAKE_ARGS} \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX=$PREFIX \
  -DCMAKE_INSTALL_LIBDIR=lib \
  -DBUILD_SHARED_LIBS=ON \
  -DWITH_LIBRARY_SOVERSIONING=ON \
  -DWITH_SERVER=ON \
  -DWITH_SERVER_INTERFACE=ON \
  -DWITH_CLIENT=OFF \
  -DWITH_CLIENT_COMMON=OFF \
  -DWITH_CLIENT_SDL=OFF \
  -DWITH_SAMPLE=OFF \
  -DWITH_SHADOW=OFF \
  -DWITH_PROXY=OFF \
  -DWITH_PLATFORM_SERVER=OFF \
  -DWITH_X11=OFF \
  -DWITH_WAYLAND=OFF \
  -DWITH_FFMPEG=OFF \
  -DWITH_SWSCALE=OFF \
  -DWITH_CAIRO=OFF \
  -DWITH_ALSA=OFF \
  -DWITH_PULSE=OFF \
  -DWITH_OSS=OFF \
  -DWITH_KRB5=OFF \
  -DWITH_JSONC_REQUIRED=ON \
  -DWITH_MANPAGES=OFF \
  -DBUILD_TESTING=OFF \
  $SRC_DIR

cmake --build . -j ${CPU_COUNT}
cmake --install .
