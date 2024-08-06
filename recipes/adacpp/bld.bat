@echo off

python -m pip install . --no-build-isolation -v ^
    --config-settings=cmake.args=-DODBDUMP_BIN_DIR="%LIBRARY_PREFIX%"/bin ^
    --config-settings=cmake.args=-DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
    --config-settings=cmake.args=-DCONDA_BUILD=ON