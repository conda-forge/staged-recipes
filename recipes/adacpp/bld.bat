@echo off

python -m pip install . --no-build-isolation -v ^
    --config-settings=cmake.args=-DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
    --config-settings=cmake.args=-DBUILD_TESTING=ON