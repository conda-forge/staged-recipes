setlocal enabledelayedexpansion

rem Copy the rendered [de]activate scripts to %PREFIX%\etc\conda\[de]activate.d.
rem go finds its *.go files via the GOROOT variable
for %%F in (deactivate activate) do (
  set "FDIR=%PREFIX%\etc\conda\%%F.d"
  if not exist "%FDIR%" mkdir "%FDIR%"
  if errorlevel 1 exit 1
  copy "%RECIPE_DIR%\%%F-go-%go_variant_str%.bat" "%%FDIR%%\%%F_z60-go.bat"
  if errorlevel 1 exit 1
)

call "%FDIR%\activate-z60_go.bat"

rem Set the CC and CXX TARGETS
set "CC_FOR_TARGET=%CC%"
set "CXX_FOR_TARGET=%CXX%"
set "CGO_LDFLAGS="

rem Put GOTMPDIR on the same drive as the CONDA_BLD_PATH (the D drive),
rem to avoid a known issue in the go test suite:
rem https://github.com/golang/go/issues/24846#issuecomment-381380628
set "GOTMPDIR=D:\\tmp"
mkdir "%GOTMPDIR%"

rem Do not use GOROOT_FINAL. Otherwise, every conda environment would
rem need its own non-hardlinked copy of the go (+100MB per env).
rem It is better to rely on setting GOROOT during environment activation.
rem
rem c.f. https://github.com/conda-forge/go-feedstock/pull/21#discussion_r202513916
set "GOROOT=%SRC_DIR%\go"
set "GOCACHE=off"

pushd "%GOROOT%\src"
call make.bat
if errorlevel 1 exit 1
popd

rem Don't need the cached build objects
rmdir /s /q %GOROOT%\pkg\obj

mkdir "%PREFIX%\go"
xcopy /s /y /i /q "%GOROOT%\*" "%PREFIX%\go\"

rem Right now, it's just go and gofmt, but might be more in the future!
if not exist "%PREFIX%\bin" mkdir "%PREFIX%\bin"
for %%f in ("%PREFIX%\go\bin\*.exe") do (
  move %%f "%PREFIX%\bin"
)

rem all files in bin are gone
rmdir /q /s "%PREFIX%\go\bin"
if errorlevel 1 exit 1
