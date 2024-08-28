@echo on

md %LIBRARY_PREFIX%\share\marp
pushd %LIBRARY_PREFIX%\share\marp
md node_modules
cmd /c "npm install @marp-team/marp-cli@%PKG_VERSION%"
if errorlevel 1 exit 1
popd

pushd %LIBRARY_PREFIX%\bin
for %%c in (marp-cli) do (
  echo @echo off >> %%c.bat
  echo "%LIBRARY_PREFIX%\share\marp-cli\node_modules\.bin\%%c.cmd" %%* >> %%c.bat
)
popd

@rem port yarn.lock to pnpm-lock.yaml
cmd /c "pnpm import"
if errorlevel 1 exit 1

@rem install all (prod) dependencies, this needs to be done for pnpm to properly list all dependencies later on
cmd /c "pnpm install --prod"
if errorlevel 1 exit 1

@rem list all dependencies and then call pnpm-licenses to generate the third-party-licenses.txt file
cmd /c "pnpm licenses list --prod --json | pnpm-licenses generate-disclaimer --prod --json-input --output-file=third-party-licenses.txt"
if errorlevel 1 exit 1

@rem log directory structure in order to easily verify if porting yarn.lock, installing packages and generating licenses worked
dir
