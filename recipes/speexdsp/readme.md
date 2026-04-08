# SpeexDSP Recipe - Windows Build Modernization

This recipe packages the SpeexDSP library, a patent-free, Open Source/Free Software DSP library derived from Speex.
This recipe has been modernized to use industry-standard Windows development tools (CMake + MSVC) instead of legacy MSYS2/autotools.
https://conda-forge.org/docs/maintainer/knowledge_base/#moving-from-an-autotools-build-to-a-cmake-build

While there is tooling to make autotools work on Windows, 
I have found reworking the project to use CMake regardless of platform is clearer and gives consistent builds.
There is an outstanding issue and branch which add CMake support.

* https://gitlab.xiph.org/xiph/speexdsp/-/issues/17
* https://gitlab.com/babeloff/speexdsp/-/tree/cmake

The `src` files in this project are copied from that branch.
