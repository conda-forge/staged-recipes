@echo off

:: there's a symbolic link from faiss/ to ./ in the upstream repo that does not work with windows;
:: delete symlink & copy entire source recursively (= "/S") to folder faiss to work around it
rmdir faiss
robocopy . faiss /S

call %BUILD_PREFIX%\Library\bin\run_autotools_clang_conda_build.bat build-pkg.sh
if %ERRORLEVEL% neq 0 exit 1
