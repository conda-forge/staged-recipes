#!/bin/bash

if [[ $TRAVIS_OS_NAME == osx ]]; then
    echo "XCODES AVAILABLE:"
    xcode-select --print-path

    echo "INSTALLING?"
    xcode-select --install

    echo "CC IS: $(which cc)"
    echo "CLANG IS: $(which clang)"
    echo "TRYNA RUN CC:"
    cc
fi

python -m pip install --no-deps --ignore-installed .
