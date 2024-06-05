
set "REPO=urschrei/rdp"
for /f "tokens=*" %%i in ('curl --silent "https://api.github.com/repos/%REPO%/releases/latest" ^| findstr /i "tag_name"') do (
    set "TAG=%%i"
    set "TAG=!TAG:*\"tag_name\": \"=!"
    set "TAG=!TAG:\"\,,=!"
    set "TAG=!TAG:~0,-1!"
)

set filename="rdp-${tag}-x86_64-pc-windows-msvc.tar.gz"
set "url=https://github.com/urschrei/rdp/releases/download/%TAG%/%filename%"
curl -L %url% -o %filename%
tar -xzvf %filename% -C src\simplification

"%PYTHON%" -m pip install . -vv --no-deps --no-build-isolation
if errorlevel 1 exit 1
