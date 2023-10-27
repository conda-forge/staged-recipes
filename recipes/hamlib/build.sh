#!/usr/bin/env bash

set -ex

# Get an updated config.sub and config.guess
cp $BUILD_PREFIX/share/gnuconfig/config.* .

if [[ "$target_platform" == win-* ]]; then
    # reset compiler to m2w64-toolchain since MSVC is also activated
    # (MSVC is needed later to generate the import lib)
    export CC=gcc.exe
    export CXX=g++.exe
    export PATH="$PREFIX/bin:$BUILD_PREFIX/Library/bin:$SRC_DIR:$PATH"
    # set default include and library dirs for Windows build
    export CPPFLAGS="$CPPFLAGS -isystem $PREFIX/include"
    export LDFLAGS="$LDFLAGS -L$PREFIX/lib"
    # make sure host env is on PKG_CONFIG_PATH
    export PKG_CONFIG_PATH="$PKG_CONFIG_PATH:$PREFIX/lib/pkgconfig:$PREFIX/share/pkgconfig"
    # don't have libtool check if libraries should be linked, just link them
    # (fixes linking with libusb)
    export lt_cv_deplibs_check_method='pass_all'
fi

# hide tcl pkgconfig file because its presence prevents using tclConfig.sh
# which means the tcl bindings don't get installed to the right place
if [[ -f "$PREFIX/lib/pkgconfig/tcl.pc" ]]; then
    mv $PREFIX/lib/pkgconfig/tcl.pc $PREFIX/lib/pkgconfig/tcl.pc.bak
fi

if [[ "$target_platform" == osx-* ]]; then
    # use dynamic lookup on osx so building lua bindings works
    export LDFLAGS="$LDFLAGS -undefined dynamic_lookup"
fi

configure_args=(
    --prefix="$PREFIX"
    --disable-static
    --enable-shared
    --with-cxx-binding
    --with-lua-binding
    --with-python-binding
    --with-tcl-binding
    --with-tcl="$PREFIX/lib"
    --with-xml-support
)

if [[ "$target_platform" == win-* ]]; then
    PY_INCDIR=$(cygpath -u $($PYTHON -c "import os, sysconfig; print(os.path.join(sysconfig.get_config_var('prefix'), 'include'))"))
    PY_LIBDIR=$(cygpath -u $($PYTHON -c "import os, sysconfig; print(sysconfig.get_config_var('prefix'))"))
    PY_LIBNAME=$($PYTHON -c "import sysconfig; print('python'+sysconfig.get_config_var('VERSION'))")
    configure_args+=(
        LIBUSB_LIBS="-L$PREFIX/bin -lusb-1.0"
        PYTHON_CPPFLAGS="-I$PY_INCDIR"
        PYTHON_LIBS="-L$PY_LIBDIR -l$PY_LIBNAME"
        PYTHON_SITE_PKG="$SP_DIR"
        am_cv_python_pyexecdir="$SP_DIR"
        am_cv_python_pythondir="$SP_DIR"
        PYTHON_EXTRA_LIBS=" "
        PYTHON_EXTRA_LDFLAGS=" "
        #--with-perl-inc="$PREFIX/lib/CORE"
    )
else
    core_perl_dir="$(perldir="$PREFIX/lib/perl*/*/core_perl"; echo $perldir)"
    configure_args+=(
        --with-perl-binding
        --with-perl-inc="$core_perl_dir/CORE"
    )
fi

if [[ "$target_platform" == osx-* ]]; then
    # temporary fix until https://github.com/conda-forge/perl-feedstock/pull/63
    sed -i "/^lddlflags/ s|,|-rpath |g" $core_perl_dir/Config_heavy.pl
    build_core_perl_dir="$(perldir="$BUILD_PREFIX/lib/perl*/*/core_perl"; echo $perldir)"
    if [[ -d "$build_core_perl_dir" ]]; then
        sed -i "/^lddlflags/ s|,|-rpath |g" $build_core_perl_dir/Config_heavy.pl
    fi

fi

# update configure script following patching
autoreconf -i

./configure "${configure_args[@]}" || (cat config.log; false)

if [[ "$target_platform" != win-* ]]; then
    # don't actually want to link with Python library when building module
    # (otherwise we get segfaults on osx)
    sed -i "s/^PYTHON_LIBS =.*/PYTHON_LIBS =/g" bindings/Makefile
    # let -undefined dynamic_lookup take effect on osx
    sed -i "s/-no-undefined //g" bindings/Makefile
else
    # create a .def file for the c++ bindings
    sed -i "s/\(libhamlib___la_LDFLAGS =\)\(.*\)/\1 -Wl,--output-def,libhamlib++.def\2/" c++/Makefile
    # purge Windows-style path from TCL_INCLUDE_SPEC which gets used everywhere
    sed -i "s/\(TCL_INCLUDE_SPEC =\).*/\1 -I\${prefix}\/include/g" bindings/Makefile
    # fix linking with tcl library
    sed -i "s/\(TCL_LIB_SPEC =\).*/\1 -l\$(TCL_LIB_FILE:.lib=)/g" bindings/Makefile
    # lua bindings need to link with lua library on Windows
    sed -i "s/\(Hamliblua_la_LIBADD = \)\(.*\)/\1\2 \$(LUA_LIB)/g" bindings/Makefile
    # tell Perl's MakeMaker to use nmake since GNU make is not supported
    #sed -i "/MAKEFILE=\"Hamlib-pl.mk\".*/aMAKE=\"nmake\" \\\\" bindings/Makefile
    #sed -i "s/\$(MAKE).*\(-f Hamlib-pl.mk\)/env -u MAKE -u MAKEFLAGS nmake \1/g" bindings/Makefile
    # debug ld for perl binding
    #sed -i "/MAKEFILE=\"Hamlib-pl.mk\".*/aLDDLFLAGS=\"-mdll \\\\\$\$(LDFLAGS) -Wl,--verbose -Wl,--no-gc-sections\" \\\\" bindings/Makefile
fi

make V=1

if [[ "$target_platform" != win-* ]]; then
    pushd bindings
    # fix to link perl bindings with host libs
    sed -i "s|-L$BUILD_PREFIX|-L$PREFIX|g" Hamlib-pl.mk
    sed -i "s|-Wl,-rpath,$BUILD_PREFIX|-Wl,-rpath,$PREFIX|g" Hamlib-pl.mk
    sed -i "s|-Wl,-rpath-link,$BUILD_PREFIX|-Wl,-rpath-link,$PREFIX|g" Hamlib-pl.mk
    # rebuild the perl bindings with these changes
    make all-perl
    popd
fi

make install

if [[ "$target_platform" == win-* ]]; then
    # correct Python extension library suffix to .pyd
    mv "$SP_DIR/_Hamlib.dll" "$SP_DIR/_Hamlib.pyd"
    rm "$SP_DIR/_Hamlib.dll.a"
fi

# undo hiding tcl.pc from above
if [[ -f "$PREFIX/lib/pkgconfig/tcl.pc.bak" ]]; then
    mv $PREFIX/lib/pkgconfig/tcl.pc.bak $PREFIX/lib/pkgconfig/tcl.pc
fi
