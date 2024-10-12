@echo on

cd ascii
:: the makefiles are only makefile _templates_, but basically functional;
:: to avoid use of perl for mkmf, just execute the template and then
:: do the installation step manually
make FC="%FC% -w" LINKER=lld-link LDFLAGS="" install -f makefile.gf
if %ERRORLEVEL% neq 0 exit 1
copy .\x13as_ascii.exe %LIBRARY_BIN%
if %ERRORLEVEL% neq 0 exit 1

cd ..\html
make FC="%FC% -w" LINKER=lld-link LDFLAGS="" install -f makefile.gf
if %ERRORLEVEL% neq 0 exit 1
copy .\x13as_html.exe %LIBRARY_BIN%
if %ERRORLEVEL% neq 0 exit 1
