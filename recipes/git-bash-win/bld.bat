set "_bash=%LIBRARY_PREFIX%\git-bash-win"
mkdir "%_bash%" || exit 1
7za x PortableGit-%PKG_VERSION%-%ARCH%-bit.7z.exe -o"%_bash%" -aoa || exit 1

move "%_bash%\LICENSE.txt" .\ || exit 1
del "%_bash%\README.portable" || exit 1

if not exist "%PREFIX%\bin" mkdir "%PREFIX%\bin" || exit 1
copy "%RECIPE_DIR%\bash.bat" "%PREFIX%\bin\" || exit 1

if not exist "%SCRIPTS%" mkdir "%SCRIPTS%" || exit 1
copy "%RECIPE_DIR%\.git-bash-win-post-link.bat" "%SCRIPTS%\" || exit 1
