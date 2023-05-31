#!/usr/bin/env bash

set -ex

# Get an updated config.sub and config.guess
cp $BUILD_PREFIX/share/gnuconfig/config.* .

if [[ "$target_platform" == win-* ]]; then
    # make sure host env is on PKG_CONFIG_PATH
    export PKG_CONFIG_PATH="$PKG_CONFIG_PATH:$PREFIX/lib/pkgconfig:$PREFIX/share/pkgconfig"
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
    --with-perl-binding
    --with-python-binding
    --with-tcl-binding
    --with-tcl="$PREFIX/lib"
    --with-xml-support
)

if [[ "$target_platform" == win-* ]]; then
    PY_LIBDIR=$($PYTHON -c "import os, sysconfig; print(os.path.join(sysconfig.get_config_var('prefix'), 'libs'))")
    PY_LIBNAME=$($PYTHON -c "import sysconfig; print('python'+sysconfig.get_config_var('VERSION'))")
    configure_args+=(
        PYTHON_LIBS="-L$PY_LIBDIR -l$PY_LIBNAME"
        PYTHON_EXTRA_LIBS=" "
        PYTHON_EXTRA_LDFLAGS=" "
        --with-perl-inc="$PREFIX/lib/CORE"
    )
else
    core_perl_dir="$(perldir="$PREFIX/lib/perl*/*/core_perl"; echo $perldir)"
    configure_args+=(
        --with-perl-inc="$core_perl_dir/CORE"
    )
fi

if [[ "$target_platform" == osx-* ]]; then
    # strip build-time OSX sysroot from perl config
    # (because it ends up overriding the correct CONDA_BUILD_SYSROOT)
    sed -i "s/--sysroot.*\.sdk//g" $core_perl_dir/Config_heavy.pl
    sed -i "s/^sysroot=.*/sysroot=''/g" $core_perl_dir/Config_heavy.pl
    build_core_perl_dir="$(perldir="$BUILD_PREFIX/lib/perl*/*/core_perl"; echo $perldir)"
    if [[ -d "$build_core_perl_dir" ]]; then
        sed -i "s/--sysroot.*\.sdk//g" $build_core_perl_dir/Config_heavy.pl
        sed -i "s/^sysroot=.*/sysroot=''/g" $build_core_perl_dir/Config_heavy.pl
    fi
fi

# update configure script following patching
autoreconf -i

./configure "${configure_args[@]}" || (cat config.log; false)
[[ "$target_platform" == "win-64" ]] && patch_libtool

if [[ "$target_platform" != win-* ]]; then
    # don't actually want to link with Python library when building module
    sed -i "s/^PYTHON_LIBS =.*/PYTHON_LIBS =/g" bindings/Makefile
    # let -undefined dynamic_lookup take effect on osx
    sed -i "s/-no-undefined //g" bindings/Makefile
fi

make V=1 -j${CPU_COUNT}

pushd bindings
# fix to link perl bindings with host libs
sed -i "s|-L$BUILD_PREFIX|-L$PREFIX|g" Hamlib-pl.mk
sed -i "s|-Wl,-rpath,$BUILD_PREFIX|-Wl,-rpath,$PREFIX|g" Hamlib-pl.mk
sed -i "s|-Wl,-rpath-link,$BUILD_PREFIX|-Wl,-rpath-link,$PREFIX|g" Hamlib-pl.mk
# rebuild the perl bindings with these changes
make all-perl
popd

make install

# if [[ "$target_platform" == win-* ]]; then
#   # remove unversioned DLL since Windows doesn't do symlinks
#   # (functionally this is replaced by the lib/liquid.lib import lib anyway)
#   rm $PREFIX/lib/libliquid.dll
#   # put DLLs where they properly belong in bin
#   mv $PREFIX/lib/liquid*.dll $PREFIX/bin
# fi

# undo hiding tcl.pc from above
if [[ -f "$PREFIX/lib/pkgconfig/tcl.pc.bak" ]]; then
    mv $PREFIX/lib/pkgconfig/tcl.pc.bak $PREFIX/lib/pkgconfig/tcl.pc
fi
