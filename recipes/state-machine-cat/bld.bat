@echo on
cmd /c "yarn pack"
if errorlevel 1 exit 1
cmd /c "yarn licenses generate-disclaimer > ThirdPartyLicenses.txt"
if errorlevel 1 exit 1

md %LIBRARY_PREFIX%\share\smcat
pushd %LIBRARY_PREFIX%\share\smcat

md node_modules
cmd /c "npm install smcat@%PKG_VERSION%"
if errorlevel 1 exit 1

pushd %LIBRARY_PREFIX%\bin
for %%c in (smcat) do (
  echo @echo on >> %%c.bat
  echo "%LIBRARY_PREFIX%\share\smcat\node_modules\.bin\%%c.cmd" %%* >> %%c.bat
)
