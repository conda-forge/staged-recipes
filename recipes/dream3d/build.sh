#!/bin/bash
# Based on https://github.com/BlueQuartzSoftware/DREAM3D/wiki/Configuring-and-Building-DREAM.3D-(Linux)#using-the-command-line-advanced-users-only
mkdir ../dream3d-build
cd ../dream3d-build
cmake -DCMAKE_BUILD_TYPE=Debug ../dream3d
