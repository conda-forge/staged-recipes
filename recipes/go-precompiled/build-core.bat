setlocal enabledelayedexpansion

rem Copy the rendered [de]activate scripts to %PREFIX%\etc\conda\[de]activate.d.
rem go finds its *.go files via the GOROOT variable
for %%F in (activate deactivate) do (
  if not exist "%PREFIX%\etc\conda\%%F.d" mkdir "%PREFIX%\etc\conda\%%F.d"
  if errorlevel 1 exit 1
  copy "%RECIPE_DIR%\%%F-go-%go_variant_str%.bat" "%PREFIX%\etc\conda\%%F.d\%%F_z60-go.bat"
  if errorlevel 1 exit 1
)

call "%PREFIX%\etc\conda\activate.d\activate_z60-go.bat"

mkdir "%PREFIX%\go"
xcopy /s /y /i /q "%SRC_DIR%\go\*" "%PREFIX%\go\"

rem Right now, it's just go and gofmt, but might be more in the future!
if not exist "%PREFIX%\bin" mkdir "%PREFIX%\bin"
for %%f in ("%PREFIX%\go\bin\*.exe") do (
  move %%f "%PREFIX%\bin"
)

rem all files in bin are gone
rmdir /q /s "%PREFIX%\go\bin"
if errorlevel 1 exit 1
