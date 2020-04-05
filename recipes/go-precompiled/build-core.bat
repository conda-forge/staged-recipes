mkdir "%PREFIX%\go"
xcopy /s /y /i /q "%SRC_DIR%\go\*" "%PREFIX%\go\"

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
