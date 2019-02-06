set "mathjax=%LIBRARY_LIB%\mathjax"
mkdir "%mathjax%" || exit 1

move config "%mathjax%\" || exit 1
move docs "%mathjax%\" || exit 1
move extensions "%mathjax%\" || exit 1
move fonts "%mathjax%\" || exit 1
move jax "%mathjax%\" || exit 1
move localization "%mathjax%\" || exit 1
move test "%mathjax%\" || exit 1
move unpacked "%mathjax%\" || exit 1

del /q "*.md" ".gitignore" ".npmignore" ".travis.yml" "bower.json" "composer.json" "latest.js" "package.json" || exit 1
xcopy /s "%cd%" "%mathjax%" || exit 1
del /q "%mathjax%\*.bat" "%mathjax%\LICENSE" || exit 1

if not exist "%SCRIPTS%" mkdir "%SCRIPTS%" || exit 1
copy "%RECIPE_DIR%\.mathjax-post-link.bat" "%SCRIPTS%\" || exit 1
copy "%RECIPE_DIR%\.mathjax-pre-unlink.bat" "%SCRIPTS%\" || exit 1
