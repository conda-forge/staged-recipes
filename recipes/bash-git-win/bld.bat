mkdir "%LIBRARY_PREFIX%\bash-git" || exit 1
7za x PortableGit-%PKG_VERSION%-%ARCH%-bit.7z.exe -o"%LIBRARY_PREFIX%\bash-git" -aoa || exit 1
if errorlevel 1 exit 1

move "%LIBRARY_PREFIX%\bash-git\LICENSE.txt" .\ || exit 1
cd "%LIBRARY_PREFIX%\bash-git" || exit 1
call post-install.bat
del post-install.bat || exit 1
del README.portable || exit 1

IF NOT EXIST "%PREFIX%\Menu" mkdir -p "%PREFIX%\Menu" || exit 1
copy "%RECIPE_DIR%\bash-git.json" "%PREFIX%\Menu\" || exit 1
copy "%RECIPE_DIR%\bash-git.ico" "%PREFIX%\Menu\" || exit 1

if not exist "%PREFIX%\bin" mkdir "%PREFIX%\bin" || exit 1
copy "%RECIPE_DIR%\bash.bat" "%PREFIX%\bin\" || exit 1
copy "%RECIPE_DIR%\git.bat" "%PREFIX%\bin\" || exit 1
