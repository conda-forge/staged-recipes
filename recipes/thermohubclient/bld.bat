set FART="%CD%\tools\fart\fart.exe"

echo
echo ******                		 ******
echo ****** Compiling Velocypack ******
echo ******                		 ******
echo

mkdir tmp_velo
cd tmp_velo

echo Get velocypack from git...

git clone https://github.com/arangodb/velocypack.git
cd velo*

echo Setting linker settings from /MT to /MD
echo "Fart location: %FART%"
echo "Curent directory: %CD%"
%FART% "%CD%\cmake\Modules\AR_CompilerSettings.cmake" MTd MDd
%FART% "%CD%\cmake\Modules\AR_CompilerSettings.cmake" MT MD

mkdir build
cd build

echo "Configuring..."
cmake -G Ninja -DCMAKE_BUILD_TYPE=Release -DBuildTools=OFF -DBuildVelocyPackExamples=OFF -DBuildTests=OFF ..
echo "Building..."
ninja install

cd ..

echo
echo ******                         ******
echo ****** Compiling JSONARNAGO    ******
echo ******                         ******
echo

echo git clone jsonarango...
git clone https://bitbucket.org/gems4/jsonarango.git
cd jsonarango

mkdir build
cd build

echo "Configuring..."
cmake -G Ninja -DCMAKE_BUILD_TYPE=Release -DJSONARANGO_BUILD_EXAMPLES=OFF ..
echo "Building..."
ninja install

cd ..

cd ..\..\..
REM Housekeeping
rd /s /q "%CD%\tmp*"

echo "Building ThermoHubClient..."

mkdir build
cd build

if "%VS_MAJOR%" == "9" (
ECHO VS 2008
set CXXFLAGS=%CXXFLAGS:-D_hypot=hypot
) else (
REM This is a fix for a CMake bug where it crashes because of the "/GL" flag
REM See: https://gitlab.kitware.com/cmake/cmake/issues/16282
set CXXFLAGS=%CXXFLAGS:-GL=%
set CFLAGS=%CFLAGS:-GL=%
)

cmake -G Ninja ^
    -DTHERMOFUN_PYTHON_INSTALL_PREFIX:PATH="%PREFIX%" ^
    -DCMAKE_BUILD_TYPE=Release ^
    ..
ninja install
