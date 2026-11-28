@echo on

if not exist out\pylib\anki mkdir out\pylib\anki
if errorlevel 1 exit 1
<nul set /p="%ANKI_TAG%" > out\buildhash

set "PROTOC=%BUILD_PREFIX%\Library\bin\protoc.exe"
set "PYO3_PYTHON=%PYTHON%"

cargo auditable build --release --locked -p rsbridge --features native-tls
if errorlevel 1 exit 1
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
if errorlevel 1 exit 1

if defined CARGO_BUILD_TARGET (
  copy target\%CARGO_BUILD_TARGET%\release\rsbridge.dll out\pylib\anki\_rsbridge.pyd
) else (
  copy target\release\rsbridge.dll out\pylib\anki\_rsbridge.pyd
)
if errorlevel 1 exit 1

setlocal EnableDelayedExpansion
set "PROTOS="
for %%f in (proto\anki\*.proto) do set "PROTOS=!PROTOS! %%f"
protoc --plugin=protoc-gen-mypy=%BUILD_PREFIX%\Scripts\protoc-gen-mypy.exe --python_out=out\pylib --mypy_out=out\pylib -Iproto !PROTOS!
if errorlevel 1 exit 1
endlocal

pushd pylib\tools
set "PYTHONPATH=..\anki\_vendor"
python genhooks.py ..\..\out\pylib\anki\hooks_gen.py
if errorlevel 1 exit 1
set "PYTHONPATH="
popd
python pylib\tools\genbuildinfo.py .version out\buildhash out\pylib\anki\buildinfo.py
if errorlevel 1 exit 1

set ANKI_WHEEL_TAG=py3-none-any
%PYTHON% -m pip install .\pylib -vv --no-deps --no-build-isolation
if errorlevel 1 exit 1
