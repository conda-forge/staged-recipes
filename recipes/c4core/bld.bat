@REM Fetch auxiliary GitHub projects only needed to build c4core (they are not
@REM shipped with the library!) Note c4core relies on git submodules, but since we
@REM have downloaded a tarball, we need to fetch these repos manually.
git clone https://github.com/biojppm/cmake.git --depth 1
rmdir /s /q src\c4\ext\debugbreak\ && git clone https://github.com/biojppm/debugbreak.git --depth 1 src\c4\ext\debugbreak

@REM Configure the build of the library
mkdir build
cd build
cmake -GNinja .. ${CMAKE_ARGS} -DCMAKE_BUILD_TYPE=Release

@REM Build and install the library in $PREFIX
ninja install
