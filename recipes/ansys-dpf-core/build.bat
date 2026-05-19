rem Remove Linux binaries
del /q src\ansys\dpf\gatebin\*.so

pip install . --no-deps --no-build-isolation -vv
if errorlevel 1 exit 1