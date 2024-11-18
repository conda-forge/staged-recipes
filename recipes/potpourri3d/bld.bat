:: Enable error checking and echo each command
set EXIT_ON_ERROR=1

:: Overwrite CMakeLists.txt for dynamic linking
del CMakeLists.txt
copy "%RECIPE_DIR%\CMakeLists.txt" .

:: Install Python package
python -m pip install . -vv --no-deps --no-build-isolation
