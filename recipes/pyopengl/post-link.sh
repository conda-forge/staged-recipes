#!/usr/bin/env bash
$PYTHON -c "import OpenGL.GL" && echo OpenGL OK || echo Warning: Missing OpenGL driver, install with yum install mesa-libGL-devel or equivalent
