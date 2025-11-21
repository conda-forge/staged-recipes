# SpeexDSP Recipe - Windows Build Modernization

This recipe packages the SpeexDSP library, a patent-free, Open Source/Free Software DSP library derived from Speex.
This recipe has been modernized to use industry-standard Windows development tools (CMake + MSVC) instead of legacy MSYS2/autotools.
https://conda-forge.org/docs/maintainer/knowledge_base/#moving-from-an-autotools-build-to-a-cmake-build

While there is tooling to make autotools work on Windows, 
I have found reworking the project to use CMake regardless of platform is clearer and gives consistent builds.
There is an outstanding pull request to upstream to add CMake support.
https://github.com/xiph/speexdsp/pull/53/files
