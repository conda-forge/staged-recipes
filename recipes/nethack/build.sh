#!/usr/bin/env bash
set -euo pipefail

LUA_VERSION=5.4.8

# Pick a hints file appropriate for the host platform. The linux.500 hints
# probe libuuid via /sbin/ldconfig (Linux-only) and assume GNU userland;
# macOS.500 sets macOS-specific defines and avoids that probe.
case "$(uname -s)" in
    Darwin) HINTS=hints/macOS.500 ;;
    *)      HINTS=hints/linux.500 ;;
esac

# Generate the active Makefiles from the hints file. The two source patches
# applied earlier (see recipe.yaml) make compiler.500's CFLAGS assignment
# additive so the conda env flags survive, and add -llua to LUALIBS so we
# pick up conda-forge's liblua at link time.
( cd sys/unix && sh setup.sh "$HINTS" )

# Stand in for `make fetch-Lua`: instead of downloading and building lua
# from source, point NetHack at conda-forge's lua headers and provide stub
# archives at the paths the makefile's lua dependency rules expect. The
# nhlua.h generation rule reads lua.h via `../lib/lua-X.Y.Z/src/...`, so
# the headers must live under that exact path.
mkdir -p "lib/lua-${LUA_VERSION}/src" lib/lua
cp "$PREFIX/include/lua.h" "lib/lua-${LUA_VERSION}/src/"
cp "$PREFIX/include/lualib.h" "lib/lua-${LUA_VERSION}/src/"
cp "$PREFIX/include/lauxlib.h" "lib/lua-${LUA_VERSION}/src/"
cp "$PREFIX/include/luaconf.h" "lib/lua-${LUA_VERSION}/src/"
echo "static int _stub_lua;" > stub_lua.c
"${CC:-cc}" -c stub_lua.c -o stub_lua.o
"${AR:-ar}" rcs "lib/lua-${LUA_VERSION}/src/liblua.a" stub_lua.o
"${AR:-ar}" rcs "lib/lua/liblua-${LUA_VERSION}.a" stub_lua.o
rm -f stub_lua.c stub_lua.o

# NetHack uses LFLAGS (not LDFLAGS) for linker flags. Export it so the
# `LFLAGS+=` lines in hints (e.g. -rdynamic on Linux) extend our value
# rather than replace it; this gets `-L$PREFIX/lib` into the link line so
# we pick up conda-forge ncurses and lua instead of the system ones.
export LFLAGS="${LDFLAGS:-}"

# Override the install paths from the hints file so everything lands inside
# $PREFIX (conda layout) instead of ~/nh/install or /Library/NetHack.
MAKE_OVERRIDES=(
    PREFIX="$PREFIX"
    HACKDIR="$PREFIX/share/nethack"
    SHELLDIR="$PREFIX/bin"
    GAMEUID="$(id -un)"
    GAMEGRP="$(id -gn)"
    CHOWN=true
    CHGRP=true
    NO_NHUUID=1
)

make "${MAKE_OVERRIDES[@]}" all
make "${MAKE_OVERRIDES[@]}" install
