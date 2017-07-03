cd python
SET ARROW_HOME=%LIBRARY_PREFIX%
"%PYTHON%" setup.py ^
           build_ext --build-type=Release ^
           install --single-version-externally-managed --record=record.txt
if errorlevel 1 exit 1
