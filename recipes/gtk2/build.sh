#!/usr/bin/env bash

set -exuo pipefail

# Get an updated config.sub and config.guess
cp $BUILD_PREFIX/share/gnuconfig/config.* .

export XDG_DATA_DIRS=${XDG_DATA_DIRS:-}${XDG_DATA_DIRS:+:}$PREFIX/share

PKG_CONFIG_PATH="${PREFIX}/lib/pkgconfig:${PREFIX}/share/pkgconfig:${BUILD_PREFIX}/lib/pkgconfig${PKG_CONFIG_PATH:+:}${PKG_CONFIG_PATH:-}"
GDKTARGET=""
if [[ "${target_platform}" == osx-* ]]; then
    export PKG_CONFIG_PATH
    export GDKTARGET="quartz"
    export LDFLAGS="${LDFLAGS} -Wl,-rpath,${PREFIX}/lib -framework Carbon"
    # https://discourse.llvm.org/t/clang-16-notice-of-potentially-breaking-changes/65562
    export CFLAGS="${CFLAGS} -Wno-error=incompatible-function-pointer-types"
elif [[ "${target_platform}" == linux-* ]]; then
    export PKG_CONFIG_PATH
    export GDKTARGET="x11"
    export LDFLAGS="${LDFLAGS} -Wl,-rpath=${PREFIX}/lib"
elif [[ "${target_platform}" == win-* ]]; then
    source "${RECIPE_DIR}/non-unix-helpers/library_lflags_update.sh"

    host_conda_libs="${PREFIX}/Library/lib"
    build_conda_libs="${BUILD_PREFIX}/Library/lib"
    system_libs_exclude=(
      "uuid" "gdi32" "imm32" "shell32" "usp10" "ole32" "rpcrt4" "shlwapi" "iphlpapi"
      "dnsapi" "ws2_32" "winmm" "msimg32" "dwrite" "d2d1" "windowscodecs" "dl" "m" "dld"
      "svld" "w" "mlib" "dnet" "dnet_stub" "nsl" "bsd" "socket" "posix" "ipc" "XextSan"
      "ICE" "Xinerama" "papi"
    )
    exclude_regex=$(printf "|^%s$" "${system_libs_exclude[@]}")
    exclude_regex=${exclude_regex:1}

    # Set the prefix to the PKG_CONFIG_PATH
    paths=(
        "${host_conda_libs}/pkgconfig"
        "${build_conda_libs}/pkgconfig"
    )

    # Loop through the paths and update PKG_CONFIG_PATH
    for path in "${paths[@]}"; do
        PKG_CONFIG_PATH="${PKG_CONFIG_PATH:-}${PKG_CONFIG_PATH:+:}${path}"
    done

    # There seemed to be issues with unix path in some parts of the flow
    PKG_CONFIG=$(which pkg-config.exe | sed -E 's|^/(\w)|\1:|')
    PKG_CONFIG=$(echo "${RECIPE_DIR}/non-unix-helpers/my-pkg-config.sh" | sed -E 's|^/(\w)|\1:|')
    PKG_CONFIG_PATH=$(echo "$PKG_CONFIG_PATH" | sed -E 's|^(\w):|/\1|' | sed -E 's|:(\w):|:/\1|g')

    export PKG_CONFIG
    export PKG_CONFIG_PATH
    export PKG_CONFIG_LIBDIR="${PKG_CONFIG_PATH}"

    export PATH="${BUILD_PREFIX}/Library/bin:${PREFIX}/Library/bin${PATH:+:${PATH:-}}"

    export PERL5LIB="${BUILD_PREFIX}/lib/perl5/site-perl:${PERL5LIB:+:${PERL5LIB:-}}"
    export GDKTARGET="win32"

    # Those are python scripts that fail to find the python interpreter
    PYTHON="$(which python)"
    GLIB_COMPILE_RESOURCES="$PYTHON $(which glib-compile-resources)"
    GLIB_MKENUMS="$PYTHON $(which glib-mkenums)"
    GLIB_GENMARSHAL="$PYTHON $(which glib-genmarshal)"
    export GLIB_COMPILE_RESOURCES GLIB_GENMARSHAL GLIB_MKENUMS

    # Loop over the dependencies and get the cflags and libs
    # We need to replace the -l<lib> with the full path to the library
    BASE_DEPENDENCIES_CFLAGS=""
    BASE_DEPENDENCIES_LIBS=""
    for dep in "glib-2.0 >= 2.28.0" "atk >= 1.29.2" "pango >= 1.20" "cairo >= 1.6" "gdk-pixbuf-2.0 >= 2.21.0"; do
      cflags=$($PKG_CONFIG --cflags "$dep")
      if [ $? -ne 0 ]; then
        echo "Error: Failed to get CFLAGS for $dep"
        exit 1
      fi
      libs=$($PKG_CONFIG --libs "$dep")
      if [ $? -ne 0 ]; then
        echo "Error: Failed to get LIBS for $dep"
        exit 1
      fi
      BASE_DEPENDENCIES_CFLAGS="${cflags} ${BASE_DEPENDENCIES_CFLAGS}"
      BASE_DEPENDENCIES_LIBS="${libs} ${BASE_DEPENDENCIES_LIBS}"
    done
    BASE_DEPENDENCIES_CFLAGS=$(unique_from_last "${BASE_DEPENDENCIES_CFLAGS}")
    BASE_DEPENDENCIES_LIBS=$(unique_from_last "${BASE_DEPENDENCIES_LIBS}")
    BASE_DEPENDENCIES_LIBS=$(replace_l_flags "${BASE_DEPENDENCIES_LIBS}" "${host_conda_libs}" "${build_conda_libs}")

    export BASE_DEPENDENCIES_CFLAGS
    export BASE_DEPENDENCIES_LIBS

    # Odd case of pkg-config not having the --uninstalled option on non-unix.
    # Replace all the '$PKG_CONFIG +--uninstalled with false || $PKG_CONFIG --uninstalled
    # perl -i -pe 's/\$PKG_CONFIG --uninstalled/false \&\& $PKG_CONFIG --uninstalled/g' configure

    # This test fails, let's force it to pass for now
    # perl -i -pe 's/\$PKG_CONFIG --atleast-version \$min_glib_version \$pkg_config_args/test x = x/g' configure

    # -Lppp -lxxx will apparently look for ppp/libxxx.lib (or dll.a), only ppp/xxx.lib exists - Only -lintl & -liconv present
    perl -i -pe "s#-lintl#${PREFIX}/Library/lib/intl.lib#g if /^\s*[IL]\w*IBS/" configure
    perl -i -pe "s#-liconv#${BUILD_PREFIX}/Library/lib/iconv.lib#g if /^\s*[IL]\w*IBS/" configure

    export LIBRARY_PATH="${build_conda_libs}:${host_conda_libs}${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH:-}}"
fi

configure_args=(
    --disable-dependency-tracking
    --disable-silent-rules
    --disable-glibtest
    --enable-introspection=yes
    --with-gdktarget="${GDKTARGET}"
    --disable-visibility
    --with-html-dir="${SRC_DIR}/html"
)
if [[ "${target_platform}" == win-* ]]; then
  configure_args+=(
    "--libexecdir=${PREFIX}/Library/bin"
    "--libdir=${host_conda_libs}"
    "--includedir=${PREFIX}/Library/include"
    "--enable-shared"
    "--disable-static"
    "--enable-explicit-deps=yes"
  )
fi

if [[ "${CONDA_BUILD_CROSS_COMPILATION:-0}" == 1 ]]; then
  unset _CONDA_PYTHON_SYSCONFIGDATA_NAME
  (
    mkdir -p native-build
    pushd native-build

    export CC=$CC_FOR_BUILD
    export AR=($CC_FOR_BUILD -print-prog-name=ar)
    export NM=($CC_FOR_BUILD -print-prog-name=nm)
    export LDFLAGS=${LDFLAGS//$PREFIX/$BUILD_PREFIX}
    export PKG_CONFIG_PATH=${BUILD_PREFIX}/lib/pkgconfig

    # Unset them as we're ok with builds that are either slow or non-portable
    unset CFLAGS
    unset CPPFLAGS
    export host_alias=$build_alias
    export PKG_CONFIG_PATH=$BUILD_PREFIX/lib/pkgconfig

    ../configure --prefix=$BUILD_PREFIX "${configure_args[@]}"

    # This script would generate the functions.txt and dump.xml and save them
    # This is loaded in the native build. We assume that the functions exported
    # by glib are the same for the native and cross builds
    export GI_CROSS_LAUNCHER=$BUILD_PREFIX/libexec/gi-cross-launcher-save.sh
    make -j${CPU_COUNT}
    make install
    popd
  )
  export GI_CROSS_LAUNCHER=$BUILD_PREFIX/libexec/gi-cross-launcher-load.sh

  # The build system needs to run glib tools like `glib-mkenums` but discovers
  # the path to them using pkg-config by default. If we let this happen, when
  # cross-compiling it will try to run a program with the wrong CPU type.
  export GLIB_COMPILE_RESOURCES=$BUILD_PREFIX/bin/glib-compile-resources
  export GLIB_GENMARSHAL=$BUILD_PREFIX/bin/glib-genmarshal
  export GLIB_MKENUMS=$BUILD_PREFIX/bin/glib-mkenums
fi

./configure --enable-debug=yes \
    --prefix="${PREFIX}" \
    "${configure_args[@]}"

if [[ "${target_platform}" == win-* ]]; then
  echo "Modifying Makefiles for -l<conda_lib>"
  # -Lppp -lxxx will apparently look for ppp/libxxx.lib (or dll.a), only ppp/xxx.lib exists
  makefiles=(
    "Makefile"
    "gdk/Makefile"
    "gdk/win32/Makefile"
    "gtk/Makefile"
    "modules/Makefile"
    "modules/engines/ms-windows/Makefile"
    "modules/engines/pixbuf/Makefile"
    "modules/input/Makefile"
    "modules/other/gail/libgail-util/Makefile"
    "modules/other/gail/tests/Makefile"
    "modules/other/gail/Makefile"
    "demos/gtk-demo/Makefile"
    "demos/Makefile"
    "tests/Makefile"
    "perf/Makefile"
  )
  replace_l_flag_in_files "${exclude_regex}" "${makefiles[@]}"

  # It appears that pkg-config is difficult to find within the mix of win/unix path separator (or at least that's how it appeared to me)
  perl -i -pe "s|(PKG_CONFIG)(\s*)=.*|\1\2=\2${PKG_CONFIG}|g"  "${makefiles[@]}"

  # Similarly for the .gir paths
  perl -i -pe "s|(--add-include-path=../gdk)|\1 --add-include-path=${BUILD_PREFIX}/Library/share/gir-1.0 --add-include-path=${PREFIX}/Library/share/gir-1.0|" "${makefiles[@]}"

  perl -i -pe "s|(\s+--includedir=\.)|\1 --includedir=${BUILD_PREFIX}/Library/share/gir-1.0 --includedir=${PREFIX}/Library/share/gir-1.0|" gdk/Makefile
  perl -i -pe "s|(\s+--includedir=\.\./gdk)|\1 --includedir=${BUILD_PREFIX}/Library/share/gir-1.0 --includedir=${PREFIX}/Library/share/gir-1.0|" gtk/Makefile

  # It seems that libtool is missing some dynamic libraries to create the .dll
  perl -i -pe "s|(libgdk_win32_2_0_la_LIBADD = win32/libgdk-win32.la)|\1 -Wl,-L${build_conda_libs} -Wl,-L${host_conda_libs} -Wl,-lglib-2.0 -Wl,-lgobject-2.0 -Wl,-lgio-2.0 -Wl,-lcairo -Wl,-lgdk_pixbuf-2.0 -Wl,-lpango-1.0 -Wl,-lpangocairo-1.0 -Wl,-lintl|" gdk/Makefile
  perl -i -pe "s|(libgtk_win32_2_0_la_LIBADD.+?-lcomctl32)|\1 -Wl,-L${build_conda_libs} -Wl,-L${host_conda_libs} -Wl,-lglib-2.0 -Wl,-lgmodule-2.0 -Wl,-lgobject-2.0 -Wl,-latk-1.0 -Wl,-lgio-2.0 -Wl,-lcairo -Wl,-lgdk_pixbuf-2.0 -Wl,-lpango-1.0 -Wl,-lpangocairo-1.0 -Wl,-lintl|" gtk/Makefile
  perl -i -pe "s|(libwimp_la_LIBADD.+?gdi32)|\1 -Wl,-L${build_conda_libs} -Wl,-L${host_conda_libs} -Wl,-lglib-2.0 -Wl,-lgmodule-2.0 -Wl,-lgobject-2.0 -Wl,-lgio-2.0 -Wl,-lcairo -Wl,-lpango-1.0 -Wl,-lpangowin32-1.0|" modules/engines/ms-windows/Makefile
  perl -i -pe "s|(libpixmap_la_LIBADD.+?ADDS\))|\1 ../../../gtk/.libs/libgtk-win32-2.0.dll -Wl,-L${build_conda_libs} -Wl,-L${host_conda_libs} -Wl,-lglib-2.0 -Wl,-lgmodule-2.0 -Wl,-lgobject-2.0 -Wl,-lgio-2.0 -Wl,-lgdk_pixbuf-2.0 -Wl,-lcairo|" modules/engines/pixbuf/Makefile

  perl -i -pe "s|(im_\w+_LIBADD.+?ADDS\))|\1 -Wl,-L${build_conda_libs} -Wl,-L${host_conda_libs} -Wl,-lgmodule-2.0 -Wl,-lgobject-2.0|" modules/input/Makefile
  perl -i -pe "s#(im_(ime|multipress|thai)_la_LIBADD.+?gobject-2.0)#\1 -Wl,-lglib-2.0 -Wl,-lpango-1.0 -Wl,-lpangowin32-1.0#" modules/input/Makefile

  perl -i -pe "s#(libgailutil_la_LIBADD = )#\1 -Wl,-lglib-2.0 -Wl,-lgobject-2.0 -Wl,-latk-1.0 -Wl,-lpango-1.0 -Wl,-lpangowin32-1.0#" modules/other/gail/libgail-util/Makefile
  perl -i -pe "s#(lib\w+_LIBADD =)#\1 -Wl,-lglib-2.0 -Wl,-lgobject-2.0 -Wl,-latk-1.0#" modules/other/gail/tests/Makefile
  perl -i -pe "s#(libgail\w+_LIBADD = )#\1 -Wl,-lglib-2.0 -Wl,-lgmodule-2.0 -Wl,-lgobject-2.0 -Wl,-lgdk_pixbuf-2.0 -Wl,-lpango-1.0 -Wl,-lpangowin32-1.0 -Wl,-latk-1.0#" modules/other/gail/Makefile

  # Linker seems to get confused with mixed unix/non-unix paths
  perl -i -pe 's#LDADDS = #LDADDS = \$(shell echo \$(LDADDS_0) | sed \"s|C:/|/c/|g\")\n\1\nLDADDS_0 = #' demos/Makefile perf/Makefile
  perl -i -pe 's#LINK = #LINK = \$(shell echo \$(LINK_0) | sed \"s|C:/|/c/|g\")\nLINK_0 = #' demos/Makefile perf/Makefile
  perl -i -pe 's#testtooltips$(EXEEXT) testvolumebutton$(EXEEXT)#testvolumebutton$(EXEEXT)#' demos/Makefile perf/Makefile

  # Setting the system name to MINGW64 to prevent python lib defaulting to cl.exe on non-unix
  # The error is: Specified Compiler 'C:/.../x86_64-w64-mingw32-cc.exe' is unsupported.
  perl -i -pe "s|INTROSPECTION_TYPELIBDIR|INTROSPECTION_SCANNER_ENV = MSYSTEM=MINGW64\nINTROSPECTION_TYPELIBDIR|"  "${makefiles[@]}"
  pkg_config=$(echo "${RECIPE_DIR}/non-unix-helpers/my-pkg-config.bat" | sed -E 's|/|\\\\|g')
  perl -i -pe "s|(INTROSPECTION_SCANNER_ENV = MSYSTEM=MINGW64)|\1 PKG_CONFIG='${pkg_config}'|"  "${makefiles[@]}"
fi

make V=0 -j"$CPU_COUNT"
# make check -j$CPU_COUNT
make install -j$CPU_COUNT

if [[ "${target_platform}" == win-* ]]; then
  bindir=$(echo "${PREFIX}/Library/bin" | sed -E 's|/|\\|g')
  libdir=$(echo "${PREFIX}/Library/lib" | sed -E 's|/|\\|g')
  dlltool=${BUILD_PREFIX}/Library/x86_64-w64-mingw32/bin/dlltool.exe
  ${dlltool} -D "${bindir}"\\libgdk-win32-2.0-0.dll -d "${libdir}"\\gdk-win32-2.0.def -l "${libdir}"\\gdk-win32-2.0.lib
  ${dlltool} -D "${bindir}"\\libgtk-win32-2.0-0.dll -d "${libdir}"\\gtk-win32-2.0.def -l "${libdir}"\\gtk-win32-2.0.lib
  ${dlltool} -D "${bindir}"\\libgailutil-18.dll -d "${libdir}"\\gailutil.def -l "${libdir}"\\gailutil.lib
fi

# We use the GTK 3 version of gtk-update-icon-cache
# https://github.com/conda-forge/gtk2-feedstock/issues/24
rm -f ${PREFIX}/bin/gtk-update-icon-cache*
rm -f ${PREFIX}/share/man/man1/gtk-update-icon-cache.1
