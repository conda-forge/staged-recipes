@ECHO ON
setlocal EnableDelayedExpansion

:: Ensure LOCALAPPDATA is defined — it can be unset in later conda build variants
if not defined LOCALAPPDATA (
    set "LOCALAPPDATA=%USERPROFILE%\AppData\Local"
)

:: Tell ort-sys to use dynamic loading instead of downloading onnxruntime at build time
set "ORT_PREFER_DYNAMIC_LINK=1"

:: Force UTF-8 output so cargo/maturin output is not silenced by the CI log reader
set "PYTHONUTF8=1"

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
if errorlevel 1 exit /b 1

python -m pip install . --no-build-isolation -vv
if errorlevel 1 exit /b 1
