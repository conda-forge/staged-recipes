set "STAN_VER=%PKG_VERSION:~0,-2%"

pushd pystan\\stan\\lib\\stan_math_%STAN_VER%
if errorlevel 1 exit 1

rd /q /s doc doxygen make test lib\\cpplist_4.45 lib\\gtest_1.7.0
if errorlevel 1 exit 1

popd
if errorlevel 1 exit 1


:: For VS<10 copy stdint to the pystan directory so models can be compiled.
if %VS_MAJOR% LSS 10 (
  robocopy %LIBRARY_INC% pystan\\stan\\src stdint.h
  if errorlevel GTR 1 exit 1
)

python setup.py install -q --single-version-externally-managed --record=record.txt
if errorlevel 1 exit 1
