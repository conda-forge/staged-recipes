md buildlibs
cd buildlibs
cmake -G "NMake Makefiles" ^
  -D CMAKE_BUILD_TYPE=Release ^
  -D VSP_USE_SYSTEM_LIBXML2=true ^
  -D VSP_USE_SYSTEM_FLTK=true ^
  -D VSP_USE_SYSTEM_GLM=true ^
  -D VSP_USE_SYSTEM_GLEW=true ^
  -D VSP_USE_SYSTEM_CMINPACK=true ^
  -D VSP_USE_SYSTEM_EXPRPARSE=true ^
  -D VSP_USE_SYSTEM_PINOCCHIO=true ^
  -D VSP_USE_SYSTEM_LIBIGES=false ^
  -D VSP_USE_SYSTEM_EIGEN=true ^
  -D VSP_USE_SYSTEM_CODEELI=false ^
  -D VSP_USE_SYSTEM_CPPTEST=false ^
  %SRC_DIR%/Libraries
if errorlevel 1 exit 1

nmake
if errorlevel 1 exit 1

cd ..
md build
cd build
cmake -G "NMake Makefiles" ^
  -D CMAKE_BUILD_TYPE=Release ^
  -D CMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
  -D VSP_ENABLE_MATLAB_API=OFF ^
  -D VSP_USE_SYSTEM_EIGEN=ON ^
  -D VSP_USE_SYSTEM_FLTK=ON ^
  -D VSP_USE_SYSTEM_PINOCCHIO=ON ^
  -D VSP_USE_SYSTEM_EXPRPARSE=ON ^
  -D VSP_USE_SYSTEM_GLEW=ON ^
  -D VSP_USE_SYSTEM_LIBXML2=ON ^
  %SRC_DIR%/src/

nmake package
if errorlevel 1 exit 1

nmake install
if errorlevel 1 exit 1
