#!/usr/bin/env bash
python -c "import OpenGL.GL" && echo OpenGL OK || echo Warning: Missing OpenGL driver, install with yum install mesa-libGL-devel or equivalent
