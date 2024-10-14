@echo on

cd ascii
:: clean up files that only have \r as line endings; this breaks flang
sed -i "s/\\r//g" build.i
sed -i "s/\\r//g" mkfreq.f
sed -i "s/\\r//g" mxpeak.f

:: the makefiles are only makefile _templates_, but basically functional;
:: to avoid use of perl for mkmf, just execute the template and then
:: do the installation step manually
make FC="%FC% -w" LINKER=lld-link LDFLAGS="" install -f makefile.gf
if %ERRORLEVEL% neq 0 exit 1
copy .\x13as_ascii %LIBRARY_BIN%\x13as_ascii.exe
if %ERRORLEVEL% neq 0 exit 1

cd ..\html
make FC="%FC% -w" LINKER=lld-link LDFLAGS="" install -f makefile.gf
if %ERRORLEVEL% neq 0 exit 1
copy .\x13as_html %LIBRARY_BIN%\x13as_html.exe
if %ERRORLEVEL% neq 0 exit 1
