:: Overwrite CMakeLists.txt for dynamic linking
del CMakeLists.txt
copy "%RECIPE_DIR%\CMakeLists.txt" .

:: Install Python package
python -m pip install . -vv --no-deps --no-build-isolation
