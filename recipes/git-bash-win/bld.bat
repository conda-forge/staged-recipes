set "_bash=%LIBRARY_PREFIX%\git-bash-win"
mkdir "%_bash%" || exit 1
7za x PortableGit-%PKG_VERSION%-%ARCH%-bit.7z.exe -o"%_bash%" -aoa || exit 1

copy "%_bash%\LICENSE.txt" .\ || exit 1
patch -i "%RECIPE_DIR%\01-devices.post.patch" "%_bash%\etc\post-install\01-devices.post" || exit 1
patch -i "%RECIPE_DIR%\post-install.bat.patch" "%_bash%\post-install.bat" || exit 1

if not exist "%PREFIX%\bin" mkdir "%PREFIX%\bin" || exit 1
copy "%RECIPE_DIR%\bash.bat" "%PREFIX%\bin\" || exit 1
copy "%RECIPE_DIR%\git-bash.bat" "%PREFIX%\bin\" || exit 1
