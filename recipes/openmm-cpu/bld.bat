mkdir build
cd build

set FFTW=C:\Miniconda3\pkgs\fftw3f-3.3.4-vc14_2\Library
"C:\Program Files\CMake\bin\cmake.exe" .. -G "NMake Makefiles JOM" -DCMAKE_INSTALL_PREFIX=%PREFIX% -DCMAKE_BUILD_TYPE=Release -DOPENMM_GENERATE_API_DOCS=ON ^
    -DFFTW_INCLUDES="%FFTW%/include" -DFFTW_LIBRARY="%FFTW%/lib/libfftw3f-3.lib"

jom install
jom PythonInstall
jom C++ApiDocs
jom PythonApiDocs
REM jom sphinxpdf
jom install

mkdir openmm-docs
robocopy %PREFIX%\docs openmm-docs * /e /move
mkdir %PREFIX%\docs
move openmm-docs %PREFIX%\docs\openmm
mkdir %PREFIX%\share\openmm
move %PREFIX%\examples %PREFIX%\share\openmm

