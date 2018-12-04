setlocal enabledelayedexpansion

set CGO_ENABLED=0
rem First, build go1.4 using gcc
cd "%PKG_NAME%\src"
call make.bat
if errorlevel 1 exit 1

mkdir "%PREFIX%\%PKG_NAME%"
xcopy /s /y /i /q "%SRC_DIR%\%PKG_NAME%\*" "%PREFIX%\%PKG_NAME%\"

rem Copy the rendered [de]activate scripts to %PREFIX%\etc\conda\[de]activate.d.
rem go finds its *.go files via the GOROOT variable
for %%F in (activate deactivate) do (
  if not exist "%PREFIX%\etc\conda\%%F.d" mkdir "%PREFIX%\etc\conda\%%F.d"
  if errorlevel 1 exit 1
  copy "%RECIPE_DIR%\%%F-%PKG_NAME%.bat" "%PREFIX%\etc\conda\%%F.d\%%F-%PKG_NAME%.bat"
  if errorlevel 1 exit 1
  dir %PREFIX%\etc\conda\%%F.d\
)
