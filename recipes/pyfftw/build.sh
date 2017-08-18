#!/usr/bin/env bash

export C_INCLUDE_PATH=$PREFIX/include  # required as fftw3.h installed here

# define STATIC_FFTW_DIR so the patched setup.py will statically link FFTW
export STATIC_FFTW_DIR=$PREFIX/lib

if [[ `uname` == 'Linux' ]]; then
    # -Bsymbolic link flag to ensure MKL FFT routines don't shadow FFTW ones.
    # see:  https://github.com/pyFFTW/pyFFTW/issues/40
    export CFLAGS="$CFLAGS -Wl,-Bsymbolic"
fi

$PYTHON setup.py build
$PYTHON setup.py install --single-version-externally-managed --record=record.txt --optimize=1
