@echo on

cargo build --release || goto :error

:: this can fail, but copying might still work
md "%PREFIX%\Scripts\"

:: TODO: remove debugging
dir "target\release\"

copy "target\release\%PKG_NAME%.exe" "%PREFIX%\Scripts\%PKG_NAME%.exe" || goto :error

:: TODO: remove debugging
dir "%PREFIX%\Scripts\%PKG_NAME%.exe"

goto :EOF

:error
echo FAIL Building %PKG_NAME% with error #%errorlevel%.
exit /b %errorlevel%
