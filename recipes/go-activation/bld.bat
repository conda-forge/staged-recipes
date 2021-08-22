@echo on
rem Install [de]activate scripts.
for %%F in (activate deactivate) do (
  if not exist "%PREFIX%\etc\conda\%%F.d" mkdir "%PREFIX%\etc\conda\%%F.d"
  if errorlevel 1 exit 1

  rem First, copy them to the work directory
  copy "%RECIPE_DIR%\%%F.bat" "%PREFIX%\etc\conda\%%F.d\%%F-z61-%PKG_NAME%.bat"
  if errorlevel 1 exit 1
)

