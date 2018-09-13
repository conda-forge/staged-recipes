cd pycoalescence

%PYTHON% installer.py --cmake-args="-DCMAKE_PREFIX_PATH=%PREFIX% -DCMAKE_INSTALL_PREFIX=%PREFIX% -DCMAKE_C_COMPILER=%CC% -DCMAKE_CXX_COMPILER=%CXX%"

del __pycache__
del obj
del reference
del lib

cd ..

copy pycoalescence %SP_DIR%

