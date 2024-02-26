set SRCDIR=%CD%\src

@REM A few (silent) sanity checks that variables are set and meaningful:
if exist %PREFIX%\ echo %PREFIX% is in place
@rem if %errorlevel% neq 0 exit /b %errorlevel% 
if exist %SRCDIR%\ echo %SRCDIR% is in place
@rem if %errorlevel% neq 0 exit /b %errorlevel% 
if exist %SRCDIR%\CMakeLists.txt echo CMakeLists.txt is in place
@rem if %errorlevel% neq 0 exit /b %errorlevel% 

verify other 2> nul
setlocal eneableextensions
if errorlevel 1 echo Unable to enable extensions 
@rem if %errorlevel% neq 0 exit /b %errorlevel% 
if defined PKG_VERSION echo version %PGK_VERSION% 
@rem if %errorlevel% neq 0 exit /b %errorlevel% 
endlocal

mkdir %CD%\build_mcxtrace_core
set BLDDIR=%CD%\build_mcxtrace_core

cd %BLDDIR%

@REM Configure.
cmake ^
    -DCMAKE_INSTALL_PREFIX=%PREFIX% ^
    -S %SRCDIR% ^
    -G "NMake Makefiles" ^
    -DMCVERSION=%PKG_VERSION% ^
    -DMCCODE_BUILD_CONDA_PKG=ON ^
    -DCMAKE_INSTALL_LIBDIR=lib ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DBUILD_MCXTRACE=ON ^
    -DMCCODE_USE_LEGACY_DESTINATIONS=OFF ^
    -DBUILD_TOOLS=ON ^
    -DENABLE_COMPONENTS=ON ^
    -DENSURE_MCPL=OFF ^
    -DENSURE_NCRYSTAL=OFF ^
    -DENABLE_CIF2HKL=OFF ^
    -DENABLE_NEUTRONICS=OFF ^
    -DBUILD_SHARED_LIBS=ON

@REM ^	DCMAKE_C_COMPILER=gcc.exe

	
cmake --build . --config Release

cmake --build . --target install --config Release

@REM lines below are in bash syntax, for later conversion
@REM test -f "${PREFIX}/bin/mcxtrace"
@REM test -f "${PREFIX}/bin/mxrun"
@REM test -f "${PREFIX}/share/mcxtrace/tools/Python/mccodelib/__init__.py"
@REM test -d "${PREFIX}/share/mcxtrace/resources/data"

@REM Data files will be provided in mcxtrace-data package instead:
rd /s /q %PREFIX%\share\mcxtrace\resources\data

@REM #Temporary workarounds:
@REM if [ -f "${PREFIX}/bin/postinst" ]; then
@REM     rm -f "${PREFIX}/bin/postinst"
@REM fi
@REM if [ -f "${PREFIX}/bin/acc_gpu_bind" ]; then
@REM     mv "${PREFIX}/bin/acc_gpu_bind" "${PREFIX}/bin/mcxtrace-acc_gpu_bind"
@REM fi

@REM  Activation script (simply to get $MCXTRACE convenience env var to work in the
@REM  same way as when McXtrace is installed in other manners.
@REM for CHANGE in "activate" "deactivate"
@REM do
@REM     mkdir -p "${PREFIX}/etc/conda/${CHANGE}.d"
@REM     cp "${RECIPE_DIR}/${CHANGE}.sh" "${PREFIX}/etc/conda/${CHANGE}.d/${PKG_NAME}_${CHANGE}.sh"
@REM done
