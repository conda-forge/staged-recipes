#!/usr/bin/env bash

# Test for OpenGL Driver on Linux
if [ `uname` == Linux ]; then
    $PREFIX/bin/python -c "import OpenGL.GL"
    rc=$?;
    if [[ $rc != 0 ]]; then
        echo Warning: Missing OpenGL driver, install with yum install mesa-libGL-devel or equivalent
        exit 1
    fi
fi
