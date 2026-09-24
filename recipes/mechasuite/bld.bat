:: ---- install python library ----

:: ---- build Qt app ----

cd %SRC_DIR%
%PYTHON% -m pip install . --no-deps --no-build-isolation --prefix=%PREFIX%
cd mechaedit
qmake PREFIX=%PREFIX%
nmake
nmake install
