@echo on

@rem install all (prod) dependencies, this needs to be done for pnpm to properly list all dependencies later on
cmd /c "pnpm install --prod"
if errorlevel 1 exit 1

@rem list all dependencies and then call pnpm-licenses to generate the ThirdPartyLicenses.txt file
cmd /c "pnpm licenses list --prod --json | pnpm-licenses generate-disclaimer --prod --json-input --output-file=ThirdPartyLicenses.txt"
if errorlevel 1 exit 1

cmd /c "pnpm pack"
if errorlevel 1 exit 1

md %LIBRARY_PREFIX%\share\markdownlint-cli
pushd %LIBRARY_PREFIX%\share\markdownlint-cli
md node_modules
cmd /c "npm install %SRC_DIR%\markdownlint-cli-%PKG_VERSION%.tgz"
if errorlevel 1 exit 1
popd

pushd %LIBRARY_PREFIX%\bin
for %%c in (markdownlint) do (
  echo @echo off >> %%c.bat
  echo "%LIBRARY_PREFIX%\share\markdownlint-cli\node_modules\.bin\%%c.cmd" %%* >> %%c.bat
)
popd

