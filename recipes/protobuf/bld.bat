:: Install the Python portions too.
cd %SRC_DIR%
if errorlevel 1 exit 1
cd python
if errorlevel 1 exit 1

:: Begin fix for missing packages issue: https://github.com/conda-forge/protobuf-feedstock/issues/40
if not exist "google/protobuf/util" mkdir "google/protobuf/util"
if errorlevel 1 exit 1
if not exist "google/protobuf/compiler" mkdir "google/protobuf/compiler"
if errorlevel 1 exit 1
type nul >> "google/protobuf/util/__init__.py"
if errorlevel 1 exit 1
type nul >> "google/protobuf/compiler/__init__.py"
if errorlevel 1 exit 1
:: End fix

"%PYTHON%" setup.py install --single-version-externally-managed --record record.txt
if errorlevel 1 exit 1
