mkdir build
cd build

cmake.exe .. -G "NMake Makefiles JOM" -DCMAKE_INSTALL_PREFIX=%PREFIX% -DCMAKE_BUILD_TYPE=Release -DOPENMM_GENERATE_API_DOCS=ON ^
    -DFFTW_INCLUDES="%LIBRARY_INC%" -DFFTW_LIBRARY="%LIBRARY_LIB%/libfftw3f-3.lib"

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
