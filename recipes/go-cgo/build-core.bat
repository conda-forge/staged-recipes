rem Setting CGO_ENABLED=1 will come from _go_select
rem Temporarily set CGO_ENABLED=1 here, remove 
rem set "CGO_LDFLAGS="
set "CGO_ENABLED=1"

rem Set the CC and CXX TARGETS
set "CC_FOR_TARGET=%CC%"
set "CXX_FOR_TARGET=%CXX%"

rem Put GOTMPDIR on the same drive as the CONDA_BLD_PATH (the D drive),
rem to avoid a known issue in the go test suite:
rem https://github.com/golang/go/issues/24846#issuecomment-381380628
rem set "GOTMPDIR=D:\\tmp"
rem mkdir "%GOTMPDIR%"

rem Do not use GOROOT_FINAL. Otherwise, every conda environment would
rem need its own non-hardlinked copy of go (+100MB per env).
rem It is better to rely on setting GOROOT during environment activation.
rem
rem c.f. https://github.com/conda-forge/go-feedstock/pull/21#discussion_r202513916
set "GOROOT=%SRC_DIR%\go"
set "GOCACHE=off"

rem Print diagnostics before starting the build
set

pushd "%GOROOT%\src"
call make.bat
if errorlevel 1 exit 1
popd

rem Don't need the cached build objects
rmdir /s /q %GOROOT%\pkg\obj

rem The following should match the build instructions from go-precompiled
mkdir "%PREFIX%\go"
xcopy /s /y /i /q "%GOROOT%\*" "%PREFIX%\go\"

rem Remove Invalid UTF-8 Filename and conflict with libarchive
rem c.f. https://github.com/conda-forge/staged-recipes/pull/9535#discussion_r403512142
del "%PREFIX%\go\test\fixedbugs\issue27836.go
rmdir /S /Q "%PREFIX%\go\test\fixedbugs\issue27836.dir

rem Right now, it's just go and gofmt, but might be more in the future!
if not exist "%PREFIX%\bin" mkdir "%PREFIX%\bin"
for %%f in ("%PREFIX%\go\bin\*.exe") do (
  move %%f "%PREFIX%\bin"
)

rem all files in bin are gone
rmdir /q /s "%PREFIX%\go\bin"
if errorlevel 1 exit 1
